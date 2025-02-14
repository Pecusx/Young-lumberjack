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
    .wo gamescreen_upper
    :17 .by $04
    .by $84 ; first DLI
    .by $44
animation_addr
    .wo gamescreen_lower1r
    :5 .by $04
    .by $84 ; second DLI
    .by $04
    .by $44
lastline_addr
    .wo last_line_r
    .by $41
    .wo dl_level
;---------------------------------------------------
    icl 'art/anim_exported.asm'
; Animation sequence:
; - phase 1 page 1 (standard position)
; - phase 2 page 1
; - phase 2 page 2
; - phase 2 page 3
; - phase 2 page 4
; - phase 3 page 1
; - phase 3 page 2
; - phase 3 page 3
; - phase 3 page 4
; - phase 3 page 5
; - phase 2 page 1
; - phase 2 page 1
; - phase 2 page 1
; - phase 1 page 1 (standard position)
    
;--------------------------------------------------
    ;icl 'lib/fileio.asm'
;--------------------------------------------------

;--------------------------------------------------
.proc vint
;--------------------------------------------------

    mva #0 dliCount
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
    bne secondDLI
    mva LowCharsetBase CHBASE
    mva #$0c COLPF2
    mva #$c6 COLPF0
    inc dliCount
    pla
    rti
secondDLI
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC    
    mva #$86 COLPF2
    pla
    rti
.endp
;--------------------------------------------------
main
;--------------------------------------------------
    jsr wait_for_depress
    jsr MakeDarkScreen
    jsr initialize
    RMTsong song_main_menu
    jsr StartScreen
    RMTSong song_ingame
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
    jsr wait_for_press
    jsr wait_for_depress
    jsr AnimationR
    jsr wait_for_press
    jsr wait_for_depress
    jsr AnimationR
    jsr wait_for_press
    jsr wait_for_depress
    jsr AnimationL
    jsr wait_for_press
    jsr wait_for_depress
    jsr AnimationL
NoAuto
    jmp loop
LevelOver
    ; level over
    jsr wait_for_depress
    rts
.endp   

;--------------------------------------------------
.proc AnimationR
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
;    mwa #gamescreen_lower1r animation_addr
;    waitRTC
    mwa #gamescreen_lower2r animation_addr
    waitRTC
    mwa #gamescreen_lower3r animation_addr
    waitRTC
    mwa #gamescreen_lower4r animation_addr
    waitRTC
    mwa #gamescreen_lower5r animation_addr
    waitRTC
    mwa #gamescreen_lower6r animation_addr
    waitRTC
    mwa #gamescreen_lower7r animation_addr
    waitRTC
    mwa #gamescreen_lower8r animation_addr
    waitRTC
    mwa #gamescreen_lower9r animation_addr
    waitRTC
    mwa #gamescreen_lower10r animation_addr
    waitRTC
    mwa #gamescreen_lower2r animation_addr
    waitRTC
    waitRTC
    waitRTC
    mwa #gamescreen_lower1r animation_addr
    rts
.endp
;--------------------------------------------------
.proc AnimationL
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
;    mwa #gamescreen_lower1l animation_addr
;    waitRTC
    mwa #gamescreen_lower2l animation_addr
    waitRTC
    mwa #gamescreen_lower3l animation_addr
    waitRTC
    mwa #gamescreen_lower4l animation_addr
    waitRTC
    mwa #gamescreen_lower5l animation_addr
    waitRTC
    mwa #gamescreen_lower6l animation_addr
    waitRTC
    mwa #gamescreen_lower7l animation_addr
    waitRTC
    mwa #gamescreen_lower8l animation_addr
    waitRTC
    mwa #gamescreen_lower9l animation_addr
    waitRTC
    mwa #gamescreen_lower10l animation_addr
    waitRTC
    mwa #gamescreen_lower2l animation_addr
    waitRTC
    waitRTC
    waitRTC
    mwa #gamescreen_lower1l animation_addr
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
.proc initialize
;--------------------------------------------------
     
    mva #>font_game_upper CHBAS
    mva #>font_game_lower_right LowCharsetBase
    mva #$00 PCOLR0 ; = $02C0 ;- - rejestr-cień COLPM0

    mva #$00 COLBAKS
    mva #$88 COLOR0
    mva #$f4 COLOR1
    mva #$0c COLOR2
    mva #$f6 COLOR3
    ;mva #$ff COLOR4

    mva #0 dliCount
    sta RMT_blocked
    
    lda #$ff
    sta sfx_effect

    JSR AudioInit
    
/*     ;RMT INIT
    ldx #<MODUL                 ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    lda #0                      ;starting song line 0-255 to A reg
    jsr RASTERMUSICTRACKER      ;Init
 */    
    mwa #gamescreen_lower1r animation_addr
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
;--------------------------------------------------
.proc wait_for_press  ; ion
;--------------------------------------------------
    lda TRIG0
    beq press_ok
    lda CONSOL
    and:cmp #%00000111
    beq wait_for_press
press_ok
    rts
.endp
;--------------------------------------------------
.proc wait_for_depress  ; ion
;--------------------------------------------------
    lda CONSOL
    and:cmp #%00000111
    bne wait_for_depress
    lda TRIG0
    beq wait_for_depress
    rts
.endp
;--------------------------------
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
