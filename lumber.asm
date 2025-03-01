;Young lumberjack closure
;---------------------------------------------------
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
;---------------------------------------------------

         OPT r+  ; saves 10 bytes, and probably works :) https://github.com/tebe6502/Mad-Assembler/issues/10

;---------------------------------------------------
.macro build
    dta d"0.00" ; number of this build (4 bytes)
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
    .zpvar tempbyte .byte
    .zpvar StateFlag .byte    ; 0 - game, 1 - start screen, 2 game over screen, etc.
    .zpvar PowerValue .byte ; power: 0 - 48
    .zpvar PowerTimer .byte
    .zpvar PowerDownSpeed .byte
    .zpvar LevelValue .byte
    .zpvar LumberjackDir .byte ; 2 - on left , 1 - on right
    .zpvar PaddleState .byte
    .zpvar LowCharsetBase .byte
    .zpvar displayposition .word
    .zpvar DLI_A DLI_X dliCount .byte
    .zpvar RMT_blocked noSfx SFX_EFFECT .byte
    .zpvar AutoPlay .byte   ; Auto Play flag ($80 - auto)
RMT_zpvars = AutoPlay+1  ; POZOR!!! RMT vars go here
;---------------------------------------------------
    org $2000
MODUL
    ;ins 'art/muzyka_stripped.rmt',+5  ; my RMT 1.28 on WINE is apparently broken. I lost some hair here (5, not 6)
    ;.align $100
    ;icl 'art/rmtplayr.a65'
    ;---------------------------------------------------
    .align $400
font_game_upper
    ins 'art/tu.fnt'  ;
font_game_lower_right
    ins 'art/tl_r.fnt'  ;
font_game_lower_left
    ins 'art/tl_l.fnt'  ;
dl_level
    .by $10
    .by $44
    .wo power_bar    ; power indicator
    .by $84  ; DLI1
    .by $44
    .wo gamescreen_middle   ; branches
    :16 .by $04
    .by $84 ; DLI2
    .by $44
animation_addr
    .wo gamescreen_r_ph1p1
    :4 .by $04
    .by $84 ; DLI3
    .by $84 ; DLI4
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
    icl 'art/anim_exported.asm'
; Animations:
; v1 - if no branches
; v2 - if the branch under (due to change of sides) the lumberjack and none above 
; v3 - if the branch opposite the lumberjack and no branch and none above
; v4 - if no branch at the level of the lumberjack and branch above (kill)
; v5 - if the branch under (due to change of sides) the lumberjack and branch above (kill)
; v6 - if the branch opposite the lumberjack and branch above (kill)
; v7 - if no branch at the level of the lumberjack and branch above on the other side
; v8 - if the branch under (due to change of sides) the lumberjack and branch above on the other side
; v9 - if the branch opposite the lumberjack and branch above on the other side
;--------------------------------------------------

;--------------------------------------------------
.proc vint
;--------------------------------------------------

    mva #0 dliCount

    lda StateFlag
    bne wait_for_timer
    ; only during game
    ; power down
    dec PowerTimer
    bne wait_for_timer
    ; one bar down
    mva PowerDownSpeed PowerTimer
    jsr PowerDown
wait_for_timer

    
    ; mva #13 VSCROL  ; FOX gfx mode only

/*
    bit RMT_blocked
    bmi SkipRMTVBL
    ; ------- RMT -------
    lda sfx_effect
    bmi lab2
    asl @                       ; * 2
    tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
    ldx #0                      ;X = 0          channel (0..3 or 0..7 for stereo module)
    lda #0                      ;A = 0          note (0..60)
    bit noSfx
    smi:jsr RASTERMUSICTRACKER+15   ;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

    lda #$ff
    sta sfx_effect              ;reinit value
lab2
    jsr RASTERMUSICTRACKER+3    ;1 play
    ; ------- RMT -------
SkipRMTVBL

*/
/*     ;sfx
    lda sfx_effect
    bmi lab2
    asl                         ; * 2
    tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
    ldx #3                      ;X = 3          channel (0..3 or 0..7 for stereo module)
    lda #12                     ;A = 12         note (0..60)
    jsr RASTERMUSICTRACKER+15   ;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)
;
    lda #$ff
    sta sfx_effect              ;reinit value
;
lab2
    jsr RASTERMUSICTRACKER+3
skipSoundFrame */

    jmp XITVBV
.endp
;--------------------------------------------------
.proc IngameDLI1
;--------------------------------------------------
    pha
    lda dliCount
    bne DLI2
    inc dliCount
    mva #$0c COLPF2
    pla
    rti
DLI2
    cmp #1
    bne DLI3
    inc dliCount
    mva LowCharsetBase CHBASE
    mva #$f8 COLPF3
    nop
    nop
    nop
    mva #$c6 COLBAK
    pla
    rti
DLI3
    cmp #2
    bne DLI4
    sta WSYNC
    mva #>font_game_upper CHBASE
    inc dliCount
    pla
    rti
DLI4
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC    
    mva #$86 COLPF2
    inc dliCount
    pla
    rti
