;Young lumberjack closure
;---------------------------------------------------
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
.IFNDEF RMT
    .def RMT = 1 ; 2 - new player
.ENDIF
;---------------------------------------------------

         ;OPT r+  ; saves 10 bytes, and probably works :) https://github.com/tebe6502/Mad-Assembler/issues/10

;---------------------------------------------------
.macro build
    dta d"0.82" ; number of this build (4 bytes)
.endm

.macro RMTSong
      lda #:1
      jsr RMTSongSelect
.endm

;---------------------------------------------------
.IF TARGET = 800
        ORG $3000
        ; dark screean and BASIC off
        mva #0 dmactls             ; dark screen
        mva #$ff portb
        ; and wait one frame :)
        waitRTC                   ; or waitRTC ?
        mva #$ff portb        ; BASIC off
        rts
        ini $3000

.local
    icl 'art/DM_logo_src/digital_melody_logo.asm'
.endl

.ENDIF
;---------------------------------------------------
    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'

    .zpvar temp .word = $80
    .zpvar temp2 .word
    .zpvar VBItemp .word
    .zpvar tempbyte .byte
    .zpvar tempbyte2 .byte
    .zpvar SyncByte .byte
    .zpvar NTSCCounter  .byte
    .zpvar DLIcount .byte
    .zpvar StateFlag .byte    ; 0 - menu, 1 = GO!, 2 - game screen, 3 RIP screen, 4 - game over screen, 5 - halp screen, etc.
    .zpvar PowerValue .byte ; power: 0 - 48
    .zpvar PowerTimer .byte
    .zpvar PowerDownSpeed .byte
    .zpvar PowerSpeedIndex .byte
    .zpvar SpeedTableAdr .word
    .zpvar Difficulty .byte ; 0 - normal, 1 - easy
    .zpvar LumberjackDir .byte ; 2 - on left , 1 - on right
    .zpvar PaddleState .byte
    .zpvar LowCharsetBase .byte
    .zpvar displayposition .word
    .zpvar LastKey  .byte   ; $ff if no key pressed or last key released
    .zpvar RMT_blocked sfx_effect .byte
    .zpvar birdsHpos    .byte   ; 0 - no birds on screen (from $13 to $de)
    .zpvar birdsOffset  .byte
    .zpvar birds_order  .byte   ; $00 - standard , $80 - reverse
    .zpvar clouds1Hpos,clouds2Hpos,clouds3Hpos,clouds4Hpos  .byte     ; 0 - no cloud on screen (from $0e to $de)
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

RMT_Zero_Page_V = COLPM3_d+1  ; POZOR!!! RMT vars go here
;---------------------------------------------------
        ; init.... dark screean and BASIC off
        ORG $2000
        mva #0 dmactls             ; dark screen
        mva #$ff portb
        ; and wait one frame :)
        seq:wait                   ; or waitRTC ?
        mva #$ff portb        ; BASIC off
        rts
        ini $2000
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
font_over
    ins 'art/game_over.fnt'   ;
;---------------------------------------------------
dl_over
    .by $80 ; DLI1
    .by $45
    .wo over_screen    ; Game Over screen
    .by $05
    .by $05 ; DLI2 - end of chain (off)
    :3 .by $05
    .by $85 ; DLI3 - font change
    :4 .by $85 ; DLI4-7 - font colors
    .by $85 ; DLI8 - font change
    .by $05 
    .by $41
    .wo dl_over
;---------------------------------------------------
dl_help
    .by $30+$80
    .by $45+$80
    .wo help_screen    ; 
    :3 .by $05+$80
    .by $05
    .by $30+$80
    :3 .by $05+$80
    .by $05
    .by $30+$80
    :3 .by $05+$80
    .by $05
    .by $41
    .wo dl_help
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
    .by $44
    .wo empty_line
    .by $44
    .wo empty_line
    .by $44+$80 ; DLI8 - hat color change
    .wo title_timber    ; timberman logo
    .by $44+$80 ; DLI9 - color bars
timber_eyes_addr
    .wo eyes_0
    .by $44+$80 ; DLI10 - timbermaner charset change and horizon and color bars
    .wo title_timber+(32*2)
    .by $84 ; DLI11 - color bars
    .by $84 ; DLI12 - pants color
    .by $84 ; DLI13 - shadow
    .by $44+$80 ; DLI14
timber_foot_addr
    .wo foot_0
    .by $44+$80 ; DLI_L2 - fonts
    .wo title_timber+(32*7) ; rest of shadow
    .by $45 
difficulty_text_addr
    .wo difficulty_normal_text
    .by $45+$80
    .wo empty_line
    .by $45+$80
    .wo credits_lines
    .by $85
    .by $41
    .wo dl_title
;---------------------------------------------------
dl_go
    ;.by $10
    .by $44
    .wo power_bar    ; power indicator
    .by $84  ; DLI1 - color change (power bar - letters)
    .by $44
    .wo gamescreen_middle   ; branches
    .by $84  ; DLI2 - second clouds
    :3 .by $04
    .by $84     ; DLI3 - 3th clouds
    :3 .by $04
    .by $84     ; DLI4 - last clouds
    .by $84     ; DLI5 - GO line
    .by $30
    .by $45
go_addr
    .wo go_text-32 ; empty line before
    .by $10+$80; DLI6 - end GO line
    .by $10
    .by $44
    .wo gamescreen_middle+32*13
    :2 .by $04
    .by $84 ; DLI7
    .by $44
;animation_addr
    .wo gamescreen_r_ph1p1
    .by $84 ; DLI8
    :3 .by $04
    .by $84 ; DLI9
    .by $84 ; DLI10
    .by $04+$80 ; DLI11 - shadow
    .by $44
;lastline_addr
    .wo last_line_r
    .by $41
    .wo dl_go
;---------------------------------------------------
dl_level
    ;.by $10
    .by $44
    .wo power_bar    ; power indicator
    .by $84  ; DLI1 - color change (power bar - letters)
    .by $44
    .wo gamescreen_middle   ; branches
    .by $84  ; DLI2 - second clouds
    :3 .by $04
    .by $84     ; DLI3 - 3th clouds
    :3 .by $04
    .by $84     ; DLI4 - last clouds
    :7 .by $04
    .by $84 ; DLI5
    .by $44
animation_addr
    .wo gamescreen_r_ph1p1
    .by $84 ; DLI6
    :3 .by $04
    .by $84 ; DLI7
    .by $84 ; DLI8
    .by $04+$80 ; DLI9 - shadow
    .by $44
lastline_addr
    .wo last_line_r
    .by $41
    .wo dl_level
;---------------------------------------------------
Power = power_bar+32+10
gamescreen_middle
    .ds 32*18   ; 18 lines
screen_score = gamescreen_middle+9*32+14  
screen_timer = gamescreen_middle+1*32+12  
;---------------------------------------------------
GameColors
    .ds 64
c_black = 0
c_white = 1 ; (numbers and letters anf chain)
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
c_shirtC = 33  ; timberman shirt on title screen
c_over1 = 34   ; additional Game Over color
c_shadow = 35   ; lumberjack green shadow
c_fonti = 36    ; invertet font color
c_chain1 = 37   ; chain
c_chain2 = 38
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
    icl 'art/title_logo.asm'    ;   8 lines, mode 4 narrow
title_timber
    icl 'art/title_timber.asm'    ;   8 lines, mode 4 narrow (+ 4 lines - eyes animation, + 1 line - foot animation)
eyes_0 = title_timber+32
eyes_1 = title_timber+(32*8)
eyes_2 = title_timber+(32*9)
eyes_3 = title_timber+(32*10)
eyes_4 = title_timber+(32*11)
foot_0 = title_timber+(32*6)
foot_1 = title_timber+(32*12)
empty_line
    :40 .by 0
go_text
    icl 'art/go.asm'   ;   4 lines, mode 5
difficulty_normal_text
    icl 'art/difficulty_texts.asm'   ;   2 lines, mode 5
difficulty_easy_text = difficulty_normal_text + 40
    .align $400
over_screen
    icl 'art/over_screen.asm'   ;   13 lines, mode 5 narrow
scores_on_screen = over_screen+(32*7)+6   ; first byte of text in scores
credits_texts
    icl 'art/credits.asm'   ;   12 lines, mode 5
