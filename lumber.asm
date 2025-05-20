;Young lumberjack closure
;---------------------------------------------------
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
;---------------------------------------------------

         OPT r+  ; saves 10 bytes, and probably works :) https://github.com/tebe6502/Mad-Assembler/issues/10

;---------------------------------------------------
.macro build
    dta d"0.44" ; number of this build (4 bytes)
.endm

.macro RMTSong
      lda #:1
      jsr RMTSongSelect
.endm

;---------------------------------------------------
    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'

display = $a000
    .zpvar temp .word = $80
    .zpvar temp2 .word
    .zpvar VBItemp .word
    .zpvar tempbyte .byte
    .zpvar SyncByte .byte
    .zpvar NTSCCounter  .byte
    .zpvar StateFlag .byte    ; 0 - menu, 1 - game screen, 2 RIP screen, 5 - game over screen, etc.
    .zpvar PowerValue .byte ; power: 0 - 48
    .zpvar PowerTimer .byte
    .zpvar PowerDownSpeed .byte
    .zpvar PowerSpeedIndex .byte
    .zpvar SpeedTableAdr .word
    .zpvar LevelValue .byte
    .zpvar Difficulty .byte ; 0 - normal, 1 - easy
    .zpvar LumberjackDir .byte ; 2 - on left , 1 - on right
    .zpvar PaddleState .byte
    .zpvar LowCharsetBase .byte
    .zpvar displayposition .word
    .zpvar LastKey  .byte   ; $ff if no key pressed or last key released
    .zpvar RMT_blocked sfx_effect .byte
    .zpvar AutoPlay .byte   ; Auto Play flag ($80 - auto)
    .zpvar birdsHpos    .byte   ; 0 - no birds on screen (from $13 to $de)
    .zpvar birdsOffset  .byte
    .zpvar birds_order  .byte   ; $00 - standard , $80 - reverse
    .zpvar clouds1Hpos,clouds2Hpos,clouds3Hpos  .byte     ; 0 - no cloud on screen (from $0e to $de)
     ; PMG registers for sprites over horizon	
    .zpvar HPOSP0_u   .byte	
    .zpvar HPOSP1_u   .byte	
    .zpvar HPOSP2_u   .byte	
    .zpvar HPOSP3_u   .byte	
    .zpvar HPOSM0_u   .byte	
    .zpvar HPOSM1_u   .byte	
    .zpvar HPOSM2_u   .byte	
    .zpvar HPOSM3_u   .byte	
    .zpvar SIZEP0_u   .byte	
    .zpvar SIZEP1_u   .byte	
    .zpvar SIZEP2_u   .byte	
    .zpvar SIZEP3_u   .byte	
    .zpvar SIZEM_u   .byte 	
    ; PMG registers for sprites under horizon
    .zpvar HPOSP0_d   .byte
    .zpvar HPOSP1_d   .byte
    .zpvar HPOSP2_d   .byte
    .zpvar HPOSP3_d   .byte
    .zpvar HPOSM0_d   .byte
    .zpvar HPOSM1_d   .byte
    .zpvar HPOSM2_d   .byte
    .zpvar HPOSM3_d   .byte
    .zpvar SIZEP0_d   .byte
    .zpvar SIZEP1_d   .byte
    .zpvar SIZEP2_d   .byte
    .zpvar SIZEP3_d   .byte
    .zpvar SIZEM_d   .byte 
    .zpvar GRAFP0_d   .byte
    .zpvar GRAFP1_d   .byte
    .zpvar GRAFP2_d   .byte
    .zpvar GRAFP3_d   .byte
    .zpvar GRAFM_d   .byte 
    .zpvar COLPM0_d   .byte
    .zpvar COLPM1_d   .byte
    .zpvar COLPM2_d   .byte
    .zpvar COLPM3_d   .byte

RMT_zpvars = AutoPlay+1  ; POZOR!!! RMT vars go here
;---------------------------------------------------
    org $2000
    .align $400
PMmemory
    .ds $400
font_game_upper
    ins 'art/tu.fnt'  ;
font_game_lower_right
    ins 'art/tl_r.fnt'  ;
font_game_lower_left
    ins 'art/tl_l.fnt'  ;
font_game_rip
    ins 'art/t_rip.fnt'  ;
font_titles
    ins 'art/title_fonts.fnt'   ;
font_logo
    ins 'art/title_logo.fnt'   ;
;---------------------------------------------------
dl_over
    .by $10,$70
    .by $45
    .wo over_screen    ; title screen (menu?)
    .by $85 ; DLI1 - second clouds
    .by $05
    .by $85 ; DLI2 - last clouds
    :4 .by $05
    .by $85 ; DLI - horizon
    :3 .by $05 
    .by $41
    .wo dl_over
;---------------------------------------------------
dl_title
    .by $10,$70
    .by $44+$80 ; DLI1 - Logo PM and colors
    .wo title_logo    ; title logo (menu?)
    .by $84 ; DLI2 - Logo colors
    .by $84 ; DLI3 - Logo PM and colors
    .by $84 ; DLI4 - second clouds
    .by $84 ; DLI5 - Logo colors
    .by $84 ; DLI6 - Logo colors
    .by $04
    .by $84 ; DLI7 - last clouds
    :2 .by $04
    .by $84 ; DLI8 - hat color change
    .by $04
    .by $84 ; DLI9 - timbermaner charset change
    :4 .by $04    
    .by $84 ; DLI10 - horizon
    .by $85  ; DLI_L2 - fonts
    .by $45+$80
difficulty_text_DL
    .wo difficulty_normal_text
    .by $45+$80
    .wo credits_lines
    .by $85
    .by $41
    .wo dl_title
;---------------------------------------------------
dl_level
    ;.by $10
    .by $44
    .wo power_bar    ; power indicator
    .by $04 
    .by $44
    .wo gamescreen_middle   ; branches
    .by $84  ; DLI1 - color change (power bar - letters) and second clouds
    :3 .by $04
    .by $84     ; DLI2 - last clouds
    :11 .by $04
    .by $84 ; DLI3
    .by $44
animation_addr
    .wo gamescreen_r_ph1p1
    .by $84 ; DLI4
    :3 .by $04
    .by $84 ; DLI5
    .by $84 ; DLI6
    .by $04
    .by $44
lastline_addr
    .wo last_line_r
    .by $41
    .wo dl_level
;---------------------------------------------------
Power = power_bar+32+10
gamescreen_middle
    .ds 32*18   ; 18 lines
screen_score = gamescreen_middle+6*32+14  
screen_level = gamescreen_middle+9*32+13  
;---------------------------------------------------
GameColors
    .ds 64
c_black = 0
c_white = 1 ; (numbers and letters)
c_sky = 2
c_dark_brown = 3
c_light_brown = 4
c_red = 5   ; (power bar)
c_shirtA = 6    ; Lumberjack shirt A
c_shirtB = 7    ; Lumberjack shirt B
c_hands = 8    ; Lumberjack hand/face
c_birds = 9
c_white2 = 10
c_light_red = 11    ; (power bar up)
c_horizonA = 12    ; thin horizon line A
c_horizonB = 13    ; thin horizon line B
c_grass = 14    ; green grass
c_hat = 15
c_buckle = 16    ; button and buckle... and logo
c_pants = 17    ; blue pants
c_greyRIP = 18
c_font1 = 19    ; title fonts colors
c_font2 = 20    ; .. and logo
c_font3 = 21
c_font4 = 22
c_font5 = 23
c_font1b = 24
c_font2b = 25
c_font5b = 26
c_logo1 = 27    ; rest of logo colors
c_logo2 = 28
c_logo3 = 29
c_logo4 = 30
c_logo5 = 31
c_clouds = 32  ; clouds
;---------------------------------------------------
    icl 'art/anim_exported.asm'
; Animations:
; v1 - if no branches
; v2 - if the branch under (due to change of sides) the lumberjack and none above - (now v1)
; v3 - if the branch opposite the lumberjack and no branch and none above - (now v1)
; v4 - if no branch at the level of the lumberjack and branch above (kill)
; v5 - if the branch under (due to change of sides) the lumberjack and branch above (kill) - (now v4)
; v6 - if the branch opposite the lumberjack and branch above (kill) - (now v4)
; v7 - if no branch at the level of the lumberjack and branch above on the other side
; v8 - if the branch under (due to change of sides) the lumberjack and branch above on the other side - (now v7)
; v9 - if the branch opposite the lumberjack and branch above on the other side - (now v7)
;--------------------------------------------------
title_logo
    icl 'art/title_logo.asm'    ;   17 lines, mode 4
title_screen
    icl 'art/title_screen.asm'  ;   13 lines, mode 5
    .align $400
over_screen
    icl 'art/over_screen.asm'   ;   12 lines, mode 5
difficulty_normal_text
    icl 'art/difficulty_texts.asm'   ;   2 lines, mode 5
difficulty_easy_text = difficulty_normal_text + 40
credits_texts
    icl 'art/credits.asm'   ;   10 lines, mode 5