.endp
;--------------------------------------------------
main
;--------------------------------------------------
    jsr WaitForKeyRelease
    jsr MakeDarkScreen
    jsr initialize
    RMTsong song_main_menu
    jsr StartScreen
    RMTSong song_ingame
    jsr ScoreClear
gameloop
    jsr MakeDarkScreen
    jsr LevelScreen
    jsr PlayLevel
    jsr MakeDarkScreen
    ;jsr NextLevel
    ; RMTSong song_ingame
    jsr AudioInit   ; after I/O
    jmp gameloop
EndOfLife
    ;dec Lives   ; decrease Lives
    ;lda Lives
    ;cmp #"0"
    ;beq gameOver    ; if no lives - game over
    ;jsr NextLife
    jmp gameloop
gameOver
    ;game over
    ;RMTSong song_game_over 
    ;jsr HiScoreCheckWrite
    jsr GameOverScreen
@   lda CONSOL
    and #@consol(start) ; START
    beq main
    lda TRIG0   ; fire
    jeq main
    jmp @-

;--------------------------------------------------
.proc StartScreen
;--------------------------------------------------
/*     jsr MakeDarkScreen
    mwa #dl_start dlptrs
    lda #$0 ;+GTIACTLBITS
    sta GPRIOR
    sta COLBAKS
    lda #@dmactl(standard|dma) ; normal screen width, DL on, P/M off
    sta dmactls
    pause 1
StartLoop
    ;jmp StartLoop
EndOfStartScreen */
    mva #1 StateFlag
    rts
.endp
;--------------------------------------------------
.proc LevelScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    ldx #2
    mwa #dl_level dlptrs
    lda #@dmactl(narrow|dma)  ; narrow screen width, DL on, P/M off
    sta dmactls
    mva #>font_game_upper CHBAS
    pause 5
    mva #0 StateFlag
    rts
.endp
;--------------------------------------------------
.proc GameOverScreen
;--------------------------------------------------
/*     jsr MakeDarkScreen
    ldx #5
    mwa #dl_over dlptrs
    lda #%00110010  ; normal screen width, DL on, P/M off
    sta dmactls
    pause 20 */
    mva #2 StateFlag
    
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
loop

    ; PUT GAME HERE
    jsr GetKeyFast
    cmp #@kbcode._left
    beq left_pressed
    cmp #@kbcode._right
    beq right_pressed
    ; other keys or no key
    cmp #@kbcode._up
    bne NoNextLevel
    ; next level if joy UP
    jsr LevelUp
    jsr WaitForKeyRelease
NoNextLevel
    lda PowerValue
    jeq LevelDeath
    lda branches_list+5
    cmp LumberjackDir    ; branch and Lumerjack ?
    jeq LevelDeath
    jmp loop
right_pressed
/*  
    ; test for right lower branch
    lda branches_list+5
    cmp #1
    bne no_r_branch
    ; death by lower right branch
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    waitRTC
    mwa #gamescreen_r_ph1p1 animation_addr
    mva #1 LumberjackDir    ; right side
    bne LevelDeath
no_r_branch
*/ 
    jsr ScoreUp
    jsr PowerUp
    lda branches_list+4  ; check branch over 
    beq no_brancho_r
    ; branch over lumberjack
    cmp #1  ; right branch (kill)
    bne no_kill_r
    ;
    lda branches_list+5 ; check branch on lumberjack level
    beq kill_2branch_r
    cmp #2  ; left branch - animation v4
    bne kill_2branch_r    ; animation v5 (=v4)
    jsr AnimationR6
    jmp loop
kill_2branch_r
    jsr AnimationR4
    jmp loop    
no_kill_r
    lda branches_list+5 ; check branch on lumberjack level
    beq no_kill_2branch_r
    cmp #2  ; left branch - animation v7
    bne no_kill_2branch_r    ; animation v8 (=v7)
    jsr AnimationR9
    jmp loop
no_kill_2branch_r
    jsr AnimationR7
    jmp loop    
no_brancho_r
    ;no branch over lumberjack
    lda branches_list+5 ; check branch on lumberjack level
    beq no_2branch_r
    cmp #2  ; left branch - animation v3
    bne no_2branch_r    ; animation v2 (=v1)
    jsr AnimationR3
    jmp loop
no_2branch_r
    jsr AnimationR1
    jmp loop
left_pressed
/* 
    ; test for left lower branch
    lda branches_list+5
    cmp #2
    bne no_l_branch
    ; death by lower left branch
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    waitRTC
    mwa #gamescreen_l_ph1p1 animation_addr
    mva #2 LumberjackDir    ; left side
    bne LevelDeath
no_l_branch
*/
    jsr ScoreUp
    jsr PowerUp
    lda branches_list+4  ; check branch over
    beq no_brancho_l
    ; branch over lumberjack
    cmp #2  ; left branch (kill)
    bne no_kill_l
    ;
    lda branches_list+5 ; check branch on lumberjack level
    beq kill_2branch_l
    cmp #1  ; right branch - animation v4
    bne kill_2branch_l    ; animation v5 (=v4)
    jsr AnimationL6
    jmp loop