number_of_credits = 6
credits_lines   ; 2 lines for credits animations
    :80 .by 0
    .by 0   ; for second line animation
credit_nr   ; number of credit to display (displayed)
    .ds 1
credits_anim_counter    ; counter for credits animation/display
    .ds 1
help_screen
    icl 'art/help.asm'   ;   13 lines, mode 5
;--------------------------------------------------
.proc vint
;--------------------------------------------------
    lda StateFlag
    jmi common_VBI
    bne no_titles
    ; titles (StateFlag=0) - set DLI
    vdli TitlesDLI1
    jmp DLI_OK
no_titles
    cmp #1
    bne no_go
    ; go screen dli (StateFlag = 1)
    vdli GoDLI1
    jmp DLI_OK
no_go
    cmp #5
    bne no_help
    ; help screen dli
    vdli HelpDLI1
    jmp DLI_OK
no_help
    cmp #4
    beq no_game_and_RIP
    ; game screen and RIP screen (StateFlag=2 or 3) - set DLI
    vdli IngameDLI1
    jmp DLI_OK
no_game_and_RIP    
    ; game over screen (StateFlag=4) - set DLI
    vdli GameOverDLI1

DLI_OK
    lda StateFlag
    jeq titles_VBI
    cmp #1
    beq go_VBI
    cmp #2
    beq game_VBI
    cmp #3
    beq game_VBI
    cmp #4
    jeq gameover_VBI
    cmp #5
    jeq common_VBI
game_VBI
go_VBI
    ; game screen and RIP screen (StateFlag=2 or 3) VBI
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
    ; title screen (StateFlag=0) VBI
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
    jsr TimberLogoAnimate
    ;
    jmp common_VBI
gameover_VBI
    ; game over screen (StateFlag=4) VBI
    ; over horizon
    ; PMG horizontal coordinates and sizes
    ldx #$0c
@   lda HPOSP0_u,x
    sta HPOSP0,x
    dex
    bpl @-
    ; no clouds
    ;jsr FlyClouds
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
    cmp #2
    bne wait_for_timer
    ; only during game
    ; time up
    bit TimeCount
    bpl time_stopped
    jsr TimelUp
time_stopped
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
    asl                         ; * 2
    tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
    ldx #3                    ;X = 0          channel (0..3 or 0..7 for stereo module)
    lda #0                     ;A = 0          note (0..60)
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
    lda StateFlag
    beq no_new_cloud4   ; no cloud 4 on Start (Menu) screem
    lda clouds4Hpos
    bne cloud4_fly
    ; if no cloud 3 then randomize new cloud 3 start
    lda RANDOM
    and #%11111000  ;   1:32
    bne no_new_cloud4
    ; then create new cloud 3 shape
    jsr PrepareCloudsPM.make_cloud4
    mva #$de clouds4Hpos
cloud4_fly
    dec clouds4Hpos
no_new_cloud4
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
.proc TimberLogoAnimate
;--------------------------------------------------
    lda RTCLOK+2
    and #%00000011  ; for slower animation
    jne no_timber_animation
    inc AnimTimer
    ; animations
    ; check if animation in progress
    ; eyes....
    ldx EyesPhase
    beq no_eyes ; eyes up (no animation)
    cpx #5
    beq no_eyes ; eyes down (no animation)
    ; eyes animation in progress
    ; next phase
    inx
    cpx #5  ; after last phase of eyes down animation
    bne not_end_v1
    ldx #0  ; set to mo animation phase
    beq not_end_v2
not_end_v1
    cpx #10 ; after last phase of eyes up animation
    bne not_end_v2
    ldx #5  ; set to mo animation phase
not_end_v2
    stx EyesPhase
    jsr MenuEyesSet
    jmp no_eyes_animation
no_eyes
    ; no animation in progress let's make new
    lda AnimTimer
    cmp #30
    bne no_eyes_animation
    mva #0 AnimTimer    ; reset timer
    lda RANDOM
    and #%00000011
    beq no_eyes_animation ; 00 - no animation
/*     cmp #1
    bne no_eyes_change ; up/down
    ; eyes change (or not :) )
    ldx #5  ; eyes up
    lda RANDOM
    and #%00000111
    beq @+   ; eyes up (0)
    ldx #0   ; eyes down (1-7)
@   stx EyesPhase
    jsr MenuEyesSet
    jmp no_eyes_animation
 */
    cmp #1
    bne no_eyes_change
    ;  eyes down :)
    ldx #0  ; set to no animation phase
    stx EyesPhase
    beq go_eyes_set
no_eyes_change
    ; %10 and %11 - eyes animation
    inc EyesPhase
    ldx EyesPhase
go_eyes_set
    jsr MenuEyesSet
no_eyes_animation
    ; Foot animation (or not)
    ; check if animation in progress
    ; foot....
    ldx FootPhase
    beq no_foot ; eyes up (no animation)
    ; continue foot animation
    inx
    cpx #33   ; after last phase of foot animation (one frame = 4, one "step" = 2 frames = 8 .... +1 (ending frame) - 33 = 8(step)*4+1
    bne not_end_f
    ldx #0
not_end_f
    stx FootPhase
    cpx #8
    bne no_eyes_up
    ; foot animation phase 8 - eyes up :) 50/50
    bit RANDOM
    bmi no_eyes_up
    mvx #5 EyesPhase
    jsr MenuEyesSet
no_eyes_up
    ldx FootPhase
    jsr MenuFootSet
    jmp no_timber_animation
no_foot
    ; no animation in progress let's make new
    lda RTCLOK+2
    and #%00000111  ; for slower animation
    bne no_timber_animation
    dec FootTimer
    bne no_timber_animation
    ; start foot animation
    ldx #1
    stx FootPhase
    jsr MenuFootSet
    randomize 15 35
    sta FootTimer
no_timber_animation    
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
    sta WSYNC
    mva GameColors+c_logo1 COLPF2
    mva #$70 HPOSP0
    mva #$03 SIZEP0
    sta WSYNC
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
    mwa #TitlesDLI1.DLI7 VDSLST
    pla
    rti
DLI7
    pha
    ; timberman initial colors
    mva GameColors+c_black COLPF0
    mva GameColors+c_shirtB COLPF1
    mva GameColors+c_hat COLPF2
    mva GameColors+c_white COLPF3
    mva GameColors+c_hands COLPM0 ; face
    mva GameColors+c_dark_brown COLPM1 ; beard
    lda #0
    sta SIZEP0
    sta SIZEP1
    mva #$7c HPOSP0 ; face
    sta HPOSP1 ; beard
    mwa #TitlesDLI1.DLI8 VDSLST
    pla
    rti
DLI8
    pha
    ; timberman DLI1
    ; end of hat color
    mva GameColors+c_shirtA COLPF2
    :7 sta WSYNC
    mva GameColors+c_shirtC COLPF2
    mwa #TitlesDLI1.DLI9 VDSLST
    pla
    rti
DLI9
    pha
    mva GameColors+c_buckle COLPM2 ; buckle and buttons color
    ; color bars
    :3 sta WSYNC
    mva GameColors+c_shirtA COLPF2
    mva #$6f HPOSP0 ; left side hand
    lda #%00000011
    sta SIZEM
    mva #$8a HPOSM0 ; right side hand
    :4 sta WSYNC
    mva GameColors+c_shirtC COLPF2
    mva GameColors+c_light_brown COLPM1 ; axe color
    mwa #TitlesDLI1.DLI10 VDSLST
    pla
    rti
DLI10
    pha
    ; font for titles and timberman
    mva #$75 HPOSP1 ; axe
    mva #>font_titles CHBASE
    sta WSYNC
    mva GameColors+c_horizonA COLBAK ; thin line (horizon)
    mva #$7e HPOSP2 ; buttons and buckle
    mva #$6a HPOSM1 ; axe
    sta WSYNC
    mva GameColors+c_horizonB COLBAK ; additional lines (horizon)
    mva #$03 SIZEP3
    mva #$6a HPOSP3
    mva GameColors+c_dark_brown COLPM3 ; axe color 2
    ; color bars
    sta WSYNC
    mva GameColors+c_shirtA COLPF2
    sta WSYNC
    mva GameColors+c_grass COLBAK ; green (horizon)
    :3 sta WSYNC
    mva GameColors+c_shirtC COLPF2
    mwa #TitlesDLI1.DLI11 VDSLST
    pla
    rti
