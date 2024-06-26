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

/*
 * Macro: createMagicDeskLoader
 * Purpose: Creates a loader for MagicDesk cartridges, providing a jump table for 
 * setting target addresses and loading data into memory.
 * Usage:
 *   - Before using, ensure the macro is included in your assembly file.
 *   - Invoke the macro without arguments to instantiate the loader routines.
 *   - Use the jump table entries to call the loader subroutines, assuming the 
       `loader` label preceses macro execution (loader: createMagicDeskLoader()):
 *     - `loader.setTarget`: Sets the target memory address for loading data.
 *       IN: X = low byte of address, A = high byte of address
 *       Usage: JSR setTarget
 *     - `loader.load`: Loads data into memory at the previously set address.
 *       IN: A = bank number, X = size low byte, Y = size high byte
 *       Usage: JSR load
 */
.macro createMagicDeskLoader() {
    // jump table labels
    .label setTarget = *
    jmp _setTarget
    .label load = *
    jmp _load

    _setTarget: {
        stx target
        sta target + 1
        rts
    }

    // IN: A bank no, X size lo, Y size hi
    _load: {
        sta bankNumber
        stx size
        sty size + 1
        lda #0
        sta currentSize
        lda #$20
        sta currentSize + 1
        lda target
        sta currentTarget
        lda target + 1
        sta currentTarget + 1
    loop:
        lda size + 1
        cmp #$20 // less than 8kB
        bcs !+ // $2000 already in current size
    lessThan8kB:
        lda size
        sta currentSize
        lda size + 1
        sta currentSize + 1
    !:
        lda bankNumber
        sta $DE00 // switch bank number
        jsr __copy
        // subtract size
        sec
        lda size
        sbc currentSize
        sta size
        lda size + 1
        sbc currentSize + 1
        sta size + 1
        // check for end
        lda size
        bne !+
            lda size + 1
            beq !++
        !:
            // increment target
            clc
            lda currentTarget + 1
            adc #$20
            sta currentTarget + 1
            inc bankNumber
            jmp loop
    !:
        rts
    }

    __copy: {
        lda #$00
        sta ldaNext
        lda #$80
        sta ldaNext + 1

        lda currentTarget
        sta staNext
        lda currentTarget + 1
        sta staNext + 1

        lda currentSize
        sta copyCounter
        lda currentSize + 1
        sta copyCounter + 1

        copyNextPage:
            ldx #0
            copyNext:
            lda ldaNext:$ffff, x
            sta staNext:$ffff, x
            c64lib_dec16(copyCounter)
            c64lib_cmp16(0, copyCounter)
            beq end
            inx
            cpx #0
            bne copyNext
            c64lib_add16(256, ldaNext)
            c64lib_add16(256, staNext)
        jmp copyNextPage
        end:

        rts
        // local vars
        copyCounter: .word 0
    }

    // vars
    bankNumber:     .byte 0
    size:           .word 0
    currentSize:    .word 0
    target:         .word 0
    currentTarget:  .word 0
}