number_of_credits = 5
credits_lines   ; 2 lines for credits animations
    :80 .by 0
    .by 0   ; for second line animation
credit_nr   ; number of credit to display (displayed)
    .ds 1
credits_anim_counter    ; counter for credits animation/display
    .ds 1
;--------------------------------------------------
.proc vint
;--------------------------------------------------
    lda StateFlag
    bne no_titles
    ; titles (StateFlag=0) - set DLI
    vdli TitlesDLI1
    jmp DLI_OK
no_titles
    cmp #3
    beq no_geme_and_RIP
    ; game screen and RIP screen (StateFlag=1 or 2) - set DLI
    vdli IngameDLI1
    jmp DLI_OK
no_geme_and_RIP    
    ; game over screen (StateFlag=3) - set DLI
    vdli GameOverDLI1

DLI_OK
    lda StateFlag
    jeq titles_VBI
    cmp #1
    beq game_VBI
    cmp #2
    beq game_VBI
    cmp #3
    jeq gameover_VBI
game_VBI
    ; game screen and RIP screen (StateFlag=1 or 2) - set DLI
    ; over horizon
    ; PMG horizontal coordinates and sizes
    ldx #$0c
@   lda HPOSP0_u,x
    sta HPOSP0,x
    dex
    bpl @-
    ; fly birds
    jsr FlyBirds
    ; fly clouds
    jsr FlyClouds
    ;
    jmp common_VBI

titles_VBI
    ; title screen (StateFlag=0) - set DLI
    ; over horizon
    ; PMG horizontal coordinates and sizes
    ldx #$0c
@   lda HPOSP0_u,x
    sta HPOSP0,x
    dex
    bpl @-
    ; fly clouds
    jsr FlyClouds
    ; different clouds color
    sec
    lda GameColors+c_clouds
    sta PCOLR2
    sta PCOLR3
    ;
    jsr CreditsAnimate
    ;
    jmp common_VBI
gameover_VBI
    ; game over screen (StateFlag=3) - set DLI
    ; over horizon
    ; PMG horizontal coordinates and sizes
    ldx #$0c
@   lda HPOSP0_u,x
    sta HPOSP0,x
    dex
    bpl @-
    ; fly clouds
    jsr FlyClouds
    ;
    ;jmp common_VBI

common_VBI
    ; NTSC speed correction
    lda PAL
    and #%00001110
    beq is_PAL
    inc NTSCCounter
    lda NTSCCounter
    cmp #6
    bne is_PAL
    mva #0 NTSCCounter
    jmp VBI_end
is_PAL

    lda StateFlag
    cmp #1
    bne wait_for_timer
    ; only during game
    ; power down
    dec PowerTimer
    bne wait_for_timer
    ; one bar down
    mva PowerDownSpeed PowerTimer
    jsr PowerDown
wait_for_timer

    bit RMT_blocked
    bmi SkipRMTVBL
    ; ------- RMT -------
    lda sfx_effect
    bmi lab2
    asl @                       ; * 2
    tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
    ldx #0                     ;X = 0          channel (0..3 or 0..7 for stereo module)
    lda #0                      ;A = 0          note (0..60)
    jsr RASTERMUSICTRACKER+15   ;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)
    lda #$ff
    sta sfx_effect              ;reinit value
lab2
    jsr RASTERMUSICTRACKER+3    ;1 play
    ; ------- RMT -------
SkipRMTVBL

VBI_end
    ; key release flag
    lda LastKey
    cmp #$ff
    beq key_released
    jsr GetKeyFast
    cmp LastKey
    beq last_key_still_press
    mva #$ff LastKey
last_key_still_press
key_released
    jmp XITVBV
.endp

;--------------------------------------------------
.proc FlyBirds
;--------------------------------------------------
    ; Birds fly and animation VBI procedure
    lda birdsHpos
    bne fly_birds
    ; if no birds then randomize new birds start
    lda RANDOM
    and #%11111100  ;   1:64
    bne no_birds
    ; new birds
    mva RANDOM birds_order  ; randomize birds order
    jsr PrepareBirdsPM  ; new birds position
    jmp no_birds
fly_birds
    lda RTCLOK+2
    and #%00000011
    bne no_wings_change
    inc birdsHpos
    lda birdsHpos
    bit birds_order
    bmi reverse_b_order
    sta HPOSP0_u
    clc
    adc #6
    sta HPOSP1_u
    bne new_b_h_pos ; always
reverse_b_order
    sta HPOSP1_u
    clc
    adc #6
    sta HPOSP0_u
new_b_h_pos
    ; wings
    lda birdsHpos
    and #%00000011
    bne no_wings_change
    lda birdsHpos
    and #%00000100
    bne wings_phase_a
    jsr PrepareBirdsPM.bird_b
    jmp no_wings_change
wings_phase_a
    jsr PrepareBirdsPM.bird_a
no_wings_change    
no_birds
    rts
.endp
;--------------------------------------------------
.proc FlyClouds
;--------------------------------------------------
    ; Clouds fly and animation VBI procedure
    lda RTCLOK+2
    and #%00000111
    bne no_clouds_change
    ; fly clouds
    lda clouds1Hpos
    bne cloud1_fly
    ; if no cloud 1 then randomize new cloud 2 start
    lda RANDOM
    and #%11111000  ;   1:32
    bne no_new_cloud1
    ; then create new cloud 1 shape
    jsr PrepareCloudsPM.make_cloud1
    mva #$de clouds1Hpos
cloud1_fly
    dec clouds1Hpos
    lda clouds1Hpos
    clc
    sta HPOSM2_u
    adc #4
    sta HPOSP2_u
    adc #8
    sta HPOSP3_u
    adc #8
    sta HPOSM3_u
    
no_new_cloud1
    lda clouds2Hpos
    bne cloud2_fly
    ; if no cloud 2 randomize new cloud 2 start
    lda RANDOM
    and #%11111000  ;   1:32
    bne no_new_cloud2
    ; then create new cloud 2 shape
    jsr PrepareCloudsPM.make_cloud2
    mva #$de clouds2Hpos
cloud2_fly
    dec clouds2Hpos
no_new_cloud2
    lda clouds3Hpos
    bne cloud3_fly
    ; if no cloud 3 then randomize new cloud 3 start
    lda RANDOM
    and #%11111000  ;   1:32
    bne no_new_cloud3
    ; then create new cloud 3 shape
    jsr PrepareCloudsPM.make_cloud3
    mva #$de clouds3Hpos
cloud3_fly
    dec clouds3Hpos
no_new_cloud3
no_clouds_change
    rts
.endp
;--------------------------------------------------
.proc CreditsClear
;--------------------------------------------------
    ldx #80
    lda #0
@   sta credits_lines,x
    dex
    bpl @-
    sta credit_nr
    sta credits_anim_counter
    rts
.endp
;--------------------------------------------------
.proc CreditsAnimate
;--------------------------------------------------
    lda credits_anim_counter
    cmp #40
    bcs static_display
    ; lets animate
    ; first move existing characters
    ldx #38
@   lda credits_lines,x
    sta credits_lines+1,x
    lda credits_lines+40,x
    sta credits_lines+42,x
    dex
    bpl @-
    ; and now write new characters to screen
    ; credit text addres calculate
    mwa #credits_texts VBItemp
    ldx credit_nr
    beq write_chars
@   adw VBItemp #80
    dex
    bne @-
write_chars
    ; first line
    lda #39
    sec
    sbc credits_anim_counter
    tay
    lda (VBItemp),y
    sta credits_lines
    ; second line
    lda credits_anim_counter
    cmp #20
    bcs no_spaces
    ; first half of second credits line - spaces
    lda #0
    sta credits_lines+40
    sta credits_lines+41
    beq static_display
no_spaces
    ; second half of second credits line
    lda #39
    sec
    sbc credits_anim_counter
    asl
    clc
    adc #40
    tay
    lda (VBItemp),y
    sta credits_lines+40
    iny
    lda (VBItemp),y
    sta credits_lines+41
    
static_display
    inc credits_anim_counter
    lda credits_anim_counter
    cmp #200
    bne no_next_credit
next_credit
    inc credit_nr
    lda credit_nr
    cmp #number_of_credits
    bne no_credits_loop
    mva #0 credit_nr
no_credits_loop
    mva #0 credits_anim_counter
no_next_credit
    rts
.endp
;--------------------------------------------------
.proc NoDLI
;--------------------------------------------------
    rti
.endp
;--------------------------------------------------
.proc TitlesDLI1
; Clouds, color changes
;--------------------------------------------------
    pha
    :3 sta WSYNC
    mva #$70 HPOSP0
    mva #$7a HPOSP1
    mva GameColors+c_logo4 COLPF2
    mva GameColors+c_font2 COLPM0
    sta COLPM1
    lda #0
    sta SIZEP0
    mwa #TitlesDLI1.DLI2 VDSLST
    pla
    rti