DLI11
    pha
    sta WSYNC
    ; horizon
    ;mva GameColors+c_horizonA COLBAK ; thin line (horizon)
    sta WSYNC
    ;mva GameColors+c_horizonB COLBAK ; additional lines (horizon)
    sta WSYNC
    ; color bars
    mva GameColors+c_shirtA COLPF2
    sta WSYNC
    ;mva GameColors+c_grass COLBAK ; green (horizon)
    ; color bars
    :3 sta WSYNC
    mva GameColors+c_shirtC COLPF2
    mwa #TitlesDLI1.DLI12 VDSLST
    pla
    rti
DLI12
    pha
    ; color bars
    :2 sta WSYNC
    mva GameColors+c_shirtA COLPF2 ; belt color
    :3 sta WSYNC
    mva GameColors+c_white COLPF1 ; axe end color
    sta WSYNC
    mva GameColors+c_pants COLPF2 ; pants color
    mwa #TitlesDLI1.DLI13 VDSLST
    pla
    rti
DLI13
    pha
    :4 sta WSYNC
    mva GameColors+c_shadow COLPF2 ; shadow color
    mwa #TitlesDLI1.DLI14 VDSLST
    pla
    rti
DLI14
    pha
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
    ; titles font colors
    mva GameColors+c_over1 COLPF0
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2
    mva GameColors+c_font3 COLPF3
    inc SyncByte
    lda #@dmactl(standard|dma|missiles|players|lineX2)  ; normal screen width, DL on, P/M on (2lines)
    sta dmactl
    mwa #TitlesDLI1.DLI_L1 VDSLST
    pla
    rti
DLI_L1
    pha
    mva GameColors+c_over1 COLPF0
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2
    :12 sta WSYNC
    mva GameColors+c_font5 COLPF2
    mwa #TitlesDLI1.DLI_L2 VDSLST
    pla
    rti
DLI_L2
    pha
    mva GameColors+c_over1 COLPF0
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
; color changes
;--------------------------------------------------
    pha
    phy
    sta WSYNC
    mva GameColors+c_sky COLBAK
    ldy #2
@   mva GameColors+c_chain1 COLPF3
    :2 sta WSYNC
    mva GameColors+c_chain2 COLPF3
    :4 sta WSYNC
    mva GameColors+c_white COLPF3
    :2 sta WSYNC
    mva GameColors+c_chain2 COLPF3
    :2 sta WSYNC
    mva GameColors+c_chain1 COLPF3
    :2 sta WSYNC
    mva GameColors+c_white COLPF3
    :4 sta WSYNC
    dey
    bpl @-
    mva GameColors+c_chain2 COLPF3
    ply
    :2 sta WSYNC
    mva GameColors+c_chain1 COLPF3
    mva GameColors+c_font1b COLPF1
    :2 sta WSYNC
    mva GameColors+c_logo4 COLPF3
    mva #0 DLIcount
    mwa #GameOverDLI1.DLI2 VDSLST
    pla
    rti
    ;
LastLine
    ; character set change
    sta WSYNC
    mva #>font_over CHBASE
    ; set lower colors
    mva GameColors+c_font1b COLPF1
    mva GameColors+c_font2 COLPF2
    inc SyncByte
    pla
    rti
DLI2
    pha
    lda DLIcount
    cmp #5
    bcs LastLine
    ; character set change
    sta WSYNC
    mva #>font_titles CHBASE
    lda DLIcount
    cmp NewHiScorePosition
    beq this_line_score1
    ; and font colors
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2
    :12 sta WSYNC
    mva GameColors+c_font5 COLPF2
    inc DLIcount
    pla
    rti
this_line_score1
    mva GameColors+c_font1b COLPF1
    mva GameColors+c_font2b COLPF2
    :12 sta WSYNC
    mva GameColors+c_font5b COLPF2
    inc DLIcount
    pla
    rti

.endp
;--------------------------------------------------
.proc HelpDLI1
; color changes
;--------------------------------------------------
    pha
    sta WSYNC
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2
    :12 sta WSYNC
    mva GameColors+c_font5 COLPF2
    pla
    rti
.endp
;--------------------------------------------------
.proc GoDLI1
; Clouds, birds, color changes
;--------------------------------------------------
    pha
    mva GameColors+c_white COLPF2 ; white (numbers and letters)
    mwa #GoDLI1.DLI2 VDSLST
    pla
    rti
DLI2
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
    mwa #GoDLI1.DLI3 VDSLST
    pla
    rti
DLI3
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
    mwa #GoDLI1.DLI4 VDSLST
    pla
    rti
DLI4
    pha
    ; set cloud 4 horizontal position
    lda #0  ; hide 4 cloud on GO screen
    sta HPOSM2
    sta HPOSP2
    sta HPOSP3
    sta HPOSM3
    mwa #GoDLI1.DLI5 VDSLST
    pla
    rti

DLI5
    pha
    sta WSYNC
    mva #>font_titles CHBASE
    mva GameColors+c_over1 COLBAK
    sta COLPF0
    mva GameColors+c_font1 COLPF1
    mva GameColors+c_font2 COLPF2 
    :2 sta WSYNC
    mva GameColors+c_buckle COLBAK
    :14 sta WSYNC
    mva GameColors+c_font5 COLPF2
    mwa #GoDLI1.DLI6 VDSLST
    pla
    rti
DLI6
    pha
    sta WSYNC
    mva #>font_game_upper CHBASE
    mva GameColors+c_over1 COLBAK
    mva GameColors+c_black COLPF0
    mva GameColors+c_dark_brown COLPF1
    mva GameColors+c_white COLPF2   
    :2 sta WSYNC
    mva GameColors+c_sky COLBAK
    mwa #IngameDLI1.DLI5 VDSLST ; !!! From here on, DLI interrupts are shared with the ingame screen
    pla
    rti
/* DLI6
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
    mwa #GoDLI1.DLI7 VDSLST
    pla
    rti
DLI7
    pha
    sta WSYNC
    mva GameColors+c_hat COLPF2 ; hat
    :4 STA WSYNC
    mva GameColors+c_white COLPF2 ; white
    mwa #GoDLI1.DLI8 VDSLST
    pla
    rti
DLI8
    pha
    lda StateFlag
    sta WSYNC
    cmp #2
    beq go_dli6
    cmp #1  ; go
    bne @+
go_dli6
    mva GameColors+c_buckle COLPF2 ; button and buckle
@   mva #>font_game_upper CHBASE
    mwa #GoDLI1.DLI9 VDSLST
    pla
    rti
DLI9
    pha
    lda StateFlag
    cmp #2
    beq go_dli7
    cmp #1  ; go
    bne @+
go_dli7
    sta WSYNC
    sta WSYNC
    sta WSYNC
    mva GameColors+c_pants COLPF2 ; blue pants
@   mwa #GoDLI1.DLI10 VDSLST
    pla
    rti
DLI10
    pha
    :3 sta WSYNC
    mva GameColors+c_shadow COLPF2 ; shadow
    pla
    rti */
.endp
;--------------------------------------------------
.proc IngameDLI1
; Clouds, birds, color changes
;--------------------------------------------------
    pha
    mva GameColors+c_white COLPF2 ; white (numbers and letters)
    mwa #IngameDLI1.DLI2 VDSLST
    pla
    rti
DLI2
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
    mwa #IngameDLI1.DLI3 VDSLST
    pla
    rti
DLI3
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
    mwa #IngameDLI1.DLI4 VDSLST
    pla
    rti
DLI4
    pha
    ; set cloud 4 horizontal position
    lda clouds4Hpos
    clc
    sta HPOSM2
    adc #4
    sta HPOSP2
    adc #8
    sta HPOSP3
    adc #8
    sta HPOSM3
    mwa #IngameDLI1.DLI5 VDSLST
    pla
    rti
DLI5
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
    mwa #IngameDLI1.DLI6 VDSLST
    pla
    rti
DLI6
    pha
    sta WSYNC
    mva GameColors+c_hat COLPF2 ; hat
    :4 STA WSYNC
    mva GameColors+c_white COLPF2 ; white
    mwa #IngameDLI1.DLI7 VDSLST
    pla
    rti
