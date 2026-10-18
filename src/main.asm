.segment "HEADER"
  .byte "NES", $1A
  .byte 2
  .byte 1
  .byte $00, $00
  .byte 0, 0, 0, 0, 0, 0, 0, 0

.segment "ZEROPAGE"
player_x:   .res 1
player_y:   .res 1
buttons:    .res 1
direction:  .res 1  ; 0=Yuqori, 1=O'ng, 2=Past, 3=Chap

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

vblank1:
  bit $2002
  bpl vblank1

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

vblank2:
  bit $2002
  bpl vblank2

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

; 2. Ekran xotirasini tozalash (Ko'k to'rlarni yo'q qilish)
  lda $2002
  lda #$20
  sta $2006
  lda #$00
  sta $2006
  ldy #$00
  ldx #$04
  lda #$00
clear_nametable:
  sta $2007
  iny
  bne clear_nametable
  dex
  bne clear_nametable

; 3. Boshlang'ich qiymatlar
  lda #120
  sta player_x
  lda #100
  sta player_y
  lda #$00
  sta direction

; 4. Palitra (Tank rangi)
  lda #$00
  sta $0202
  sta $0206
  sta $020A
  sta $020E

; 5. Ekranni yoqish
  lda #%10000000  
  sta $2000
  lda #%00011110  ; Fon va Spritelar yoqildi
  sta $2001

main_loop:
  jmp main_loop

; --- NMI ---
nmi:
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

  ; Harakat va Burilish
  lda buttons
  and #%00001000  ; Yuqoriga
  beq check_down
  dec player_y
  lda #$00
  sta direction
check_down:
  lda buttons
  and #%00000100  ; Pastga
  beq check_left
  inc player_y
  lda #$02
  sta direction
check_left:
  lda buttons
  and #%00000010  ; Chapga
  beq check_right
  dec player_x
  lda #$03
  sta direction
check_right:
  lda buttons
  and #%00000001  ; O'ngga
  beq update_sprites
  inc player_x
  lda #$01
  sta direction

update_sprites:
  ; Tankning 4 ta bo'lagi (Tile) ni yo'nalishga qarab tanlash
  lda direction
  cmp #$00
  beq dir_up
  cmp #$01
  beq dir_right
  cmp #$02
  beq dir_down
  cmp #$03
  beq dir_left

dir_up:
  lda #$00
  sta $0201
  lda #$01
  sta $0205
  lda #$10
  sta $0209
  lda #$11
  sta $020D
  jmp set_coords

dir_right:
  lda #$02
  sta $0201
  lda #$03
  sta $0205
  lda #$12
  sta $0209
  lda #$13
  sta $020D
  jmp set_coords

dir_down:
  lda #$04
  sta $0201
  lda #$05
  sta $0205
  lda #$14
  sta $0209
  lda #$15
  sta $020D
  jmp set_coords

dir_left:
  lda #$06
  sta $0201
  lda #$07
  sta $0205
  lda #$16
  sta $0209
  lda #$17
  sta $020D
  jmp set_coords

set_coords:
  ; Koordinatalarni joylash
  lda player_y
  sta $0200
  lda player_x
  sta $0203

  lda player_y
  sta $0204
  lda player_x
  clc
  adc #8
  sta $0207

  lda player_y
  clc
  adc #8
  sta $0208
  lda player_x
  sta $020B

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
  .byte $21, $11, $21, $31   ; Fon rangi (Ko'k)
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $21, $11, $21, $31
  .byte $0F, $28, $18, $38   ; Tank rangi (Sariq)
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38

.segment "VECTORS"
  .word nmi
  .word reset
  .word 0
