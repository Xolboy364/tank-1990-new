; --- NES Header ---
.segment "HEADER"
  .byte "NES", $1A
  .byte 2         ; 32KB PRG
  .byte 1         ; 8KB CHR
  .byte $00, $00  ; Mapper 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0

; --- Xotira o'zgaruvchilari ---
.segment "ZEROPAGE"
player_x:   .res 1
player_y:   .res 1
buttons:    .res 1

.segment "CODE"

reset:
  sei
  cld
  ldx #$FF
  txs
  
  ; PPU o'chirilganini kutish
vblank1:
  bit $2002
  bpl vblank1

  ; 1. Palitrani yuklash
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

  ; 2. Fon xotirasini tozalash (Ekran butunlay qora bo'ladi)
  lda #$20
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
  ldy #$04
clear_nametable:
  lda #$00        ; 0-tile ni yozamiz
  sta $2007
  dex
  bne clear_nametable
  dey
  bne clear_nametable

  ; 3. Tankning boshlang'ich koordinatalari
  lda #120
  sta player_x
  lda #100
  sta player_y

  ; 4. Tankning 4 ta bo'lagini (tile) sozlash
  ; Yuqori chap
  lda #$00
  sta $0201
  ; Yuqori o'ng
  lda #$01
  sta $0205
  ; Pastki chap
  lda #$10
  sta $0209
  ; Pastki o'ng
  lda #$11
  sta $020D

  ; Tank rangi (Palitra)
  lda #$00
  sta $0202
  sta $0206
  sta $020A
  sta $020E

  ; Ekranni yoqish (Fon va Spritelar)
  lda #%10000000
  sta $2000
  lda #%00011110
  sta $2001

main_loop:
  jmp main_loop

; --- NMI (Har bir kadrda ishlaydi) ---
nmi:
  ; OAM xotirasini yangilash (DMA)
  lda #$00
  sta $2003
  lda #$02
  sta $4014

  ; Kontrollerni o'qish
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

  ; Harakatni tekshirish (D-pad)
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
  ; Tankning 4 ta bo'lagini koordinatalarini yangilash
  ; Yuqori chap (X, Y)
  lda player_y
  sta $0200
  lda player_x
  sta $0203

  ; Yuqori o'ng (X+8, Y)
  lda player_y
  sta $0204
  lda player_x
  clc
  adc #8
  sta $0207

  ; Pastki chap (X, Y+8)
  lda player_y
  clc
  adc #8
  sta $0208
  lda player_x
  sta $020B

  ; Pastki o'ng (X+8, Y+8)
  lda player_y
  clc
  adc #8
  sta $020C
  lda player_x
  clc
  adc #8
  sta $020F

  rti

; --- Palitralar ---
palettes:
  ; Fon palitrasi (Ko'k fon)
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  ; Sprite palitrasi (Sariq tank)
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38

.segment "VECTORS"
  .word nmi
  .word reset
  .word 0