DLI7
    pha
    lda StateFlag
    sta WSYNC
    cmp #3  ; RIP screen
    beq @+
    mva GameColors+c_buckle COLPF2 ; button and buckle
@   mva #>font_game_upper CHBASE
    mwa #IngameDLI1.DLI8 VDSLST
    pla
    rti
DLI8
    pha
    lda StateFlag
    cmp #3  ; RIP screen
    beq @+
    sta WSYNC
    sta WSYNC
    sta WSYNC
    mva GameColors+c_pants COLPF2 ; blue pants
@   mwa #IngameDLI1.DLI9 VDSLST
    pla
    rti
DLI9
    pha
    ;lda StateFlag
    ;cmp #3  ; RIP screen
    ;beq @+
    :4 sta WSYNC
    mva GameColors+c_shadow COLPF2 ; shadow
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
    jsr ScoreClear
gameloop
    jsr MakeDarkScreen
    jsr LevelScreen
    RMTSong song_ingame
    ;RMTSong song_empty
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
    RMTsong song_scores
    jsr GameOverScreen
    jmp GameStart
;--------------------------------------------------
.proc StartScreen
;--------------------------------------------------
    mva #125 FootTimer  ; set delay for first foot animation (125 = 20s in PAL)
no_foot_delay
    jsr ZeroClock
    mva #$00 AutoScreen
    mva #$ff StateFlag
    jsr MakeDarkScreen
    jsr MenuAnimationsReset
    jsr ClearPM
    jsr HidePM
    jsr PrepareCloudsPM.no_cloud4
    jsr PrepareTitlePM
    jsr CreditsClear
    mva #0 StateFlag
    mva #>font_logo CHBAS
    mwa #dl_title dlptrs
    mva GameColors+c_sky COLBAKS
    mva GameColors+c_white2 COLOR0
    mva GameColors+c_logo3 COLOR1
    mva GameColors+c_font2 COLOR2
    lda #@dmactl(narrow|dma|missiles|players|lineX2)  ; narrow screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
difficulty_display
    lda Difficulty
    bne level_easy
    mwa #difficulty_normal_text difficulty_text_addr
    mwa #PowerSpeedTableA SpeedTableAdr     ; difficulty level normal
    jmp wait_for_key
level_easy
    mwa #difficulty_easy_text difficulty_text_addr
    mwa #PowerSpeedTableB SpeedTableAdr     ; difficulty level easy
wait_for_key
    pause 1
    jsr WaitForKeyRelease
StartLoop
    jsr GetKeyFast
    cmp #@kbcode._left  ; left, Select
    beq leftkey
    cmp #@kbcode._right ; right , Option
    bne notdirectionskeys
leftkey
    lda Difficulty
    eor #$01
    sta Difficulty
    jmp difficulty_display
notdirectionskeys
    cmp #@kbcode._help
    bne no_help
    jsr HelpScreen
go_startloop
    jsr WaitForKeyRelease
    jmp StartScreen
no_help
    cmp #@kbcode._space  ; space, Start
    beq EndOfStartScreen
    cmp #@kbcode._tab  ; TAB, 1st joy button
    beq EndOfStartScreen
    ; check timer
    lda RTCLOK+1
    cmp #8
    bne StartLoop
    ; if timer then auto change screens (help, Hi-score)
    mva #$ff AutoScreen
    jsr HelpScreen
    jsr GameOverScreen
    mva #40 FootTimer  ; set delay for foot animation
    jmp StartScreen.no_foot_delay
EndOfStartScreen
    rts
.endp
;--------------------------------------------------
.proc LevelScreen
;--------------------------------------------------
    mva #$ff StateFlag
    jsr MakeDarkScreen
    jsr ClearPM
    mva #>font_game_upper CHBAS
    mva #>font_game_lower_right LowCharsetBase
    mva GameColors+c_black PCOLR0 ; = $02C0 ;- - rejestr-cień COLPM0
    mva GameColors+c_black COLOR0
    mva GameColors+c_sky COLBAKS ; sky
    mva GameColors+c_dark_brown COLOR1 ; dark brown
    mva GameColors+c_red COLOR2 ; red
    mva GameColors+c_light_brown COLOR3 ; light brown
    
    ldy #$ff
    lda RANDOM
    and #%00000011  ; randomize bird order: 11, 10, 01 - stabdard / 00 - reverse
    beq reverse_birds
    iny
reverse_birds    
    sty birds_order    ; set birds order
    jsr TimerReset
    jsr InitBranches
    jsr draw_branches
    mva #24 PowerValue  ; half power
    mva #1 PowerTimer   ; reset timer ( 1, not 0! )
    jsr draw_PowerBar
    mva #1 LumberjackDir    ; right side
    mwa #gamescreen_r_ph1p1 animation_addr
    mwa #last_line_r lastline_addr
    mwa #(go_text-32) go_addr   ; empty line before GO! texts

    jsr PrepareLevelPM
    jsr PrepareBirdsPM
    jsr PrepareCloudsPM
    mwa #dl_go dlptrs
    lda #@dmactl(narrow|dma|missiles|players|lineX2)  ; narrow screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
    jsr SetPMr1
    mva #1 StateFlag    ; GO! screen
    RMTsong song_go
    jsr AnimateGoLine
    mwa #dl_level dlptrs
    mva #2 StateFlag    ; Game
    rts
.endp
;--------------------------------------------------
.proc GameOverScreen
;--------------------------------------------------
    mvy #$ff StateFlag
    iny
    sty ATRACT                 ; reset atract mode
    jsr MakeDarkScreen
    jsr ClearPM
    jsr HidePM
    jsr PrepareOverPM
    bit AutoScreen
    bmi training_mode
    lda Difficulty
    bne training_mode
    jsr ScoreToBuffer
    jsr ScoreToTable    ; score saving only in normal game mode
training_mode
    jsr PrepareScores
    mva #4 StateFlag
    mva #>font_over CHBAS
    mwa #dl_over dlptrs
    mva GameColors+c_black COLBAKS
    mva GameColors+c_over1 COLOR0
    mva GameColors+c_white2 COLOR1
    mva GameColors+c_white2 COLOR2
    mva GameColors+c_logo4 COLOR3
    lda #@dmactl(narrow|dma|missiles|players|lineX2)  ; narrow screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
    pause 1
    bit AutoScreen
    bmi training_mode2
    lda Difficulty
    bne training_mode2
    lda NewHiScorePosition
    cmp #5
    beq training_mode2
    jsr EnterPlayerName    ; enter name only in normal game mode and if there are new score
training_mode2
    jsr ZeroClock
    mva #$ff AutoScreen
    mva #5 NewHiScorePosition ; prevent highlighting of result
    jsr WaitForKeyRelease
OverLoop
    jsr GetKeyFast
    cmp #@kbcode._space ; space, Start
    beq EndOfOverScreen
    cmp #@kbcode._tab   ; TAB, Joy 1st button
    beq EndOfOverScreen
    ; if AutoScreen flag is set
    bit AutoScreen
    bpl OverLoop
    ; check timer
    lda RTCLOK+1
    cmp #2
    bne OverLoop
EndOfOverScreen
    rts
.endp
;--------------------------------------------------
.proc HelpScreen
;--------------------------------------------------
    mva #$ff StateFlag
    jsr ZeroClock
    jsr ScoreToBuffer
    jsr MakeDarkScreen
    jsr ClearPM
    jsr HidePM
    mva #5 StateFlag
    mva #>font_titles CHBAS
    mwa #dl_help dlptrs
    mva GameColors+c_sky COLBAKS
    mva GameColors+c_over1 COLOR0
    mva GameColors+c_font1 COLOR1
    mva GameColors+c_font2 COLOR2
    mva GameColors+c_fonti COLOR3
    lda #@dmactl(narrow|dma)  ; narrow screen width, P/M off
    sta dmactls
    pause 1
    jsr WaitForKeyRelease
HelpLoop
    jsr GetKeyFast
    cmp #@kbcode._space ; space, Start
    beq EndOfHelpScreen
    cmp #@kbcode._tab   ; TAB, Joy 1st button
    beq EndOfHelpScreen
    ; if AutoScreen flag is set
    bit AutoScreen
    bpl HelpLoop
    ; check timer
    lda RTCLOK+1
    cmp #2
    bne HelpLoop