kill_2branch_l
    jsr AnimationL4
    jmp loop 
no_kill_l
    lda branches_list+5 ; check branch on lumberjack level
    beq no_kill_2branch_l
    cmp #1  ; right branch - animation v7
    bne no_kill_2branch_l    ; animation v8 (=v7)
    jsr AnimationL9
    jmp loop
no_kill_2branch_l
    jsr AnimationL7
    jmp loop    

no_brancho_l
    ; no branch over lumberjack
    lda branches_list+5 ; check branch on lumberjack level
    beq no_2branch_l
    cmp #1 ; right branch - animation v3
    bne no_2branch_l    ; animation v2 (=v1)
    jsr AnimationL3
    jmp loop
no_2branch_l
    jsr AnimationL1
    jmp loop
LevelDeath
    mva #2 StateFlag
    mva RANDOM COLBAK
    jsr GetKeyFast
    cmp #@kbcode._space
    bne LevelDeath
    ; restart game
    jsr ScoreClear
    jsr InitBranches
    jsr draw_branches
    jsr LevelReset
    mva #24 PowerValue  ; half power
    jsr draw_PowerBar
    mva #0 StateFlag
    jmp loop
LevelOver
    ; level over
    jsr WaitForKeyRelease
    rts
.endp   

;--------------------------------------------------
    icl 'art/animations.asm'
;--------------------------------------------------

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
.proc initialize
;--------------------------------------------------
     
    mva #>font_game_upper CHBAS
    mva #>font_game_lower_right LowCharsetBase
    mva #$00 PCOLR0 ; = $02C0 ;- - rejestr-cień COLPM0

    mva #$00 COLOR0
    mva #$88 COLBAKS ; sky
    mva #$f6 COLOR1 ; dark brown
    mva #$38 COLOR2 ; red
    mva #$18 COLOR3 ; light brown
    ;mva #$ff COLOR4

    mva #0 dliCount
    sta RMT_blocked
    
    lda #$ff
    sta sfx_effect

    JSR AudioInit
    
    jsr LevelReset
    jsr InitBranches
    jsr draw_branches
    mva #24 PowerValue  ; half power
    mva #1 PowerTimer   ; reset timer ( 1, not 0! )
    jsr draw_PowerBar
    mva #1 LumberjackDir    ; right side
    
/*     ;RMT INIT
    ldx #<MODUL                 ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    lda #0                      ;starting song line 0-255 to A reg
    jsr RASTERMUSICTRACKER      ;Init
 */    
    mwa #gamescreen_r_ph1p1 animation_addr
    lda #@dmactl(standard|dma)
    sta dmactls
    mwa #dl_level dlptrs
    vdli IngameDLI1

                    
    ;VBI

    vmain vint,7
    
    rts
.endp
;--------------------------------------------------
.proc RmtSongSelect
;  starting song line 0-255 to A reg
;--------------------------------------------------
/*
    cmp #song_main_menu
    beq noingame               ; noMusic blocks only ingame songs
    bit noMusic
    spl:lda #song_silencio
noingame
*/
/*     mvx #$ff RMT_blocked
    ldx #<MODUL                ; low byte of RMT module to X reg
    ldy #>MODUL                ; hi byte of RMT module to Y reg
    jsr RASTERMUSICTRACKER     ; Init
    mva #0 RMT_blocked
 */    rts
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
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+2
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
    mvx #1 LevelValue
    lda PowerSpeedTable,x
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
    tax
    lda PowerSpeedTable,x
    sta PowerDownSpeed
    jsr LevelToScreen
    rts
.endp
;--------------------------------------------------
.proc PowerUp
;--------------------------------------------------
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
    lda #PowerCharEmpty ; becouse naxt in bar chars are empty
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
    ; now calculate start screen adress
    lda #5
    sec
    sbc branches_anim_phase
    :5 asl  ; skippedlines*32
    tay ; to skip lines
    txa
    ; now calculate start screen adress
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
    ; ldy #$00  ; we hawe value in Y
@   lda (temp2),y
    sta (temp),y
    iny
    cpy #(5*32) ;5 lines - skipped lines
    bne @-
draw_branch1
    lda branches_anim_phase
    ; now calculate start screen adress
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
    ; now calculate start screen adress
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
    ; now calculate start screen adress
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
    ; now calculate start screen adress
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
    and #$3f                   ; CTRL and SHIFT ellimination
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
initial_branches_list
    .by 1,0,2,0,1,0 ; 

branch_addr_tableL
    .by <branch0
    .by <branch1
    .by <branch2
branch_addr_tableH
    .by >branch0
    .by >branch1
    .by >branch2
; Level to power speed table
PowerSpeedTable
    .by 12,11,10,9,8,7,6,5,4,3
    ;.by 20,20,18,16,14,12,11,10,9,8

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
;-----------------------------------
; names of RMT instruments (sfx)
;--------------------------------
sfx_ping = $07
sfx_pong = $08
;--------------------------------
; RMT songs (lines)
;--------------------------------
song_main_menu  = $00
song_ingame     = $07
song_game_over  = $12


    RUN main