DLI2
    pha
    :5 sta WSYNC
    mva GameColors+c_logo2 COLPF1
    mva GameColors+c_logo4 COLPM1
    mwa #TitlesDLI1.DLI3 VDSLST
    pla
    rti
DLI3
    pha
    mva GameColors+c_logo1 COLPM0
    :7 sta WSYNC
    mva GameColors+c_buckle COLPF2
    mwa #TitlesDLI1.DLI4 VDSLST
    pla
    rti
DLI4
    pha
    ; set cloud 2 horizontal position
    lda clouds2Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    mva GameColors+c_logo1 COLPF2
    mva #$70 HPOSP0
    mva #$03 SIZEP0
    mva GameColors+c_font2 COLPM0
    :2 sta WSYNC
    mva GameColors+c_logo3 COLPF1
    :3 sta WSYNC
    mva GameColors+c_font2 COLPF2
    mwa #TitlesDLI1.DLI5 VDSLST
    pla
    rti
DLI5
    pha
    sta WSYNC
    mva GameColors+c_logo4 COLPF2
    mva GameColors+c_logo5 COLPM1
    mva #$70 HPOSP1
    mva #$03 SIZEP1
    mwa #TitlesDLI1.DLI6 VDSLST
    pla
    rti
DLI6
    pha
    :3 sta WSYNC
    mva GameColors+c_logo2 COLPF1
    :2 sta WSYNC
    mva GameColors+c_logo5 COLPF2    
    :2 sta WSYNC
    mva GameColors+c_logo1 COLPF2    
    mwa #TitlesDLI1.DLI7 VDSLST
    pla
    rti
DLI7
    pha
    ; set cloud 3 horizontal position
    lda clouds3Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    ; no cloud 3 !
/*     lda #0
    sta HPOSM2
    sta HPOSP2
    sta HPOSP3
    sta HPOSM3     */
    ; timberman initial colors
    mva GameColors+c_black COLPF0
    mva GameColors+c_light_brown COLPF1
    mva GameColors+c_hat COLPF2
    mva GameColors+c_white2 COLPF3
    mwa #TitlesDLI1.DLI8 VDSLST
    pla
    rti
DLI8
    pha
    ; timberman DLI1
    mva GameColors+c_shirtB COLPF2
    ; mva #0 COLBAK - for test
    mwa #TitlesDLI1.DLI9 VDSLST
    pla
    rti
DLI9
    pha
    ; font for titles and timberman
    mva #>font_titles CHBASE
    mwa #TitlesDLI1.DLI10 VDSLST
    pla
    rti
DLI10
    pha
    ; font for titles
    ;mva #>font_titles CHBASE
    :7 sta WSYNC
    mva GameColors+c_horizonA COLBAK ; thin line
    sta WSYNC
    mva GameColors+c_horizonB COLBAK ; additional lines
    sta WSYNC
    sta WSYNC
    mva GameColors+c_grass COLBAK ; green
    ; under horizon
    ; titles font colors
    mva GameColors+c_font4 COLPF0
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2
    mva GameColors+c_font3 COLPF3
    ; PMG colors, horizontal coordinates and sizes
    txa
    pha
    lda #0  ; hide PMG
    ldx #$15
@   sta HPOSP0,x
    dex
    bpl @-
    pla
    tax
    inc SyncByte
    mwa #TitlesDLI1.DLI_L1 VDSLST
    pla
    rti
DLI_L1
    pha
    mva GameColors+c_font4 COLPF0
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2
    :12 sta WSYNC
    mva GameColors+c_font5 COLPF2
    mwa #TitlesDLI1.DLI_L2 VDSLST
    pla
    rti
DLI_L2
    pha
    mva GameColors+c_font4 COLPF0
    mva GameColors+c_font1b COLPF1
    mva GameColors+c_font2b COLPF2
    :12 sta WSYNC
    mva GameColors+c_font5b COLPF2
    mwa #TitlesDLI1.DLI_L1 VDSLST ; tricky
    pla
    rti
.endp
;--------------------------------------------------
.proc GameOverDLI1
; Clouds, color changes
;--------------------------------------------------
    pha
    ; set cloud 2 horizontal position
    lda clouds2Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    mwa #GameOverDLI1.DLI2 VDSLST
    pla
    rti
DLI2
    pha
    ; set cloud 3 horizontal position
    lda clouds3Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    mwa #GameOverDLI1.DLI3 VDSLST
    pla
    rti
DLI3
    pha
    ; under horizon
    ; PMG colors, horizontal coordinates and sizes
    txa
    pha
    lda #0  ; hide PMG
    ldx #$15
@   sta HPOSP0,x
    dex
    bpl @-
    pla
    tax
    inc SyncByte
    pla
    rti
.endp
;--------------------------------------------------
.proc IngameDLI1
; Clouds, birds, color changes
;--------------------------------------------------
    pha
    mva GameColors+c_white COLPF2 ; white (numbers and letters)
    ; set cloud 2 horizontal position
    lda clouds2Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    mwa #IngameDLI1.DLI2 VDSLST
    pla
    rti
DLI2
    pha
    ; set cloud 3 horizontal position
    lda clouds3Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    mwa #IngameDLI1.DLI3 VDSLST
    pla
    rti
DLI3
    pha
    sta WSYNC
    mva LowCharsetBase CHBASE
    mva GameColors+c_horizonA COLBAK ; thin line
    mva GameColors+c_light_brown COLPF3 ; light brown
    sta WSYNC
    mva GameColors+c_horizonB COLBAK ; additional lines
    sta WSYNC
    sta WSYNC
    mva GameColors+c_grass COLBAK ; green
    ; under horizon
    ; PMG colors, horizontal coordinates and sizes
    txa
    pha
    ldx #$15
@   lda HPOSP0_d,x
    sta HPOSP0,x
    dex
    bpl @-
    pla
    tax
    inc SyncByte
    mwa #IngameDLI1.DLI4 VDSLST
    pla
    rti
DLI4
    pha
    sta WSYNC
    mva GameColors+c_hat COLPF2 ; hat
    :4 STA WSYNC
    mva GameColors+c_white COLPF2 ; white
    mwa #IngameDLI1.DLI5 VDSLST
    pla
    rti
DLI5
    pha
    lda StateFlag
    sta WSYNC
    cmp #1  ; game
    bne @+
    mva GameColors+c_buckle COLPF2 ; button and buckle
@   mva #>font_game_upper CHBASE
    mwa #IngameDLI1.DLI6 VDSLST
    pla
    rti
DLI6
    pha
    lda StateFlag
    cmp #1  ; game
    bne @+
    sta WSYNC
    sta WSYNC
    sta WSYNC
    mva GameColors+c_pants COLPF2 ; blue pants
@   pla
    rti
.endp
;--------------------------------------------------
main
;--------------------------------------------------
    jsr WaitForKeyRelease
    jsr MakeDarkScreen
    jsr PAL_NTSC
    jsr initialize
GameStart
    RMTsong song_main_menu
    jsr StartScreen
    RMTSong song_ingame
    jsr ScoreClear
gameloop
    jsr MakeDarkScreen
    jsr LevelScreen
    jsr PlayLevel
    ;jsr NextLevel
    ; RMTSong song_ingame
    jsr AudioInit   ; after I/O
    jmp gameOver
EndOfLife
    ;dec Lives   ; decrease Lives
    ;lda Lives
    ;cmp #"0"
    ;beq gameOver    ; if no lives - game over
    ;jsr NextLife
    jmp gameOver
gameOver
    ;game over
    ;RMTSong song_game_over 
    ;jsr HiScoreCheckWrite
    jsr GameOverScreen
    jmp GameStart
;--------------------------------------------------
.proc StartScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    jsr HidePM
    jsr PrepareTitlePM
    jsr CreditsClear
    mva #0 StateFlag
    mva #>font_logo CHBAS
    mwa #dl_title dlptrs
    mva GameColors+c_sky COLBAKS
    mva GameColors+c_white2 COLOR0
    mva GameColors+c_logo3 COLOR1
    mva GameColors+c_font2 COLOR2
    lda #@dmactl(standard|dma|missiles|players|lineX2)  ; normal screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
difficulty_display
    lda Difficulty
    bne level_easy
    mwa #difficulty_normal_text difficulty_text_DL
    mwa #PowerSpeedTableA SpeedTableAdr     ; difficulty level normal
    jmp wait_for_key
level_easy
    mwa #difficulty_easy_text difficulty_text_DL
    mwa #PowerSpeedTableB SpeedTableAdr     ; difficulty level easy
wait_for_key
    pause 1
StartLoop
    jsr GetKey
    cmp #@kbcode._left
    beq leftkey
    cmp #@kbcode._right
    bne notdirectionskeys
leftkey
    lda Difficulty
    eor #$01
    sta Difficulty
    jmp difficulty_display
notdirectionskeys
EndOfStartScreen
    rts