EndOfHelpScreen
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
    mva #$ff TimeCount ; start time
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
    cmp #@kbcode._left  ; left, Select
    beq left_pressed
    cmp #@kbcode._tab   ; TAB, 1st button
    beq left_pressed
    cmp #@kbcode._right ; right, Option
    beq right_pressed
    cmp #@kbcode._ret ; Return
    beq right_pressed
    ; other keys or no key
    sta LastKey
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
    mva #0 TimeCount    ; stop time
    jsr SetRIPscreen
    RMTsong song_game_over
    jsr ZeroClock
    jsr WaitForKeyRelease
RIPLoop   
    jsr GetKeyFast
    cmp #@kbcode._space ; space, Start
    beq restart
    cmp #@kbcode._tab   ; TAB, 1st joy button
    beq restart
    lda RTCLOK+1
    cmp #2
    bne RIPLoop
restart
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
    mva #3 StateFlag
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
.proc ZeroClock
;--------------------------------------------------
    lda #0
    sta RTCLOK+1
    sta RTCLOK+2
    rts
.endp
;--------------------------------------------------
.proc TextToScreen
;--------------------------------------------------
; print text from temp address to screen at temp2 address
; X = characters to print
    lda #0
    tay
    sta (temp2),y   ; first space fix
    stx tempbyte2
@   jsr PrintChar
    ; after PrintChar i X register we have charcode and Y=0
    dec tempbyte2
    bne @-
    cpx #11  ; I character
    bne not_last_I
    tya ; 0 - space
    iny
    sta (temp2),y   ; fix for last I
not_last_I
    rts
PrintChar
    ldy #0
    lda (temp),y
    ; looking for char in the array
    ldx #0
@   cmp char_ascii,x
    beq char_found
    inx
    cpx char_count
    bne @-
    ; error - char not found
    beq skip_char
    rts
char_found
    ; print it
    lda char_byte1,x
    beq space_char  ; if space then skip one byte
    sta (temp2),y
space_char
    lda char_byte2,x
    inw temp2
    sta (temp2),y
    lda char_byte3,x
    bmi skip_char  ; space or I has only 2 bytes
    inw temp2
    sta (temp2),y
skip_char
    inw temp    
    rts
.endp
;--------------------------------------------------
.proc PrepareScores
;--------------------------------------------------
; display all scores table on Game Over screen
    jsr ClearScreenNames
    mva #0 ScorePosition    ; HiScore table position (0-4)
print_loop
    jsr InMemoryCacl    ; position in temp (word)
    jsr OnScreenCacl    ; positiom in temp2 (word)
    ldx #10     ; 10 characters ( result(4) + space(1) + name(5) )
    jsr TextToScreen
    inc ScorePosition
    lda ScorePosition
    cmp #5
    bne print_loop
    rts

InMemoryCacl    ; calculate position in memory (result in temp)
    mwa #(hs_pos1+6) temp
    lda ScorePosition
    :4 asl  ; *16
    clc
    adc temp
    sta temp
    bcc @+
    inc temp+1
@   rts
OnScreenCacl    ; calculate position on screen (result in temp2)
    mwa #scores_on_screen temp2
    lda ScorePosition
    :5 asl  ; *32
    clc
    adc temp2
    sta temp2
    bcc @+
    inc temp2+1
@   rts
.endp
;--------------------------------------------------
.proc ClearScreenNames
;--------------------------------------------------
; clear place for names on HiScore table
    mva #0 ScorePosition    ; HiScore table position (0-4)
clear_loop
    jsr PrepareScores.OnScreenCacl    ; calculate address on screen (result in temp2)    
    ldy #20     ; 21 bytes in each line
    lda #0  ; value to fill
@   sta (temp2),y
    dey
    bpl @-
    inc ScorePosition
    lda ScorePosition
    cmp #5
    bne clear_loop
    rts
.endp
;--------------------------------------------------
.proc ScoreToTable
;--------------------------------------------------
; moving last score from buffer to HiScore table
; in ScorePosition returns position in HiScore
; if ScorePosition=5 then not in HiScore
    mva #4 ScorePosition    ; starting from last (4) HiScore position
compare_next_position
    jsr PrepareScores.InMemoryCacl ; score address in temp (word)
    ldy #0
    ; compare last score (buffer) to HiScore in ScorePosition
compare_loop
    lda hs_posX+6,y   ; buffer
    cmp (temp),y    ; score in table
    beq next_digit
    bcc is_lower
is_bigger
    ldx ScorePosition
    dex
    bmi new_record
    stx ScorePosition
    bpl compare_next_position
next_digit
    iny
    cpy #4
    bne compare_loop
    ; last score is equal to HiScore position ScorePosition
is_lower
    inc ScorePosition
new_record
    ; now we have position of last score in HiScore (ScorePosition)
    lda ScorePosition
    sta NewHiScorePosition  ; save position for new name input
    cmp #5
    beq no_in_hiscore   ; last score is lower than last HiScore score
    cmp #4
    beq move_score_to_table ; last hi score position, then we dont moving lower scores down in table
    ; move down lower scores
    mva #4 ScorePosition    ; startig from penultimate position in HiScore
moving_loop
    dec ScorePosition
    ; now calculate position of overwritten score
    inc ScorePosition
    jsr PrepareScores.InMemoryCacl ; score address in temp (word)
    sbw temp #6 temp2    ; time in hiscore correction save to temp2
    ; calculate position of score to write
    dec ScorePosition
    jsr PrepareScores.InMemoryCacl ; score address in temp (word)
    sbw temp #6    ; time in hiscore correction
    ; move one position down
    ldy #15  ; 16bytes
@   lda (temp),y
    sta (temp2),y
    dey
    bpl @-
    ; one score moved
    lda ScorePosition
    cmp NewHiScorePosition
    bne moving_loop
    ; we have prepared space in HiScore
move_score_to_table
    ;mva NewHiScorePosition ScorePosition   ; unnecessary ?
    jsr PrepareScores.InMemoryCacl ; score address in temp (word)
    sbw temp #6    ; time in hiscore correction
    ldy #15  ; 16bytes
@   lda hs_posX,y
    sta (temp),y
    dey
    bpl @-
no_in_hiscore
    ; great success!!
    rts
.endp
;--------------------------------------------------
.proc EnterPlayerName
;--------------------------------------------------
    ; initial variables - "A" on first position
    mva #0 PositionInName
    mva #3 CharCode ;   3 = "A"
    mva NewHiScorePosition ScorePosition    ; HiScore table position (0-4)
    jsr PrepareScores.InMemoryCacl    ; position in temp (word)
    adw temp #5    ; after points
    ; clear name
    lda #0
    ldy #4
@   sta (temp),y
    dey
    bpl @-
input_name_loop
    jsr PrepareScores.InMemoryCacl    ; position in temp (word)
    adw temp #5    ; after points
    jsr PrepareScores.OnScreenCacl    ; positiom in temp2 (word)
    adw temp2 #10    ; after points
    ldy PositionInName
    ldx CharCode
    lda char_ascii,x
    sta (temp),y
    ; display name on Game Over screen
    ldx #5     ; 5 characters
    jsr TextToScreen
    lda NewHiScorePosition
    cmp #5  ; trick for END before 5 characters
    jeq end_of_name
    pause 1
    jsr GetKey
    cmp #@kbcode._left  ; left, Select
    beq leftkey
    cmp #@kbcode._right ; right, Option
    beq rightkey
    cmp #@kbcode._space ; space, Start
    beq next_char
    cmp #@kbcode._tab ; TAB, 1st joy buttom
    beq next_char
    bne input_name_loop
leftkey
    ldx CharCode
    dex
    cpx #2
    bne not_minimal ; check for lower than A (not space and s, l)
    ldx #char_count+1
not_minimal
not_maximal
    stx CharCode
    jmp input_name_loop
rightkey   
    ldx CharCode
    inx
    cpx #char_count+2
    bne not_maximal
    ldx #3  ; A (not space and s, l)
    bne not_maximal
next_char
    ; space / fire pressed
    ; next character or DEL or end of name
    lda CharCode
    cmp #char_count ; DEL
    bne no_del
    ; backspace :)
    ; set current char to space (clear)
    jsr PrepareScores.InMemoryCacl    ; position in temp (word)
    adw temp #5    ; after points
    ldy PositionInName
    bne no_first_char
    ; first char in name - nothing to do
    jmp input_name_loop    
