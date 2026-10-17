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

; PPU ni sozlash
load_palettes:
  lda $2002             ; PPUSTATUS ni o'qib, manzilni reset qilamiz
  lda #$3F              ; Palitra manzilining yuqori bayti ($3F00)
  sta $2006
  lda #$00              ; Palitra manzilining pastki bayti ($00)
  sta $2006

  ldx #$00
load_palettes_loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20              ; 32 bayt palitra yuklaymiz
  bne load_palettes_loop

; NMI (VBlank) ni yoqish
  lda #%10000000        ; NMI ni yoqish
  sta $2000
  lda #%00011110        ; Fon (Background) va Spritelarni yoqish
  sta $2001

forever:
  jmp forever

; NMI (Har bir kadr yangilanishida ishlaydi)
nmi:
  ; Hozircha bu yerda hech narsa qilmaymiz
  rti

; Palitralar ma'lumotlari
palettes:
  ; Fon palitrasi (Fon rangi, va 3 ta rang)
  .byte $21, $11, $21, $31   ; Ko'k fon
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  ; Sprite palitrasi
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31

.segment "VECTORS"
  .word nmi       ; NMI
  .word reset     ; RESET
  .word 0         ; IRQ