.endp
;--------------------------------------------------
.proc LevelScreen
;--------------------------------------------------
    jsr MakeDarkScreen

    mva #>font_game_upper CHBAS
    mva #>font_game_lower_right LowCharsetBase
    mva GameColors+c_black PCOLR0 ; = $02C0 ;- - rejestr-cień COLPM0
    mva GameColors+c_black COLOR0
    mva GameColors+c_sky COLBAKS ; sky
    mva GameColors+c_dark_brown COLOR1 ; dark brown
    mva GameColors+c_red COLOR2 ; red
    mva GameColors+c_light_brown COLOR3 ; light brown
    
    mva #$00 birds_order    ; standard birds order
    jsr LevelReset
    jsr InitBranches
    jsr draw_branches
    mva #24 PowerValue  ; half power
    mva #1 PowerTimer   ; reset timer ( 1, not 0! )
    jsr draw_PowerBar
    mva #1 LumberjackDir    ; right side
    mwa #gamescreen_r_ph1p1 animation_addr
    mwa #last_line_r lastline_addr

    jsr PrepareLevelPM
    jsr PrepareBirdsPM
    jsr PrepareCloudsPM
    mwa #dl_level dlptrs
    lda #@dmactl(narrow|dma|missiles|players|lineX2)  ; narrow screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
    jsr SetPMr1
    mva #1 StateFlag
    pause 5
    rts
.endp
;--------------------------------------------------
.proc GameOverScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    jsr PrepareTitlePM.clearP0_1
    jsr HidePM
    mva #3 StateFlag
    mva #>font_titles CHBAS
    mwa #dl_over dlptrs
    mva GameColors+c_sky COLBAKS
    mva GameColors+c_font4 COLOR0
    mva GameColors+c_font1 COLOR1
    mva GameColors+c_font2 COLOR2
    mva GameColors+c_font3 COLOR3
    lda #@dmactl(standard|dma|missiles|players|lineX2)  ; normal screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
    pause 1
OverLoop
    jsr GetKey
    cmp #@kbcode._space
    bne OverLoop
EndOfOverScreen
    rts
.endp
;--------------------------------------------------
.proc MakeDarkScreen
;--------------------------------------------------
    mva #0 dmactls             ; dark screen
    ; and wait one frame :)
    pause 1
    rts
.endp
;--------------------------------------------------
.proc PlayLevel
;--------------------------------------------------
    jsr PrepareLevelPM
loop
    ; PUT GAME HERE
    lda branches_list+5
    cmp LumberjackDir    ; branch and Lumberjack ?
    jeq LevelDeath
    lda LastKey
    cmp #$ff
    beq key_released_before
    bne No_keys
key_released_before
    jsr GetKeyFast
    cmp #@kbcode._left
    beq left_pressed
    cmp #@kbcode._right
    beq right_pressed
    ; other keys or no key
    cmp #@kbcode._up
    bne NoNextLevel
    ; next level if joy UP
    sta LastKey
    jsr LevelUp
NoNextLevel
No_keys
    lda PowerValue
    jeq LevelDeath
    jmp loop
right_pressed
    sta LastKey
    mva #sfx_ciach sfx_effect
/*  
    ; test for right lower branch
    lda branches_list+5
    cmp #1
    bne no_r_branch
    ; death by lower right branch
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    WaitForSync
    mwa #gamescreen_r_ph1p1 animation_addr
    mva #1 LumberjackDir    ; right side
    bne LevelDeath
no_r_branch
*/ 
    jsr ScoreUp
    jsr PowerUp
    jsr SetPMr1
    lda branches_list+4  ; check branch over 
    beq no_brancho_r
    ; branch over lumberjack
    cmp #1  ; right branch (kill)
    bne no_kill_r
    jsr AnimationR4
    jmp go_loop    
no_kill_r
     ; left branch
    jsr AnimationR7
    jmp go_loop    
no_brancho_r
    ; no branch over lumberjack
    jsr AnimationR1
    jmp go_loop
left_pressed
    sta LastKey
    mva #sfx_ciach sfx_effect
/* 
    ; test for left lower branch
    lda branches_list+5
    cmp #2
    bne no_l_branch
    ; death by lower left branch
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    WaitForSync
    mwa #gamescreen_l_ph1p1 animation_addr
    mva #2 LumberjackDir    ; left side
    bne LevelDeath
no_l_branch
*/
    jsr ScoreUp
    jsr PowerUp
    jsr SetPMl1
    lda branches_list+4  ; check branch over
    beq no_brancho_l
    ; branch over lumberjack
    cmp #2  ; left branch (kill)
    bne no_kill_l
    jsr AnimationL4
    jmp go_loop 
no_kill_l
    ; right branch
    jsr AnimationL7
    jmp go_loop    
no_brancho_l
    ; no branch over lumberjack
    jsr AnimationL1
    jmp go_loop
LevelDeath
    jsr SetRIPscreen
    RMTsong song_game_over
@   
    jsr GetKey
    cmp #@kbcode._space
    bne @-
    ; restart game
    rts
go_loop
    jmp loop
.endp   

;--------------------------------------------------
    icl 'art/animations.asm'
;--------------------------------------------------
;--------------------------------------------------
.proc SetRIPscreen
;--------------------------------------------------
    :5 WaitForSync
    mva #2 StateFlag
    mva #>font_game_rip LowCharsetBase
    jsr HidePM
    jsr PrepareRIPPM
    lda LumberjackDir    ; RIP direction
    cmp #1
    bne leftRIP
    mwa #last_line_RIP_r lastline_addr
    jsr SetPMr_RIP
    jmp afterLastLine
leftRIP
    mwa #last_line_RIP_l lastline_addr
    jsr SetPMl_RIP
afterLastLine
    lda LumberjackDir    ; branch and Lumberjack ?
    cmp branches_list+5
    beq BranchDeath
    ;no branch death
    cmp #1
    bne leftside
    ; right death
    lda branches_list+5
    beq no_branch_r
    ; left side branch
    mwa #RIPscreen_r_Lbranch animation_addr
    rts
no_branch_r    
    mwa #RIPscreen_r_nobranch animation_addr
    rts
leftside
    ; right death
    lda branches_list+5
    beq no_branch_l
    ; right side branch
    mwa #RIPscreen_l_Rbranch animation_addr
    rts
no_branch_l   
    mwa #RIPscreen_l_nobranch animation_addr
    rts    
BranchDeath
    cmp #1
    bne leftbranch
    ; right branch
    mwa #RIPscreen_r_branch animation_addr
    rts
leftbranch
    mwa #RIPscreen_l_branch animation_addr
    rts
.endp
;--------------------------------------------------
.proc SetLumberjackPosition
;--------------------------------------------------
    WaitForSync
    lda LumberjackDir
    cmp #1
    beq right_side
left_side
    jsr SetPMl1
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    lda branches_list+5
    cmp #1
    bne no_branch_r
    mwa #gamescreen_l_ph1p2 animation_addr
    rts
no_branch_r    
    mwa #gamescreen_l_ph1p1 animation_addr
    rts
right_side
    jsr SetPMr1
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    lda branches_list+5
    cmp #2
    bne no_branch_l
    mwa #gamescreen_r_ph1p2 animation_addr
    rts
no_branch_l
    mwa #gamescreen_r_ph1p1 animation_addr
    rts
.endp
;--------------------------------------------------
.proc AudioInit
;--------------------------------------------------
    ; pokeys init
    lda #3
    sta skctl ; put Pokey into Init
    sta skctl+$10
    ldx #8
    lda #0
@   
      sta $D200,x ; clear all voices, set AUDCTL to 00
      sta $D210,x ; clear all voices, set AUDCTL to 00
      dex
    bpl @-
    rts
.endp

;--------------------------------------------------
.proc RestoreRedBar
;--------------------------------------------------
    mva GameColors+c_red COLOR2 ; red
    rts
.endp
;--------------------------------------------------
.proc initialize
;--------------------------------------------------
     
    mva #>font_game_upper CHBAS
    mva #>font_game_lower_right LowCharsetBase
    mva GameColors+c_black PCOLR0 ; = $02C0 ;- - rejestr-cień COLPM0

    mva GameColors+c_black COLOR0
    mva GameColors+c_sky COLBAKS ; sky
    mva GameColors+c_dark_brown COLOR1 ; dark brown
    mva GameColors+c_red COLOR2 ; red
    mva GameColors+c_light_brown COLOR3 ; light brown
    ;mva #$ff COLOR4

    ;clear P/M memory
    lda #0
    tax
