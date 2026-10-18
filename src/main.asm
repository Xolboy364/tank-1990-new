.segment "HEADER"
  .byte "NES", $1A
  .byte 2
  .byte 1
  .byte $00, $00
  .byte 0, 0, 0, 0, 0, 0, 0, 0

.segment "CODE"
reset:
  sei
  cld
  ldx #$FF
  txs
  inx
  stx $2000       ; NMI o'chirildi
  stx $2001       ; PPU o'chirildi

vblank1:
  bit $2002
  bpl vblank1

; Palitrani yuklash (Faqat qizil rang)
  lda #$3F
  sta $2006
  lda #$00
  sta $2006
  lda #$16        ; Qizil rang kodi
  sta $2007
  lda #$16
  sta $2007
  lda #$16
  sta $2007
  lda #$16
  sta $2007

; Ekranni yoqish (Faqat fon rangi ko'rinadi)
  lda #%00000000
  sta $2000
  lda #%00000000  ; Fon (BG) va Spritelar o'chirilgan
  sta $2001

forever:
  jmp forever

.segment "VECTORS"
  .word 0
  .word reset
  .word 0