no_first_char
    lda char_ascii  ; first char i table = space
    sta (temp),y    ; clear current char
    dey
    sty PositionInName
    jmp input_name_loop
no_del
    cmp #char_count+1   ; END
    bne no_end
    ; END
    ; change to space
    mva #0 CharCode ; space
    mva #5 NewHiScorePosition   ; name entered (trick)
    jmp input_name_loop    
no_end    
    inc PositionInName
    lda PositionInName
    cmp #5 ; last character in name
    beq end_of_name
    ; set naxt char to space - no .. no change charcode
    ldx CharCode
    bne not_maximal
end_of_name
    mva #5 NewHiScorePosition   ; name entered, set color to standard
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
.proc AnimateGoLine
;--------------------------------------------------
    ldy #3  ; 3 lines
next_line
    ; .... 3 , 2 , 1 ,  ....
    ldx #16     ; 32 characters
@   inw go_addr 
    inw go_addr
    WaitForSync
    dex
    bne @-
    phy
    ;RMTsong song_go1
    mva #sfx_go1 sfx_effect
    pause 25
    ply
    dey
    bne next_line
    ; .... GO! ....
    ldx #16     ; 32 characters
@   inw go_addr 
    inw go_addr
    WaitForSync
    dex
    bne @-
    ;RMTsong song_go2
    mva #sfx_go2 sfx_effect
    pause 25
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

    jsr ClearPM
    mva #>PMmemory PMBASE
    jsr HidePM
    mva #%00100100 GPRIOR
    mva #0 RMT_blocked
    
    lda #$ff
    sta sfx_effect

    JSR AudioInit

    jsr CreditsClear
    mva #$00 birds_order    ; standard birds order
    jsr TimerReset
    jsr InitBranches
    jsr draw_branches
    mva #24 PowerValue  ; half power
    mva #1 PowerTimer   ; reset timer ( 1, not 0! )
    jsr draw_PowerBar
    mva #1 LumberjackDir    ; right side
    mva #0 Difficulty       ; level normal
    mva #0 TimeCount    ; time stopped
    mva #$ff StateFlag
    
    ;jsr PrepareLevelPM
    ;jsr PrepareBirdsPM
    ;jsr PrepareCloudsPM
    ;jsr SetPMr1
    mwa #gamescreen_r_ph1p1 animation_addr
    lda #@dmactl(narrow|dma|missiles|players|lineX2)  ; narrow screen width, DL on, P/M on (2lines)
    sta dmactls
    mva #%00000011 GRACTL
    mwa #dl_level dlptrs
    ;vdli IngameDLI1
    mva #$ff RMT_blocked

    lda #$f0                   ; initial value
    sta RMTSFXVOLUME           ; sfx note volume * 16 (0,16,32,...,240)
                    
    ;VBI
    mva #0 NTSCCounter
    vmain vint,7
    
    mwa #PowerSpeedTableB SpeedTableAdr     ; difficulty level
    jsr GetKeyFast.Check2button  ; update state second joy button
    rts
.endp

;--------------------------------------------------
.proc ClearPM
; clear P/M memory
;--------------------------------------------------
    ;clear P/M memory
    lda #0
    tax
@   sta PMmemory,x
    sta PMmemory+$100,x
    sta PMmemory+$200,x
    sta PMmemory+$300,x
    inx
    bne @-
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
    ; 3 - vertical offset in PM from 36 (first byte) to 51 (last byte)
    ; 4 - vertical offset in PM from 52 (first byte) to 74 (last byte)
    ; cloud
    jsr make_cloud4
no_cloud4
    jsr make_cloud1
    jsr make_cloud2
    jsr make_cloud3
    mva #0 SIZEP2_u
    sta SIZEP3_u
    lda #%01010101
    sta SIZEM_u
    mva GameColors+c_clouds PCOLR2
    sta PCOLR3
    randomize 10 230
    sta clouds4Hpos
    randomize 10 230
    sta clouds3Hpos
    randomize 10 230
    sta clouds2Hpos
    randomize 10 230
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
    adc #5
    tay
    randomize 0 2
    clc
    adc #7  ; (7 to 9 = shapes 8 to 10)
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
    adc #20
    tay
    randomize 0 2
    clc
    adc #5  ; (5 to 7 = shapes 6 to 8)
    bne fill_cloud
make_cloud3
    ; clear cloud 3 PMG memory 
    ldx #(51-36) ; ldx #(84-36)
    lda #0
@   sta PMmemory+$300+36,x
    sta PMmemory+$380+36,x
    sta PMmemory+$180+36,x
    dex
    bpl @-
    randomize 0 (51-36-datalines_clouds)
    adc #36
    tay
    randomize 0 3
    clc
    adc #2  ; (2 to 5 = shapes 3 to 6)
    bne fill_cloud
make_cloud4
    ; clear cloud 4 PMG memory 
    ldx #(74-52)
    lda #0
@   sta PMmemory+$300+52,x
    sta PMmemory+$380+52,x
    sta PMmemory+$180+52,x
    dex
    bpl @-
    randomize 0 (74-52-datalines_clouds)
    adc #52
    tay
    randomize 0 2  ; (0 to 2 = shapes 1 to 3)
    ; fill cloud PMG memory
fill_cloud
    and #%00001111
    ; now we have shape number in A
    ; calculate offset (each cloud dataset = 12 bytes)
    ; calculate A*12
    :2 asl  ; A*4
    sta tempbyte
    asl ; A*2 (shape*8)
    adc tempbyte
    tax ; shape number * 12 in X register
    ; shape 1-10
    mva #datalines_clouds-1 tempbyte
@   lda cloud1_P2,x
    sta PMmemory+$300,y
    lda cloud1_P3,x
    sta PMmemory+$380,y
    lda cloud1_M,x
    sta PMmemory+$180,y
    iny
    inx
    dec tempbyte
    bpl @-
    rts

; clouds data
; shapes 1 to 10 for clouds
; player 2
cloud1_P2
    .by $00,$00,$00,$00,$08,$1D,$3F,$3F,$00,$00,$00,$00
cloud2_P2
    .by $00,$00,$00,$00,$07,$1F,$3F,$FF,$00,$00,$00,$00
cloud3_P2
	.by $00,$00,$00,$00,$39,$7D,$FF,$FF,$00,$00,$00,$00
cloud4_P2
    .by $00,$00,$00,$38,$7D,$FF,$FF,$FF,$00,$00,$00,$00
cloud5_P2
    .by $00,$00,$00,$0E,$1F,$1F,$7F,$FF,$FF,$00,$00,$00
cloud6_P2
	.by $00,$00,$00,$38,$7C,$7C,$FD,$FD,$FF,$FF,$00,$00
cloud7_P2
    .by $00,$00,$00,$00,$01,$73,$FF,$FF,$FF,$FF,$00,$00
cloud8_P2
    .by $00,$00,$00,$3E,$FF,$FF,$FF,$FF,$FF,$7C,$00,$00
cloud9_P2
    .by $00,$00,$01,$03,$77,$FF,$FF,$FF,$FF,$FF,$07,$01
cloud10_P2
    .by $00,$0F,$1F,$BF,$FF,$FF,$FF,$FF,$FF,$FF,$1F,$07
; player 3
cloud1_P3
    .by $00,$00,$00,$00,$00,$80,$E0,$F8,$00,$00,$00,$00
cloud2_P3
    .by $00,$00,$00,$00,$80,$DC,$FE,$FF,$00,$00,$00,$00
cloud3_P3
    .by $00,$00,$00,$F0,$F8,$FA,$FF,$FF,$00,$00,$00,$00
cloud4_P3
    .by $00,$00,$00,$C0,$F0,$FC,$FE,$FF,$00,$00,$00,$00
cloud5_P3
    .by $00,$00,$00,$30,$78,$78,$FB,$FF,$FF,$00,$00,$00
cloud6_P3
    .by $00,$00,$00,$00,$00,$E0,$F0,$F6,$FF,$FF,$00,$00
cloud7_P3
    .by $00,$00,$00,$00,$C0,$F6,$FF,$FF,$FF,$FF,$00,$00