@   sta PMmemory,x
    sta PMmemory+$100,x
    sta PMmemory+$200,x
    sta PMmemory+$300,x
    inx
    bne @-
    mva #>PMmemory PMBASE
    jsr HidePM
    mva #%00100100 GPRIOR
    mva #0 RMT_blocked
    
    lda #$ff
    sta sfx_effect

    JSR AudioInit

    jsr CreditsClear
    mva #$00 birds_order    ; standard birds order
    jsr LevelReset
    jsr InitBranches
    jsr draw_branches
    mva #24 PowerValue  ; half power
    mva #1 PowerTimer   ; reset timer ( 1, not 0! )
    jsr draw_PowerBar
    mva #1 LumberjackDir    ; right side
    mva #0 Difficulty       ; level normal
    
    jsr PrepareLevelPM
    jsr PrepareBirdsPM
    jsr PrepareCloudsPM
    jsr SetPMr1
    mwa #gamescreen_r_ph1p1 animation_addr
    lda #@dmactl(narrow|dma|missiles|players|lineX2)  ; narrow screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
    mwa #dl_level dlptrs
    ;vdli IngameDLI1
    mva #$ff RMT_blocked
                    
    ;VBI
    mva #0 NTSCCounter
    vmain vint,7
    
    mwa #PowerSpeedTableB SpeedTableAdr     ; difficulty level
    rts
.endp
;--------------------------------------------------
.proc HidePM
; hide P/M on right side of screen
;--------------------------------------------------
    lda #$e0
    ldx #$07 ; 8 registers. from HPOSP0_d to HPOSM3_d
@   sta HPOSP0_d,x
    ;sta HPOSP0_u,x
    sta HPOSP0,x
    dex
    ;sta birdsHpos
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc ClearLowerPM
;--------------------------------------------------
    ; clear PMG memory under horizon line
    ldx #90
    lda #0
@   sta PMmemory+$180,x
    sta PMmemory+$200,x
    sta PMmemory+$280,x
    sta PMmemory+$300,x
    sta PMmemory+$380,x
    inx
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc PrepareLevelPM
;--------------------------------------------------
    jsr ClearLowerPM
    ; Lumberjack shirt
    ldx #datalinesP2-1
@   lda P2_data,x
    sta PMmemory+$300+HoffsetP2,x
    lda P3_data,x
    sta PMmemory+$380+HoffsetP2,x
    lda M23_data,x
    sta PMmemory+$180+HoffsetP2,x
    dex
    bpl @-
    mva #1 SIZEP2_d
    sta SIZEP3_d
    lda #%01011111
    sta SIZEM_d
    mva GameColors+c_shirtA COLPM2_d
    mva GameColors+c_shirtB COLPM3_d
    ; Lumberjack hand
    ldx #datalinesP0-1
@   lda P0_data,x
    sta PMmemory+$200+HoffsetP0,x
    dex
    bpl @-
    mva #0 SIZEP0_d
    mva GameColors+c_hands COLPM0_d
    ; Lumberjack face
    ldx #datalinesM0-1
@   lda PMmemory+$180+HoffsetM0,x
    ora M0_data,x
    sta PMmemory+$180+HoffsetM0,x
    dex
    bpl @-
    ; Lumberjack second hand
    ldx #datalinesM1-1
@   lda PMmemory+$180+HoffsetM1,x
    ora M1_data,x
    sta PMmemory+$180+HoffsetM1,x
    dex
    bpl @-
    mva GameColors+c_hands COLPM1_d
    ; Lumberjack both hands
    ldx #datalinesP1-1
@   lda P1_data,x
    sta PMmemory+$280+HoffsetP1,x
    dex
    bpl @-
    mva #1 SIZEP1_d
    rts
; Lumberjack shirt data
P2_data
    .by $55,$55,$aa,$aa,$55,$55,$aa,$aa,$55,$55,$aa,$aa,$55,$55,$ff,$ff
P3_data
    .by $ff,$ff,$55,$55,$ff,$ff,$55,$55,$ff,$ff,$55,$55,$ff,$ff,$00,$00
M23_data
    .by $80,$80,$20,$20,$80,$80,$20,$20,$80,$80,$20,$20,$80,$80,$20,$20
HoffsetP2=97
datalinesP2=16
; Lumberjack hand data
P0_data
    .by %11111000
    .by %11111000
    .by %11111000
    .by %11111000
    .by %11111000
HoffsetP0=94
datalinesP0=5
; Lumberjack face data
M0_data
    .by %00000011
    .by %00000011
    .by %00000011
    .by %00000011
    .by %00000011
    .by %00000011
    .by %00000011
    .by %00000011
    .by %00000011
HoffsetM0=93
datalinesM0=9
; Lumberjack second hand data
M1_data
    .by %00001100
    .by %00001100
    .by %00001100
    .by %00001100
    .by %00001100
HoffsetM1=102
datalinesM1=5
; Lumberjack both hands data
P1_data
    .by %11101110
    .by %11101110
    .by %11101110
    .by %11101110
    .by %11101110
HoffsetP1=102
datalinesP1=5
.endp
;--------------------------------------------------
.proc PrepareRIPPM
;--------------------------------------------------
    jsr ClearLowerPM
    ; RIP
    ldx #datalinesP0-1
@   lda P0_data,x
    sta PMmemory+$200+HoffsetP0,x
    dex
    bpl @-
    mva #1 SIZEP0_d
    mva GameColors+c_greyRIP COLPM0_d
    rts
; RIP data
P0_data
    .by %00111110
    .by %01111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
    .by %11111111
HoffsetP0=101
datalinesP0=17
.endp
;--------------------------------------------------
.proc PrepareBirdsPM
;--------------------------------------------------
    ; bird 2, 1 and 3
    ; hoffset (16 - 40) - (all) birds hsize - 28
    randomize 16 40
    sta birdsOffset
    jsr PrepareTitlePM.clearP0_1_sky
    jsr bird_a
    mva #0 SIZEP0_u
    sta SIZEP1_u
    mva GameColors+c_birds PCOLR0
    sta PCOLR1
    lda #1
    sta birdsHpos
    sta HPOSP0_u
    sta HPOSP1_u

    rts
bird_a
    ldx #datalines_bird-1
    lda birdsOffset
    clc
    adc #datalines_bird
    tay
@   lda bird_data_a,x
    sta PMmemory+$200+Hoffset_bird2,y
    sta PMmemory+$280+Hoffset_bird1,y
    sta PMmemory+$280+Hoffset_bird3,y
    dey
    dex
    bpl @-
    rts
bird_b
    ldx #datalines_bird-1
    lda birdsOffset
    clc
    adc #datalines_bird
    tay
@   lda bird_data_b,x
    sta PMmemory+$200+Hoffset_bird2,y
    sta PMmemory+$280+Hoffset_bird1,y
    sta PMmemory+$280+Hoffset_bird3,y
    dey
    dex
    bpl @-
    rts
; bird data
bird_data_a
  dta $00, $00, $00, $3f, $7c, $18, $18, $08
bird_data_b
  dta $00, $30, $18, $18, $3f, $7c, $00, $00
Hoffset_bird1=0
Hoffset_bird2=10
Hoffset_bird3=20
datalines_bird=8
.endp
;--------------------------------------------------
.proc PrepareCloudsPM
;--------------------------------------------------
    ; 3 clouds
    ; 1 - vertical offset in PM from 5 (first byte) to 19 (last byte)
    ; 2 - vertical offset in PM from 20 (first byte) to 35 (last byte)
    ; 3 - vertical offset in PM from 36 (first byte) to 84 (last byte)
    ; cloud
    jsr make_cloud1
    jsr make_cloud2
    jsr make_cloud3
    mva #0 SIZEP2_u
    sta SIZEP3_u
    lda #%01010101
    sta SIZEM_u
    mva GameColors+c_clouds PCOLR2
    sta PCOLR3
    lda #36
    sta clouds2Hpos
    lda #98
    sta clouds1Hpos
    
    clc
    sta HPOSM2_u
    adc #4
    sta HPOSP2_u
    adc #8
    sta HPOSP3_u
    adc #8
    sta HPOSM3_u
    rts
make_cloud1
    ; clear cloud 1 PMG memory 
    ldx #(19-5)
    lda #0
@   sta PMmemory+$300+5,x
    sta PMmemory+$380+5,x
    sta PMmemory+$180+5,x
    dex
    bpl @-
    randomize 0 (19-5-datalines_clouds)
    adc #(datalines_clouds-1+5)
    tay
    lda RANDOM
    and #%00000011
    clc
    adc #4  ; (4 to 7 = shapes 5 to 8)
    bne fill_cloud
make_cloud2
    ; clear cloud 2 PMG memory 
    ldx #(35-20)
    lda #0
@   sta PMmemory+$300+20,x
    sta PMmemory+$380+20,x
    sta PMmemory+$180+20,x
    dex
    bpl @-
    randomize 0 (35-20-datalines_clouds)
    adc #(datalines_clouds-1+20)
    tay
    lda RANDOM
    and #%00000011
    clc
    adc #2  ; (2 to 5 = shapes 3 to 6)
    bne fill_cloud
make_cloud3
    ; clear cloud 3 PMG memory 
    ldx #(84-36)
    lda #0
@   sta PMmemory+$300+36,x
    sta PMmemory+$380+36,x
    sta PMmemory+$180+36,x
    dex
    bpl @-
    randomize 0 (51-36-datalines_clouds)
    adc #(datalines_clouds-1+36)
    tay
    lda RANDOM
    and #%00000011  ; (0 to 3 = shapes 1 to 4)
    ; fill cloud PMG memory
