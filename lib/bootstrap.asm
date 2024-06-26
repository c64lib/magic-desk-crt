/*
 * MIT License
 *
 * Copyright (c) 2024 Maciej Małecki
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#import "common/lib/math-global.asm"
#import "common/lib/mem-global.asm"

#importonce
.filenamespace c64lib

.macro createMagicDeskBootstrap(zeroPageAddr1, zeroPageAddr2, loaderCodeSize, loaderTargetAddress) {


    bootstrapCodeBegin:
    .byte <init, >init
    .byte <initBasic, >initBasic
    .byte $C3, $C2, $CD, $38, $30 // CBM80 signature

    init:
        sei
        stx $d016
        jsr $fda3 // prepare irq
        jsr $fd50 // init memory
        jsr $fd15 // init i/o
        jsr $ff5b // init video
        cli
    initBasic:

        .label sourceAdr = $8000 + bootstrapCodeEnd - bootstrapCodeBegin
        .label size = loaderCodeSize
        .label SOURCE_PTR = zeroPageAddr1
        .label DEST_PTR = zeroPageAddr2

        lda #<sourceAdr
        sta SOURCE_PTR
        lda #>sourceAdr
        sta SOURCE_PTR + 1
        lda #<loaderTargetAddress
        sta DEST_PTR
        lda #>loaderTargetAddress
        sta DEST_PTR + 1
        lda #<size
        sta COUNTER
        lda #>size
        sta COUNTER + 1

        copyNextPage:
            ldy #0
            copyNext:
                lda (SOURCE_PTR), y
                sta (DEST_PTR), y
                c64lib_dec16(COUNTER)
                c64lib_cmp16(0, COUNTER)
                beq end
                iny
                cpy #0
            bne copyNext
            inc SOURCE_PTR + 1
            inc DEST_PTR + 1
        jmp copyNextPage
        end:

        jmp loaderTargetAddress

    // data
    COUNTER: .word 0

    bootstrapCodeEnd:
}