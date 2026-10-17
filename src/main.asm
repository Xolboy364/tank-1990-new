; --- NES Header ---
.segment "HEADER"
  .byte "NES", $1A
  .byte 2         ; 32KB PRG
  .byte 1         ; 8KB CHR
  .byte $00, $00  ; Mapper 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0

.segment "CODE"

; --- Xotira o'zgaruvchilari ---
.segment "ZEROPAGE"
player_x:   .res 1
player_y:   .res 1
buttons:    .res 1
frame_count: .res 1

.segment "CODE"

reset:
  sei
  cld
  ldx #$FF
  txs
  
  ; PPU o'chirilganini kutish
  bit $2002
vblank1:
  bit $2002
  bpl vblank1

  ; Palitrani yuklash
  lda #$3F
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
load_pal:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne load_pal

  ; Xotirani tozalash (Nametable)
  lda #$20
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
  ldy #$04
clear_nametable:
  lda #$00
  sta $2007
  dex
  bne clear_nametable
  dey
  bne clear_nametable

  ; O'yinchi boshlang'ich koordinatalari (O'rtada)
  lda #128
  sta player_x
  lda #200
  sta player_y

  ; Ekranni yoqish
  lda #%10000000
  sta $2000
  lda #%00011110  ; Fon va Spritelar yoqildi
  sta $2001

main_loop:
  jmp main_loop

; --- NMI (Har bir kadrda ishlaydi) ---
nmi:
  ; 1. Spritelarni yangilash (OAM DMA)
  lda #$00
  sta $2003
  lda #$02
  sta $4014

  ; 2. Kontrollerni o'qish
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
read_controller:
  lda $4016
  lsr a
  rol buttons
  dex
  bne read_controller

  ; 3. Harakatni tekshirish (D-pad)
  lda buttons
  and #%00001000  ; Yuqoriga
  beq check_down
  dec player_y
check_down:
  lda buttons
  and #%00000100  ; Pastga
  beq check_left
  inc player_y
check_left:
  lda buttons
  and #%00000010  ; Chapga
  beq check_right
  dec player_x
check_right:
  lda buttons
  and #%00000001  ; O'ngga
  beq update_sprites
  inc player_x

update_sprites:
  ; 4. Tankni (Sprite 0) chizish
  lda player_y
  sta $0200       ; Y koordinata
  lda #$00        ; Tile raqami (0-tile - tank)
  sta $0201
  lda #$00        ; Atribut (palitra)
  sta $0202
  lda player_x
  sta $0203       ; X koordinata

  ; Qolgan spritelarni yashirish (ekrandan tashqariga)
  lda #$FF
  sta $0204
  sta $0208
  sta $020C

  rti

; --- Ma'lumotlar ---
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