fill_cloud
    ldx #datalines_clouds-1
    and #%00000111
    bne not_shape_1
    ; shape1
@   lda cloud1_P2,x
    sta PMmemory+$300,y
    lda cloud1_P3,x
    sta PMmemory+$380,y
    lda cloud1_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_1
    cmp #1
    bne not_shape_2
    ; shape 2
@   lda cloud2_P2,x
    sta PMmemory+$300,y
    lda cloud2_P3,x
    sta PMmemory+$380,y
    lda cloud2_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_2
    cmp #2
    bne not_shape_3
    ; shape 3
@   lda cloud3_P2,x
    sta PMmemory+$300,y
    lda cloud3_P3,x
    sta PMmemory+$380,y
    lda cloud3_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_3
    cmp #3
    bne not_shape_4
    ; shape 4
@   lda cloud4_P2,x
    sta PMmemory+$300,y
    lda cloud4_P3,x
    sta PMmemory+$380,y
    lda cloud4_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_4
    cmp #4
    bne not_shape_5
    ; shape 5
@   lda cloud5_P2,x
    sta PMmemory+$300,y
    lda cloud5_P3,x
    sta PMmemory+$380,y
    lda cloud5_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_5
    cmp #5
    bne not_shape_6
    ; shape 6
@   lda cloud6_P2,x
    sta PMmemory+$300,y
    lda cloud6_P3,x
    sta PMmemory+$380,y
    lda cloud6_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_6
    cmp #6
    bne not_shape_7
    ; shape 7
@   lda cloud7_P2,x
    sta PMmemory+$300,y
    lda cloud7_P3,x
    sta PMmemory+$380,y
    lda cloud7_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
not_shape_7
    ; shape 8
@   lda cloud8_P2,x
    sta PMmemory+$300,y
    lda cloud8_P3,x
    sta PMmemory+$380,y
    lda cloud8_M,x
    sta PMmemory+$180,y
    dey
    dex
    bpl @-
    rts
; clouds data
; shapes 1 to 8 for clouds
; player 2
cloud1_P2
    .by $00,$00,$00,$00,$00,$00,$00,$00,$08,$1D,$3F,$3F
cloud2_P2
    .by $00,$00,$00,$00,$00,$00,$00,$00,$07,$1F,$3F,$FF
cloud3_P2
    .by $00,$00,$00,$00,$00,$00,$00,$38,$7D,$FF,$FF,$FF
cloud4_P2
    .by $00,$00,$00,$00,$00,$00,$0E,$1F,$1F,$7F,$FF,$FF
cloud5_P2
    .by $00,$00,$00,$00,$00,$00,$01,$73,$FF,$FF,$FF,$FF
cloud6_P2
    .by $00,$00,$00,$00,$00,$3E,$FF,$FF,$FF,$FF,$FF,$7C
cloud7_P2
    .by $00,$00,$01,$03,$77,$FF,$FF,$FF,$FF,$FF,$07,$01
cloud8_P2
    .by $00,$0F,$1F,$BF,$FF,$FF,$FF,$FF,$FF,$FF,$1F,$07
; player 3
cloud1_P3
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$E0,$F8
cloud2_P3
    .by $00,$00,$00,$00,$00,$00,$00,$00,$80,$DC,$FE,$FF
cloud3_P3
    .by $00,$00,$00,$00,$00,$00,$00,$C0,$F0,$FC,$FE,$FF
cloud4_P3
    .by $00,$00,$00,$00,$00,$00,$30,$78,$78,$FB,$FF,$FF
cloud5_P3
    .by $00,$00,$00,$00,$00,$00,$C0,$F6,$FF,$FF,$FF,$FF
cloud6_P3
    .by $00,$00,$00,$00,$00,$00,$7C,$FF,$FF,$FF,$FF,$FF
cloud7_P3
    .by $00,$00,$F0,$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$F8
cloud8_P3
    .by $0F,$1F,$BF,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$C0,$80
; missiles
cloud1_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
cloud2_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
cloud3_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$30
cloud4_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$90
cloud5_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$B0,$F0
cloud6_M
    .by $00,$00,$00,$00,$00,$00,$10,$30,$B0,$B0,$90,$00
cloud7_M
    .by $00,$00,$00,$80,$C0,$C0,$D0,$F0,$F0,$80,$00,$00
cloud8_M
    .by $00,$80,$80,$D0,$F0,$F0,$F0,$F0,$B0,$10,$00,$00


datalines_clouds=12
.endp
;--------------------------------------------------
.proc PrepareTitlePM
;--------------------------------------------------
    ; logo PM and other title screen PN (without clouds)
    jsr clearP0_1
    jsr logoPM
    mva #1 SIZEP0_u
    sta SIZEP1_u
    mva GameColors+c_logo4 PCOLR0
    sta PCOLR1
    lda #$58
    sta HPOSP0_u
    lda #$98
    sta HPOSP1_u

    rts
clearP0_1
    ldx #$7f
    bne go_clear
clearP0_1_sky
    ldx #$53
go_clear
    lda #$00
@   sta PMmemory+$200,x
    sta PMmemory+$280,x
    dex
    bpl @-
    rts
logoPM
    ldx #datalines_logo-1
@   lda logo_data_a,x
    sta PMmemory+$200+Hoffset_logo,x
    lda logo_data_b,x
    sta PMmemory+$280+Hoffset_logo,x
    dey
    dex
    bpl @-
    rts
; logo data
logo_data_a
    dta %11111111
    dta %11111111
    ; DLI
    dta %11111111
    dta %11111111
    dta %11111111
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00011100
    dta %00001000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %11111111
    dta %11111111
    dta %11111111
    dta %00000000
    dta %00000000
    dta %00000000
logo_data_b
    dta %11111111
    dta %11111111
    ; DLI
    dta %11111111
    dta %11111111
    dta %11111111
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %11111111
    dta %11111111
    dta %11111111
Hoffset_logo=12
datalines_logo=23
.endp
;--------------------------------------------------
.proc SetPMl1
;--------------------------------------------------
    mva #$4f HPOSP2_d
    sta HPOSP3_d
    mva #$5f HPOSM2_d
    sta HPOSM3_d
    mva #$4c HPOSP0_d
    mva #$54 HPOSM0_d
    mva #$4c HPOSM1_d
    mva #$e0 HPOSP1_d ; hide
    rts
.endp
;--------------------------------------------------
.proc SetPMr1
;--------------------------------------------------
    mva #$9f HPOSP2_d
    sta HPOSP3_d
    mva #$af HPOSM2_d
    sta HPOSM3_d
    mva #$af HPOSP0_d
    mva #$a4 HPOSM0_d
    mva #$ac HPOSM1_d
    mva #$e0 HPOSP1_d ; hide
    rts
.endp
;--------------------------------------------------
.proc SetPMl2
;--------------------------------------------------
    mva #$4f HPOSP2_d
    sta HPOSP3_d
    mva #$5f HPOSM2_d
    sta HPOSM3_d
    mva #$e0 HPOSP0_d ; hide
    mva #$55 HPOSM0_d
    mva #$e0 HPOSM1_d ; hide
    mva #$50 HPOSP1_d
    rts
.endp
;--------------------------------------------------
.proc SetPMr2
;--------------------------------------------------
    mva #$9f HPOSP2_d
    sta HPOSP3_d
    mva #$af HPOSM2_d
    sta HPOSM3_d
    mva #$e0 HPOSP0_d ; hide
    mva #$a3 HPOSM0_d
    mva #$e0 HPOSM1_d ; hide
    mva #$a2 HPOSP1_d
    rts
.endp
;--------------------------------------------------
.proc SetPMl3
;--------------------------------------------------
    mva #$4f HPOSP2_d
    sta HPOSP3_d
    mva #$5f HPOSM2_d
    sta HPOSM3_d
    mva #$e0 HPOSP0_d ; hide
    mva #$54 HPOSM0_d
    mva #$56 HPOSM1_d
    mva #$5b HPOSP1_d
    rts
.endp
;--------------------------------------------------
.proc SetPMr3
;--------------------------------------------------
    mva #$9f HPOSP2_d
    sta HPOSP3_d
    mva #$af HPOSM2_d
    sta HPOSM3_d
    mva #$e0 HPOSP0_d ; hide
    mva #$a4 HPOSM0_d
    mva #$a2 HPOSM1_d
    mva #$97 HPOSP1_d
    rts
.endp
;--------------------------------------------------
.proc SetPMl_RIP
;--------------------------------------------------
    mva #$4f HPOSP0_d
    rts
.endp
;--------------------------------------------------
.proc SetPMr_RIP
;--------------------------------------------------
    mva #$9f HPOSP0_d
    rts
.endp
;--------------------------------
; non ZP variables
;--------------------------------
branches_list
    .by 1,0,2,0,1,0 ; 
branches_anim_phase ; from 0 to 4
    .by 1
score
    dta d"0000"
level
    dta $1a, $1b, $1c, $1b, $1a, $A4
    dta d"1"
