#import "chipset/lib/vic2.asm"

.segmentdef Code [start=$0810]
.file [name="./demo.prg", segments="Code", modify="BasicUpstart", _start=$0810]
.segment Code

start:
    lda #CYAN
    sta c64lib.BORDER_COL
    rts
