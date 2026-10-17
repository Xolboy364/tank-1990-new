; NES iNES Header
.segment "HEADER"
  .byte "NES", $1A
  .byte 2         ; 2 x 16KB PRG ROM (Jami 32KB)
  .byte 1         ; 1 x 8KB CHR ROM
  .byte $00, $00  ; Mapper 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0

.segment "CODE"
reset:
  sei             ; IRQ o'chirish
  cld             ; Decimal rejimni o'chirish
  ldx #$40
  stx $4017       ; APU frame counter o'chirish
  ldx #$FF
  txs             ; Stack pointerni sozlash
  inx
  stx $2000       ; NMI o'chirish
  stx $2001       ; Rendering o'chirish
  stx $4010       ; DMC IRQ o'chirish

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

forever:
  jmp forever

.segment "VECTORS"
  .word 0, 0, 0
  .word 0, 0, reset, 0
