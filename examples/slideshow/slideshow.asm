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

#import "../../lib/bootstrap.asm"
#import "../../lib/loader.asm"
#import "chipset/lib/vic2-global.asm"
#import "chipset/lib/cia-global.asm"
#import "chipset/lib/mos6510-global.asm"

.label START_ADDRESS = $0801
.label MD_BANK_ADDRESS = $8000

.label VIC_RAM_BASE = $C000

.label BITMAP_LOCATION = $E000
.label BITMAP_LOCATION_ENC = (BITMAP_LOCATION - VIC_RAM_BASE)/8*1024

.label SCREEN_MEM = VIC_RAM_BASE
.label SCREEN_MEM_ENC = (SCREEN_MEM - VIC_RAM_BASE)/1024

.label CRT_SIZE = 512*1024
.label SLIDES = 1

.segmentdef LOADER      [min=START_ADDRESS]
.segmentdef BOOTSTRAP   [min=MD_BANK_ADDRESS, max=$9fff, fill]
.segmentdef SLIDE_0     [min=MD_BANK_ADDRESS, max=$dfff, fill]
.segmentdef FILLER      [min=MD_BANK_ADDRESS, max=MD_BANK_ADDRESS + CRT_SIZE - (1 + SLIDES*3)*8*1024 - 1, fill]

.segment CRT_FILE [outBin="slideshow-crt.bin"]
    .segmentout [segments="BOOTSTRAP"]
    .segmentout [segments="SLIDE_0"]
    .segmentout [segments="FILLER"]

.segment LOADER
    * = START_ADDRESS "Loader"
    loaderStart: 
        // set up C64
        lda #BLACK
        sta c64lib.BORDER_COL
        sei
        c64lib_disableCIAInterrupts()
        c64lib_configureMemory(c64lib.RAM_IO_RAM)
        c64lib_setVICBank(0)
        cli
        // set up VIC-2
        lda #BLACK
        sta c64lib.BG_COL_0
        lda #%00011000
        sta c64lib.CONTROL_2
        lda #%00111011
        sta c64lib.CONTROL_1
        lda #(SCREEN_MEM_ENC + BITMAP_LOCATION_ENC)
        sta c64lib.MEMORY_CONTROL

        // load bitmap
        ldx #<BITMAP_LOCATION
        lda #>BITMAP_LOCATION
        jsr mdLoader.setTarget
        ldx #<8000
        ldy #>8000
        lda #1
        jsr mdLoader.load
        // load color ram
        ldx #<c64lib.COLOR_RAM
        lda #>c64lib.COLOR_RAM
        jsr mdLoader.setTarget
        ldx #<1000
        ldy #>1000
        lda #2
        jsr mdLoader.load
        // load screen colors
        ldx #<SCREEN_MEM
        lda #>SCREEN_MEM
        jsr mdLoader.setTarget
        ldx #<1000
        ldy #>1000
        lda #3
        jsr mdLoader.load

    loop: jmp loop

    mdLoader: createMagicDeskLoader() // magic desk loader code
    loaderEnd:

.segment BOOTSTRAP
    * = MD_BANK_ADDRESS "Bootstrap"
    createMagicDeskBootstrap($07, $0F, loaderEnd - loaderStart, MD_BANK_ADDRESS, START_ADDRESS)
    .segmentout[segments="LOADER"]

.macro _dumpVar(binary) {
    .fill binary.getSize(), binary.get(i)
    .fill 8*1024 - binary.getSize(), 0
}

.macro dumpSlide(name) {
    .var chars = LoadBinary(name + "-charset.bin")
    .var cols = LoadBinary(name + "-colours.bin")
    .var scrn = LoadBinary(name + "-screen-colours.bin")
    _dumpVar(chars)
    _dumpVar(cols)
    _dumpVar(scrn)
}

.segment SLIDE_0
    * = MD_BANK_ADDRESS "Slide 0"
    dumpSlide("screen-0")