;--------------------------------------------------
.proc ScoreUp
;--------------------------------------------------
    inc score+3
    lda score+3
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+3
    inc score+2
    lda score+2
    cmp #"5"
    bne no_speed_power
    jsr PowerSpeedUP     ; every 50pts.
no_speed_power
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+2
    jsr PowerSpeedUP     ; every 50pts.
    jsr LevelUp ; every 100pts.
    inc score+1
    lda score+1
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+1
    inc score
ScoreReady
    rts
.endp
;--------------------------------------------------
.proc ScoreClear
;--------------------------------------------------
    lda #"0"
    ldx #3
@   sta score,x
    dex
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc ScoreToScreen
;--------------------------------------------------
    ldx #3
@   lda score,x
    sta screen_score,x
    dex
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc LevelToScreen
;--------------------------------------------------
    lda LevelValue
    clc
    adc #"0"
    sta screen_level+6
    ldx #5
@   lda level,x
    sta screen_level,x
    dex
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc LevelReset
;--------------------------------------------------
; set level to 1 and PowerDownSpeed to ??
    mvy #1 LevelValue
    dey
    sty PowerSpeedIndex
    lda (SpeedTableAdr),y
    sta PowerDownSpeed
    jsr LevelToScreen
    rts
.endp
;--------------------------------------------------
.proc LevelUp
;--------------------------------------------------
    inc LevelValue
    lda LevelValue
    cmp #10
    bne not_max_lev
    mva #9 LevelValue
not_max_lev
    jsr LevelToScreen
    rts
.endp
;--------------------------------------------------
.proc PowerSpeedUP
;--------------------------------------------------
    inc PowerSpeedIndex
    ldy PowerSpeedIndex
    lda (SpeedTableAdr),y
    sta PowerDownSpeed
    rts
.endp
;--------------------------------------------------
.proc PowerUp
;--------------------------------------------------
    mva GameColors+c_light_red COLOR2 ; light red
    inc PowerValue
    lda PowerValue
    cmp #49
    bne not_max_pwr
    mva #48 PowerValue
not_max_pwr
    jsr draw_PowerBar
    rts
.endp
;--------------------------------------------------
.proc PowerDown
;--------------------------------------------------
    dec PowerValue
    bpl not_min_pwr
    mva #0 PowerValue
not_min_pwr
    jsr draw_PowerBar
    rts
.endp
;--------------------------------------------------
.proc draw_PowerBar
;--------------------------------------------------
    lda PowerValue
    cmp #48
    bcc not_to_high
    mva #48 PowerValue
not_to_high
    tay
    and #%00000011
    clc
    adc #PowerChar0
    tax ; code of last char in bar
    tya
    :2 lsr  ; value/4   - number of full char in bar
    sta tempbyte
    ldy #0
    lda #PowerCharFull
draw_bar_loop
    cpy tempbyte
    bne not_last_bar_char
    ; last char in bar
    txa
    sta Power,y
    lda #PowerCharEmpty ; because next in bar chars are empty
    bne next_char
not_last_bar_char
    sta Power,y
next_char
    iny
    cpy #12
    bne draw_bar_loop
    rts
.endp
;--------------------------------------------------
.proc draw_branches
;--------------------------------------------------
    ; branch 0 (off-screen if phase 0)
draw_branch0
    lda branches_anim_phase
    beq draw_branch1
    tax
    ; this is partialy off-screen branch
    ; we must draw only visible lines
    ; now calculate start screen address
    lda #5
    sec
    sbc branches_anim_phase
    :5 asl  ; skippedlines*32
    tay ; to skip lines
    txa
    ; now calculate start screen address
    :5 asl  ; phase*32
    ;clc
    adc #<(gamescreen_middle-5*32)
    sta temp
    lda #>(gamescreen_middle-5*32)
    adc #0
    sta temp+1
    ldx branches_list ; branch0
    lda branch_addr_tableL,x
    sta temp2
    lda branch_addr_tableH,x
    sta temp2+1
    ; skiping off-screen lines    
    ; ldy #$00  ; we have value in Y
@   lda (temp2),y
    sta (temp),y
    iny
    cpy #(5*32) ;5 lines - skipped lines
    bne @-
draw_branch1
    lda branches_anim_phase
    ; now calculate start screen address
    :5 asl  ; phase*32
    ;clc
    adc #<gamescreen_middle
    sta temp
    lda #>gamescreen_middle
    adc #0
    sta temp+1
    ldy branches_list+1 ; branch1
    lda branch_addr_tableL,y
    sta temp2
    lda branch_addr_tableH,y
    sta temp2+1
    ldy #$00
@   lda (temp2),y
    sta (temp),y
    iny
    cpy #(5*32) ;5 lines
    bne @-
draw_branch2
    lda branches_anim_phase
    ; now calculate start screen address
    :5 asl  ; phase*32
    ;clc
    adc #<(gamescreen_middle+5*32)
    sta temp
    lda #>(gamescreen_middle+5*32)
    adc #0
    sta temp+1
    ldy branches_list+2 ; branch2
    lda branch_addr_tableL,y
    sta temp2
    lda branch_addr_tableH,y
    sta temp2+1
    ldy #$00
@   lda (temp2),y
    sta (temp),y
    iny
    cpy #(5*32) ;5 lines
    bne @-
    jsr ScoreToScreen
    jsr LevelToScreen
draw_branch3
    lda branches_anim_phase
    ldx #(5*32)     ; how many lines draw
    cmp #4
    bne not_phase4
    ldx #(4*32)     ; how many lines draw
not_phase4
    stx tempbyte
    ; now calculate start screen address
    :5 asl  ; phase*32
    ;clc
    adc #<(gamescreen_middle+10*32)
    sta temp
    lda #>(gamescreen_middle+10*32)
    adc #0
    sta temp+1
    ldy branches_list+3 ; branch3
    lda branch_addr_tableL,y
    sta temp2
    lda branch_addr_tableH,y
    sta temp2+1
    ldy #$00
@   lda (temp2),y
    sta (temp),y
    iny
    cpy tempbyte ;? lines
    bne @-
draw_branch4    
    lda branches_anim_phase
    ; draw only if phase 0 or 1 or 2
    cmp #3
    bcs all_drawed
    ldx #(3*32)     ; how many lines draw
    cmp #1
    bne not_phase1
    ldx #(2*32)     ; how many lines draw
not_phase1    
    cmp #2
    bne not_phase2
    ldx #(1*32)     ; how many lines draw
not_phase2    
    stx tempbyte
    ; now calculate start screen address
    :5 asl  ; phase*32
    ;clc
    adc #<(gamescreen_middle+15*32)
    sta temp
    lda #>(gamescreen_middle+15*32)
    adc #0
    sta temp+1
    ldy branches_list+4 ; branch3
    lda branch_addr_tableL,y
    sta temp2
    lda branch_addr_tableH,y
    sta temp2+1
    ldy #$00
@   lda (temp2),y
    sta (temp),y
    iny
    cpy tempbyte ;? lines
    bne @-    
all_drawed
    rts
.endp
;--------------------------------------------------
.proc branches_go_down
;--------------------------------------------------
    inc branches_anim_phase
    lda branches_anim_phase
    cmp #5
    bne next_phase_only
    jsr new_branch
next_phase_only
    jsr draw_branches
    rts
.endp
;--------------------------------------------------
.proc new_branch
;--------------------------------------------------
    mva #0 branches_anim_phase
    mva branches_list+4 branches_list+5
    mva branches_list+3 branches_list+4
    mva branches_list+2 branches_list+3
    mva branches_list+1 branches_list+2
    mva branches_list+0 branches_list+1
    ; ----- less branches -----
    beq make_random_branch
    lda #0
    beq branch_ready
    ; -----
make_random_branch
    lda RANDOM  ; branch or not (50%)
    and #%00000001
    beq branch_ready    ; no branches
    lda RANDOM  ; left or right (50%)
    and #%00000001
    tax
    inx
    txa
branch_ready
    sta branches_list+0
    rts
.endp
;--------------------------------------------------
.proc GetKey
; waits for pressing a key and returns pressed value in A
; result: A=keycode
;--------------------------------------------------
    jsr WaitForKeyRelease
getKeyAfterWait
    jsr GetKeyFast
    cmp #@kbcode._none
    beq getKeyAfterWait
    ldy #0
    sty ATRACT                 ; reset atract mode
    rts
.endp

;--------------------------------------------------
.proc GetKeyFast
; returns pressed value in A - no waits for press
; result: A=keycode ($ff - no key pressed)
;--------------------------------------------------
    .IF TARGET = 800
      lda SKSTAT
      and #%00000100  ;  any key  
      bne checkJoyGetKey       ; key not pressed, check Joy
    .ELIF TARGET = 5200
      lda SkStatSimulator
      and #%11111110
      bne checkJoyGetKey       ; key not pressed, check Joy
    .ENDIF
    lda kbcode
    cmp #@kbcode._none
    bne getkeyend
