; NES iNES Header
.segment "HEADER"
  .byte "NES", $1A
  .byte 2         ; 2 x 16KB PRG ROM
  .byte 1         ; 1 x 8KB CHR ROM
  .byte $00, $00  ; Mapper 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0

.segment "CODE"
reset:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$FF
  txs
  inx
  stx $2000
  stx $2001
  stx $4010

vblankwait1:
  bit $2002
  bpl vblankwait1

clrmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne clrmem

vblankwait2:
  bit $2002
  bpl vblankwait2

; 1. Palitrani yuklash
load_palettes:
  lda $2002
  lda #$3F
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
load_palettes_loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne load_palettes_loop

; 2. Ekran xotirasini (Nametable) tozalash
clear_nametable:
  lda $2002
  lda #$20
  sta $2006
  lda #$00
  sta $2006
  lda #$00
  ldx #$00
  ldy #$04
clear_loop:
  sta $2007
  dex
  bne clear_loop
  dey
  bne clear_loop

; 3. NMI ni yoqish va Fon rasmini O'CHIRISH (faqat rang ko'rinadi)
  lda #%10000000        ; NMI ON
  sta $2000
  lda #%00000110        ; Sprites ON, Background OFF (Ekran toza rangga o'tadi)
  sta $2001

forever:
  jmp forever

nmi:
  rti

palettes:
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31

.segment "VECTORS"
  .word nmi
  .word reset
  .word 0
