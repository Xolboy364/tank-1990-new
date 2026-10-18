; --- NES Header ---
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

.segment "CODE"
reset:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$FF
  txs
  inx
  stx $2000       ; NMI o'chirildi
  stx $2001       ; Rendering o'chirildi
  stx $4010

vblank1:
  bit $2002
  bpl vblank1

; Xotirani tozalash (RAM va OAM)
clrmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE        ; Sprite'larni yashirish
  sta $0200, x
  inx
  bne clrmem

vblank2:
  bit $2002
  bpl vblank2

; 1. Palitrani yuklash (Fon rangi QIZIL, Sprite sariq)
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

; 2. EKRAN XOTIRASINI TOZALASH (O'sha ko'k to'rlarni yo'q qilish)
  lda #$20
  sta $2006
  lda #$00
  sta $2006
  lda #$00
  ldx #$00
  ldy #$04
clear_nametable:
  sta $2007       ; $00 (bo'sh) yozamiz
  dex
  bne clear_nametable
  dey
  bne clear_nametable

; 3. Tank koordinatalari
  lda #120
  sta player_x
  lda #100
  sta player_y

; 4. Tank bo'laklari (Tile)
  lda #$00
  sta $0201
  lda #$01
  sta $0205
  lda #$10
  sta $0209
  lda #$11
  sta $020D

  lda #$00        ; Palitra 0
  sta $0202
  sta $0206
  sta $020A
  sta $020E

; 5. Ekranni yoqish (Faqat Sprite'lar, Fon o'chirilgan)
  lda #%10000000  
  sta $2000
  lda #%00010100  ; Fon(BG) OFF, Sprite ON (Shunda faqat qizil fon va tank ko'rinadi)
  sta $2001

main_loop:
  jmp main_loop

; --- NMI ---
nmi:
  lda #$00
  sta $2003
  lda #$02
  sta $4014

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

  lda buttons
  and #%00001000
  beq check_down
  dec player_y
check_down:
  lda buttons
  and #%00000100
  beq check_left
  inc player_y
check_left:
  lda buttons
  and #%00000010
  beq check_right
  dec player_x
check_right:
  lda buttons
  and #%00000001
  beq update_sprites
  inc player_x

update_sprites:
  ; Tank 4 ta bo'lagini koordinatalarini yangilash
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
  .byte $16, $16, $16, $16   ; Fon rangi QIZIL ($16)
  .byte $16, $16, $16, $16
  .byte $16, $16, $16, $16
  .byte $16, $16, $16, $16
  .byte $0F, $28, $18, $38   ; Sprite rangi (Sariq)
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38
  .byte $0F, $28, $18, $38

.segment "VECTORS"
  .word nmi
  .word reset
  .word 0