checkJoyGetKey
      ;------------JOY-------------
      ;happy happy joy joy
      ;check for joystick now
      lda STICK0
      and #$0f
      cmp #$0f
      beq notpressedJoyGetKey
      tay
      lda joyToKeyTable,y
      bne getkeyend

notpressedJoyGetKey
    ;fire
    lda STRIG0
    beq JoyButton
    .IF TARGET = 800           ; Second joy button , Select and Option key only on A800
      jsr Check2button
      bcc SecondButton
      bne checkSelectKey
checkSelectKey
      lda CONSOL
      and #%00000010           ; Select
      beq SelectPressed
      lda CONSOL
      and #%00000100           ; Option
      beq OptionPressed
    .ENDIF
    lda #@kbcode._none
    bne getkeyend
OptionPressed
    lda #@kbcode._atari        ; Option key
    bne getkeyend
SecondButton
SelectPressed
    lda #@kbcode._tab          ; Select key
    bne getkeyend
JoyButton
    lda #@kbcode._ret          ; Return key
getkeyend
    rts
; ----
    .IF TARGET = 800           ; Second joy button only on A800
Check2button
    lda PADDL0
    and #$c0
    eor #$C0
    cmp PaddleState
    sta PaddleState
    rts
    .ENDIF
.endp

;--------------------------------------------------
.proc getkeynowait
;--------------------------------------------------
    jsr WaitForKeyRelease
    lda kbcode
    and #$3f                   ; CTRL and SHIFT elimination
    rts
.endp


;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
StillWait
      lda STICK0
      and #$0f
      cmp #$0f
      bne StillWait
      lda STRIG0
      beq StillWait
    .IF TARGET = 800
      lda SKSTAT
      and #%00000100  ;  any key  
      beq StillWait
      lda CONSOL
      and #%00000110           ; Select and Option only
      cmp #%00000110
      bne StillWait
    .ELIF TARGET = 5200
      lda SkStatSimulator
      and #%11111110
      beq StillWait
    .ENDIF
KeyReleased
      rts
.endp
;--------------------------------------------------
.proc CheckStartKey
;--------------------------------------------------
    lda CONSOL  ; turbo mode
    and #%00000001 ; START KEY
    rts
.endp
;--------------------------------------------------
.proc InitBranches
;--------------------------------------------------
    ldy #5
@   lda initial_branches_list,y
    sta branches_list,y
    dey
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc WaitForSync
;--------------------------------------------------
    lda SyncByte
@   cmp SyncByte
    beq @-
    rts
.endp
;--------------------------------------------------
.proc RmtSongSelect
;  starting song line 0-255 to A reg
;--------------------------------------------------
    mvx #$ff RMT_blocked
    ldx #<MODUL                ; low byte of RMT module to X reg
    ldy #>MODUL                ; hi byte of RMT module to Y reg
    jsr RASTERMUSICTRACKER     ; Init
    mva #0 RMT_blocked
    rts
.endp
;--------------------------------------------------
.proc PAL_NTSC
;--------------------------------------------------
    lda PAL
    and #%00001110
    beq is_PAL
is_NTSC
    ldx #63
@   lda NTSC_colors,x
    sta GameColors,x
    dex
    bpl @-
    rts
is_PAL
    ldx #63
@   lda PAL_colors,x
    sta GameColors,x
    dex
    bpl @-
    rts
.endp
;--------------------------------------------------
; colors tables
PAL_colors
    ; black
    .by $00
    ; white (numbers and letters)
    .by $0c
    ; sky
    .by $88
    ; dark brown
    .by $f4
    ; light brown
    .by $f6
    ; red (bower bar)
    .by $34
    ; Lumberjack shirt A
    .by $22
    ; Lumberjack shirt B
    .by $24
    ; Lumberjack hand/face
    .by $2a
    ; birds
    .by $04
    ; clouds and logo
    .by $0e
    ; light red (power bar up)
    .by $3f
    ; thin horizon line A
    .by $b4
    ; thin horizon line B
    .by $da
    ; green grass
    .by $c8
    ; hat
    .by $82
    ; button and buckle
    .by $ea
    ; blue pants
    .by $94
    ; grey RIP
    .by $06
     ; title fonts colors
    .by $fc
    .by $ee
    .by $de
    .by $12
    .by $2a
    ; second set
    .by $18
    .by $1a
    .by $16
    ; rest of logo colors
    .by $04
    .by $12
    .by $14
    .by $ec
    .by $e8
    ; clouds on title screen
    .by $7e
NTSC_colors
    ; black
    .by $00
    ; white (numbers and letters)
    .by $0c
    ; sky
    .by $98
    ; dark brown
    .by $24
    ; light brown
    .by $26
    ; red (bower bar)
    .by $44
    ; Lumberjack shirt A
    .by $32
    ; Lumberjack shirt B
    .by $34
    ; Lumberjack hand/face
    .by $3a
    ; birds
    .by $04
    ; clouds
    .by $0e
    ; light red (power bar up)
    .by $4f
    ; thin horizon line A
    .by $c4
    ; thin horizon line B
    .by $ea
    ; green grass
    .by $d8
    ; hat
    .by $92
    ; button and buckle
    .by $fa
    ; blue pants
    .by $a4    
    ; grey RIP
    .by $06
     ; title fonts colors
    .by $2c
    .by $fe
    .by $ee
    .by $22
    .by $3a
    ; second set
    .by $28
    .by $2a
    .by $26
    ; rest of logo colors
    .by $04
    .by $22
    .by $24
    .by $fc
    .by $f8
    ; clouds on title screen
    .by $8e
;--------------------------------------------------

initial_branches_list
    .by 1,0,2,0,0,0 ; 

branch_addr_tableL
    .by <branch0
    .by <branch1
    .by <branch2
branch_addr_tableH
    .by >branch0
    .by >branch1
    .by >branch2
; power speed table - every 50pts.
PowerSpeedTableA
    ; in original game double speed after 400pts.
    ;   000,050,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950
    .by 011,010,010,009,008,007,007,006,005,005,004,004,004,003,003,003,002,002,001,001
PowerSpeedTableB
    ; level for old men 
    .by 022,020,018,017,015,013,012,011,010,010,009,009,008,007,006,005,004,003,002,001,001,001,001

;--------------------------------
PowerChar0 = $07    ; power bar first (0) character 
PowerCharFull = $0b
PowerCharEmpty = PowerChar0    
;--------------------------------
joyToKeyTable
    .by $ff             ;00
    .by $ff             ;01
    .by $ff             ;02
    .by $ff             ;03
    .by $ff             ;04
    .by $ff             ;05
    .by $ff             ;06
    .by @kbcode._right  ;07
    .by $ff             ;08
    .by $ff             ;09
    .by $ff             ;0a
    .by @kbcode._left   ;0b
    .by $ff             ;0c
    .by @kbcode._down   ;0d
    .by @kbcode._up     ;0e
    .by $ff             ;0f

;-------------------------------------------------
;RMT PLAYER variables
track_variables
trackn_db   .ds TRACKS
trackn_hb   .ds TRACKS
trackn_idx  .ds TRACKS
trackn_pause    .ds TRACKS
trackn_note .ds TRACKS
trackn_volume   .ds TRACKS
trackn_distor   .ds TRACKS
trackn_shiftfrq .ds TRACKS
trackn_instrx2  .ds TRACKS
trackn_instrdb  .ds TRACKS
trackn_instrhb  .ds TRACKS
trackn_instridx .ds TRACKS
trackn_instrlen .ds TRACKS
trackn_instrlop .ds TRACKS
trackn_instrreachend    .ds TRACKS
trackn_volumeslidedepth .ds TRACKS
trackn_volumeslidevalue .ds TRACKS
trackn_effdelay         .ds TRACKS
trackn_effvibratoa      .ds TRACKS
trackn_effshift     .ds TRACKS
trackn_tabletypespeed .ds TRACKS
trackn_tablenote    .ds TRACKS
trackn_tablea       .ds TRACKS
trackn_tableend     .ds TRACKS
trackn_tablelop     .ds TRACKS
trackn_tablespeeda  .ds TRACKS
trackn_command      .ds TRACKS
trackn_filter       .ds TRACKS
trackn_audf .ds TRACKS
trackn_audc .ds TRACKS
trackn_audctl   .ds TRACKS
v_aspeed        .ds 1
track_endvariables
;-------------------------------------------------
;RMT PLAYER loading shenaningans
    icl 'msx/rmtplayr_modified.asm'
;-------------------------------------------------
;-------------------------------------------------
; music and sfx
    org $b000  ; address of RMT module
MODUL
               ; RMT module is standard Atari binary file already
               ; include music RMT module:
      ins "msx/tbm1_str.rmt",+6
MODULEND

;-----------------------------------
; names of RMT instruments (sfx)
;--------------------------------
sfx_ciach = $03
;--------------------------------
; RMT songs (lines)
;--------------------------------
song_main_menu  = $00
song_ingame     = $07
song_game_over  = $05


    RUN main
