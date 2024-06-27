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
.label SLIDES = 4

.segmentdef LOADER      [min=START_ADDRESS]
.segmentdef BOOTSTRAP   [min=MD_BANK_ADDRESS, max=$9fff, fill]
.segmentdef SLIDE_0     [min=MD_BANK_ADDRESS, max=$dfff, fill]
.segmentdef SLIDE_1     [min=MD_BANK_ADDRESS, max=$dfff, fill]
.segmentdef SLIDE_2     [min=MD_BANK_ADDRESS, max=$dfff, fill]
.segmentdef SLIDE_3     [min=MD_BANK_ADDRESS, max=$dfff, fill]
.segmentdef FILLER      [min=MD_BANK_ADDRESS, max=MD_BANK_ADDRESS + CRT_SIZE - (1 + SLIDES*3)*8*1024 - 1, fill]

.segment CRT_FILE [outBin="slideshow-crt.bin"]
    .segmentout [segments="BOOTSTRAP"]
    .for (var i = 0; i < SLIDES; i++) {
        .segmentout [segments="SLIDE_" + i]
    }
    .segmentout [segments="FILLER"]

.segment LOADER
    * = START_ADDRESS "Loader"
        // set up C64
        lda #BLACK
        sta c64lib.BORDER_COL
        sei
        c64lib_disableCIAInterrupts()
        c64lib_configureMemory(c64lib.BASIC_IO_KERNAL)
        c64lib_setVICBank(0)
        cli
        // set up VIC-2
        lda #GREY
        sta c64lib.BG_COL_0
        lda #%00011000
        sta c64lib.CONTROL_2
        lda #%00111011
        sta c64lib.CONTROL_1
        lda #%00001000
        sta c64lib.MEMORY_CONTROL

    loop: 
        jsr loadSlide
        jmp loop

    loadSlide: {
        // blank screen
        lda c64lib.CONTROL_1
        and #%11101111
        sta c64lib.CONTROL_1
        // load bitmap
        ldx #<BITMAP_LOCATION
        lda #>BITMAP_LOCATION
        jsr mdLoader.setTarget
        ldx #<8000
        ldy #>8000
        lda slideBank
        jsr mdLoader.load
        inc slideBank
        // load color ram
        ldx #<c64lib.COLOR_RAM
        lda #>c64lib.COLOR_RAM
        jsr mdLoader.setTarget
        ldx #<1000
        ldy #>1000
        lda slideBank
        jsr mdLoader.load
        inc slideBank
        // load screen colors
        ldx #<SCREEN_MEM
        lda #>SCREEN_MEM
        jsr mdLoader.setTarget
        ldx #<1000
        ldy #>1000
        lda slideBank
        jsr mdLoader.load
        // show screen
        lda c64lib.CONTROL_1
        ora #%00010000
        sta c64lib.CONTROL_1

        inc slideBank
        lda slideBank
        cmp #(SLIDES * 3 + 1)
        bne !+
            // loop slides
            lda #1
            sta slideBank
        !:

        // wait
        ldx #255
    !:  lda c64lib.RASTER
        cmp #255
        bne !-
        dex
        bne !-

        rts
    }

    mdLoader: createMagicDeskLoader() // magic desk loader code
    
    // vars
    slideBank: .byte 1

.segment BOOTSTRAP
    * = MD_BANK_ADDRESS "Bootstrap"
    .print "Loader size = " + (loaderCodeEnd - loaderCode)
    createMagicDeskBootstrap($FB, $FD, $400, loaderCodeEnd - loaderCode, MD_BANK_ADDRESS, START_ADDRESS)
    loaderCode:
    .segmentout[segments="LOADER"]
    loaderCodeEnd:

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

.segment SLIDE_1
    * = MD_BANK_ADDRESS "Slide 1"
    dumpSlide("screen-1")

.segment SLIDE_2
    * = MD_BANK_ADDRESS "Slide 2"
    dumpSlide("screen-2")

.segment SLIDE_3
    * = MD_BANK_ADDRESS "Slide 3"
    dumpSlide("screen-3")