cloud8_P3
    .by $00,$00,$00,$00,$7C,$FF,$FF,$FF,$FF,$FF,$00,$00
cloud9_P3
    .by $00,$00,$F0,$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$F8
cloud10_P3
    .by $0F,$1F,$BF,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$C0,$80
; missiles
cloud1_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
cloud2_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
cloud3_M
    .by $00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$00,$00
cloud4_M
    .by $00,$00,$00,$00,$00,$00,$10,$30,$00,$00,$00,$00
cloud5_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$90,$00,$00,$00
cloud6_M
    .by $00,$00,$00,$00,$00,$00,$00,$00,$10,$B0,$00,$00
cloud7_M
    .by $00,$00,$00,$00,$00,$00,$00,$10,$B0,$F0,$00,$00
cloud8_M
    .by $00,$00,$00,$00,$10,$30,$B0,$B0,$90,$00,$00,$00
cloud9_M
    .by $00,$00,$00,$80,$C0,$C0,$D0,$F0,$F0,$80,$00,$00
cloud10_M
    .by $00,$80,$80,$D0,$F0,$F0,$F0,$F0,$B0,$10,$00,$00


datalines_clouds=12
.endp
;--------------------------------------------------
.proc PrepareTitlePM
;--------------------------------------------------
    ; logo PM and other title screen PN (without clouds)
    jsr clearP0_1
    jsr logoPM
    jsr timlogoPM
    mva #1 SIZEP0_u
    sta SIZEP1_u
    mva GameColors+c_logo4 PCOLR0
    sta PCOLR1
    lda #$58
    sta HPOSP0_u
    lda #$98
    sta HPOSP1_u
    mva #0 VDELAY

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
timlogoPM
    ldx #datalines_tlogo-1
@   lda tlogo_data_m,x
    sta PMmemory+$180+Hoffset_tlogo,x
    lda tlogo_data_p3,x
    sta PMmemory+$380+Hoffset_tlogo,x
    lda tlogo_data_p2,x
    sta PMmemory+$300+Hoffset_tlogo,x
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
    :17 .by 0   ; 40 lines
    dta %00011000
    dta %11111111
    dta %11111111
    dta %00011000
    dta %00111100
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %11111000
    dta %11111000
    dta %11111000
    dta %11111000
    dta %11111000
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
    :17 .by 0   ; 40 lines
    dta %11100111
    dta %00000000
    dta %00000000
    dta %11100111
    dta %11000011
    dta %11111111
    dta %11111111
    dta %11111111
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %10100111
    dta %10100111
    dta %00000111
    dta %00000111
    dta %00000111
Hoffset_logo=12
datalines_logo=58
tlogo_data_m    ; axe
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000011
    dta %00000111
    dta %00001111
    dta %00001011
    dta %00001011
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
tlogo_data_p3   ; axe
    dta %00000000
    dta %00000000
    dta %00000000
    dta %00000000
    dta %10111000
    dta %10111000
    dta %10111000
    dta %00011000
    dta %00011000
    dta %00011000
    dta %00011000
    dta %00000000
tlogo_data_p2   ; buttons and buckle
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
    dta %11110000
Hoffset_tlogo=61
datalines_tlogo=11
.endp
;--------------------------------------------------
.proc PrepareOverPM
;--------------------------------------------------
    ; Players 1,2,3 filled fram ... to ...
    jsr ClearPM
    ldx #High_over-1
    lda #$ff    ; fill background
@   sta PMmemory+$280+Hoffset_over,x    ; P1
    sta PMmemory+$300+Hoffset_over,x    ; P2
    sta PMmemory+$380+Hoffset_over,x    ; P3
    dex
    bpl @-
    mva #%11 SIZEP1_u
    sta SIZEP2_u
    sta SIZEP3_u
    
    ; prepare sides
    ldx #datalines_over2-1
@   lda #$ff
    lda sides_data_a,x
    sta PMmemory+$200+Hoffset_over2,x   ; P0
    lda #%00000011
    ;lda sides_data_b,x
    sta PMmemory+$180+Hoffset_over2,x   ; M0
    dex
    bpl @-
    lda #%00000001
    sta SIZEM_u
    mva #0 SIZEP0_u
    
    mva GameColors+c_buckle PCOLR1    ; same color like buckle
    sta PCOLR2
    sta PCOLR3
    mva GameColors+c_font1b PCOLR0  ; same color like font b
    lda #$50
    sta HPOSP2_u
    lda #$70
    sta HPOSP1_u
    lda #$90
    sta HPOSP3_u
    lda #$a8
    sta HPOSP0_u
    lda #$50
    sta HPOSM0_u
    lda #%00010001
    sta VDELAY
; player 0
sides_data_a
    dta $0F,$03,$01,$3F,$0F,$00,$01,$01
    dta $1F,$01,$03,$01,$1F,$0F,$01,$01
    dta $71,$07,$00,$01,$03,$1F,$0F,$00
    dta $00,$01,$01,$03,$3F,$00,$01,$03
    dta $FF,$03,$01,$07,$01,$1F,$03,$07 
Hoffset_over = 30
High_over=78
Hoffset_over2=60
datalines_over2=40
    rts
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
timer
    dta d"00", $1a, d"00", $1a, d"00"
EyesPhase
    .ds 1
FootPhase
    .ds 1
AnimTimer
    .ds 1
FootTimer
    .ds 1
TimeCount
    .ds 1   ; 00 - time stopped , $ff - time count
ScorePosition
    .ds 1   ; line number in hi-score list (0-4)
NewHiScorePosition
    .ds 1   ; line number in hi-score list (0-4)
PositionInName
    .ds 1   ; position in player name
CharCode
    .ds 1   ; input character code in player name
AutoScreen
    .ds 1   ; 0 - standard, $ff - auto screen change
;--------------------------------------------------
.proc MenuAnimationsReset
;--------------------------------------------------
; set eyes and foot to phase 0
    mwa #eyes_0 timber_eyes_addr
    mwa #foot_0 timber_foot_addr
    ; reset timers and counters
    lda #0
    sta AnimTimer
    sta EyesPhase
    sta FootPhase
    rts
.endp
;--------------------------------------------------
.proc MenuEyesSet
;--------------------------------------------------
; set eyes to phase in X register
    lda title_anime_tableL,x
    sta timber_eyes_addr
    lda title_anime_tableH,x
    sta timber_eyes_addr+1
    rts
.endp
;--------------------------------------------------
.proc MenuFootSet
;--------------------------------------------------
; set eyes to phase in X register
    txa
    :2 lsr ; 4 times lower animation speed
    and #%00000001
    tax
    lda title_animf_tableL,x
    sta timber_foot_addr
    lda title_animf_tableH,x
    sta timber_foot_addr+1
    rts
.endp
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
    mva score screen_score
    mva score+1 screen_score+1
    mva score+2 screen_score+2
    mva score+3 screen_score+3
    rts
.endp
;--------------------------------------------------
.proc ScoreToBuffer
;--------------------------------------------------
    ; points
    lda score
    sec
    sbc #("0"-'0')
    sta hs_posX+6
    lda score+1
    sec
    sbc #("0"-'0')
    sta hs_posX+7
    lda score+2
    sec
    sbc #("0"-'0')
    sta hs_posX+8
    lda score+3
    sec
    sbc #("0"-'0')
    sta hs_posX+9
    ; time
    lda timer
    sec
    sbc #("0"-'0')
    sta hs_posX
    lda timer+1
    sec
    sbc #("0"-'0')
    sta hs_posX+1
    lda timer+3
    sec
    sbc #("0"-'0')
    sta hs_posX+2
    lda timer+4
    sec
    sbc #("0"-'0')
    sta hs_posX+3
    lda timer+6
    sec
    sbc #("0"-'0')
    sta hs_posX+4
    lda timer+7
    sec
    sbc #("0"-'0')
    sta hs_posX+5   
    rts
.endp
;--------------------------------------------------
.proc TimeToScreen
;--------------------------------------------------
    ldx #7
@   lda timer,x
    sta screen_timer,x
    dex
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc TimerReset
;--------------------------------------------------
; set timer to 1 and PowerDownSpeed to ??
    lda #"0"
    sta timer
    sta timer+1
    sta timer+3
    sta timer+4
    sta timer+6
    sta timer+7

    mvy #0 PowerSpeedIndex
    lda (SpeedTableAdr),y
    sta PowerDownSpeed
    jsr TimeToScreen
    rts
