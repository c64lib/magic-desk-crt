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

#importonce

/*
 * Creates a auto staring bootstrap code for cartridge. Main goal of the boostrap code 
 * is to copy magic desk loader to the target address and run it.
 * The bootstrap code is run directly from a cartridge (that is a ROM memory) therefore 
 * it cannot use self modyfing code thus 4 zero page bytes are required to use indirect
 * indexed addressing mode for copying code.
 *
 * For typical magic desk setup on stock C64 the code generated by this macro should be
 * always placed at $8000 as it will always be visible at this location once cartridge
 * is plugged in and the C64 is powered on.
 *
 * Input parameters:
 *   - `zeroPageAddr1` two bytes location on a zero page space
 *   - `zeroPageAddr2` two bytes location on a zero page space
 *   - `zeroPageAddr3` two bytes location anywhere in RAM memory
 *   - `loaderCodeSize` the size of the loader
 *   - `loaderSourceAddress` the address of the loader code (usually it is somewhere in 
 *     CRT BANK 0 right after bootstrap code). In most cases it should be set to $8000.
 *   - `loaderTargetAddress` the target address for the loader code (can be as low as 
 *     $0801 or even lower if needed)
 */
.macro createMagicDeskBootstrap(zeroPageAddr1, zeroPageAddr2, zeroPageAddr3, loaderCodeSize, loaderSourceAddress, loaderTargetAddress) {

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

        .label sourceAdr = loaderSourceAddress + (bootstrapCodeEnd - bootstrapCodeBegin)
        .label size = loaderCodeSize
        .label SOURCE_PTR = zeroPageAddr1
        .label DEST_PTR = zeroPageAddr2
        .label COUNTER = zeroPageAddr3

        .print "size = " + size

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

                dec COUNTER
                lda COUNTER
                cmp #$ff
                bne !+
                    dec COUNTER+1
                !:

                lda #0
                cmp COUNTER
                bne !+
                    cmp COUNTER + 1
                !:

                beq end
                iny
                cpy #0
            bne copyNext
            inc SOURCE_PTR + 1
            inc DEST_PTR + 1
        jmp copyNextPage
        end:

        jmp loaderTargetAddress


    bootstrapCodeEnd:
}