.endp
;--------------------------------------------------
.proc TimelUp
;--------------------------------------------------
    lda #"0"    ; for speed
    ldx timer+7
    inx
    inx
    cpx #"9"+1
    bcs next_digit6
    stx timer+7
    bne to_screen
next_digit6
    tax ; "0"
    stx timer+7
    ldx timer+6
    inx
    cpx #"9"+1
    bcs next_digit4
    stx timer+6
    bne to_screen
next_digit4
    tax ; "0"
    stx timer+6
    ldx timer+4
    inx
    cpx #"9"+1
    bcs next_digit3
    stx timer+4
    bne to_screen
next_digit3
    tax ; "0"
    stx timer+4
    ldx timer+3
    inx
    cpx #"6"
    bcs next_digit1
    stx timer+3
    bne to_screen
next_digit1
    tax ; "0"
    stx timer+3
    ldx timer+1
    inx
    cpx #"9"+1
    bcs next_digit0
    stx timer+1
    bne to_screen
next_digit0
    tax ; "0"
    stx timer+1
    inc timer
to_screen    
    jsr TimeToScreen
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
    jsr TimeToScreen
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
      lda CONSOL
      and #%00000001           ; Start
      beq StartPressed
    .ENDIF
    lda #@kbcode._none
    bne getkeyend
OptionPressed
    lda #@kbcode._right        ; Option key = right key
    bne getkeyend
SecondButton
    lda #@kbcode._ret          ; 2nd joy button = Return key
    bne getkeyend
SelectPressed
    lda #@kbcode._left          ; Select key = left key
    bne getkeyend
StartPressed
    lda #@kbcode._space          ; Start key = space key
    bne getkeyend
JoyButton
    lda #@kbcode._tab          ; 1st joy button = TAB key
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
      and #%00000111           ; Start, Select and Option
      cmp #%00000111
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
    ; timber shirt color on title screen
    .by $26
    ; game over colors
    .by $10
    ; shadow
    .by $c6
    ; inverted fonts
    .by $fa
    ; chain
    .by $08
    .by $0a
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
    ; timber shirt color on title screen
    .by $36
    ; game over colors
    .by $20
    ; shadow
    .by $d6
    ; inverted fonts
    .by $2a
    ; chain
    .by $08
    .by $0a
;--------------------------------------------------
title_anime_tableL
    .by <eyes_0 ; first eyes animation
    .by <eyes_1
    .by <eyes_2
    .by <eyes_1
    .by <eyes_0
    .by <eyes_3 ; second eyes animation
    .by <eyes_4
    .by <eyes_2
    .by <eyes_4
    .by <eyes_3
title_anime_tableH
    .by >eyes_0 ; first eyes animation
    .by >eyes_1
    .by >eyes_2
    .by >eyes_1
    .by >eyes_0
    .by >eyes_3 ; second eyes animation
    .by >eyes_4
    .by >eyes_2
    .by >eyes_4
    .by >eyes_3
title_animf_tableL
    .by <foot_0 ; foot animation
    .by <foot_1
    .by <foot_0
title_animf_tableH
    .by >foot_0 ; foot animation
    .by >foot_1
    .by >foot_0
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
; characters tables for GAme Over screen
    ;ascii codes
char_ascii
    .by " slABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<^"
char_count = 39 ; without DEL and END
char_byte1
    .by $00 ; space
    .by $54 ; S`    
    .by $36 ; L/  
    .by $20 ; A
    .by $22 ; B
    .by $24 ; C
    .by $26 ; D
    .by $26 ; E
    .by $26 ; F
    .by $24 ; G
    .by $26 ; H
    .by $30 ; I
    .by $32 ; J
    .by $26 ; K
    .by $36 ; L
    .by $38 ; M
    .by $3a ; N
    .by $24 ; O
    .by $26 ; P
    .by $24 ; Q
    .by $26 ; R
    .by $44 ; S
    .by $46 ; T
    .by $48 ; U
    .by $4a ; V
    .by $4c ; W
    .by $4e ; X
    .by $50 ; Y
    .by $52 ; Z
    .by $0c ; 0
    .by $0e ; 1
    .by $10 ; 2
    .by $12 ; 3
    .by $14 ; 4
    .by $16 ; 5
    .by $0c ; 6
    .by $1a ; 7
    .by $1c ; 8
    .by $1e ; 9    
    .by $18 ; DEL (arrow)
    .by $5a ; END (arrow)
char_byte2
    .by $00 ; space
    .by $55 ; S`    
    .by $57 ; L/  
    .by $21 ; A
    .by $13 ; B
    .by $25 ; C
    .by $27 ; D
    .by $29 ; E
    .by $2b ; F
    .by $2d ; G
    .by $2f ; H
    .by $31 ; I
    .by $33 ; J
    .by $35 ; K
    .by $37 ; L
    .by $39 ; M
    .by $3b ; N
    .by $3d ; O
    .by $3f ; P
    .by $41 ; Q
    .by $43 ; R
    .by $45 ; S
    .by $47 ; T
    .by $49 ; U
    .by $4b ; V
    .by $4d ; W
    .by $4f ; X
    .by $51 ; Y
    .by $53 ; Z
    .by $0d ; 0
    .by $0f ; 1
    .by $11 ; 2
    .by $13 ; 3
    .by $15 ; 4
    .by $17 ; 5
    .by $17 ; 6
    .by $1b ; 7
    .by $13 ; 8
    .by $1f ; 9    
    .by $19 ; DEL (arrow)
    .by $5b ; END (arrow)
char_byte3
    .by $00 ; space
    .by $31 ; S`    
    .by $58 ; L/   
    .by $31 ; A
    .by $31 ; B
    .by $31 ; C
    .by $31 ; D
    .by $31 ; E
    .by $31 ; F
    .by $31 ; G
    .by $31 ; H
    .by $ff ; I
    .by $31 ; J
    .by $31 ; K
    .by $58 ; L
    .by $31 ; M
    .by $31 ; N
    .by $31 ; O
    .by $31 ; P
    .by $31 ; Q
    .by $31 ; R
    .by $31 ; S
    .by $31 ; T
    .by $31 ; U
    .by $31 ; V
    .by $31 ; W
    .by $31 ; X
    .by $31 ; Y
    .by $31 ; Z
    .by $31 ; 0
    .by $58 ; 1
    .by $31 ; 2
    .by $31 ; 3
    .by $31 ; 4
    .by $31 ; 5
    .by $31 ; 6
    .by $31 ; 7
    .by $31 ; 8
    .by $31 ; 9    
    .by $00 ; DEL (arrow)
    .by $00 ; END (arrow)
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
high_scores
    ;   "0123456789012345"  - 16bytes
hs_pos1
    .by "0000000210 PECUs"  
hs_pos2
    .by "0000000170 PIRX "
hs_pos3
    .by "0000000130 ADAM "
hs_pos4
    .by "0000000110 ALEX "
hs_pos5
    .by "0000000090 TDC  "
hs_posX
    .by "0000000000 NEW  "  ; buffer for last score
hs_def_name
    .by "A    "
;-------------------------------------------------
;RMT PLAYER variables
.IF RMT = 2
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
.ENDIF
;-------------------------------------------------
;RMT PLAYER loading shenaningans
    .align $100
    .ds $400
PLAYER
.IF RMT =2
    icl 'msx/rmtplayr_modified.asm'
.ELSE
    icl 'msx/rmtplayr.asm'
.ENDIF
;-------------------------------------------------
;-------------------------------------------------
; music and sfx
    org $b000  ; address of RMT module
MODUL
               ; RMT module is standard Atari binary file already
               ; include music RMT module:
      ins "msx/tbm5_str.rmt",+6
MODULEND

;-----------------------------------
; names of RMT instruments (sfx)
;--------------------------------
sfx_ciach = $03
sfx_go1 = $0c
sfx_go2 = $0d
;--------------------------------
; RMT songs (lines)
;--------------------------------
song_main_menu  = $00
song_ingame     = $17
song_game_over  = $0d
song_go         = $10
song_scores    = $12


    RUN main
