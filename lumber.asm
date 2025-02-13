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
font_game_lower
    ins 'art/tl.fnt'  ;
dl_level
    .by $10
    .by $44
    .wo gamescreen_upper
    :17 .by $04
    .by $84
    .by $44
animation_addr
    .wo gamescreen_lower1r
    :8 .by $04
    .by $41
    .wo dl_level
;---------------------------------------------------
gamescreen_upper
l1
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l2
    .by $01, $04, $01, $36, $37, $38, $39, $04, $3B, $3C, $3D, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l3
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $3E, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l4
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $2F, $20, $2C
    .by $22, $34, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l5
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l6
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $3F, $04, $41, $42, $43, $44, $45, $46, $01, $05, $05
l7
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $2E, $23, $24, $25, $26, $47, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l8
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $10, $10
    .by $10, $10, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l9
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $30
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l10
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $31, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l11
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1A, $1B, $1C
    .by $1B, $1A, $24, $11, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l12
    .by $01, $04, $01, $36, $37, $38, $39, $04, $3B, $3C, $3D, $1D, $1E, $1F, $20, $2D
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l13
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $3E, $1D, $1E, $1F, $20, $21
    .by $33, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l14
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $2D, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l15
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l16
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $3F, $04, $41, $42, $43, $44, $45, $46, $01, $05, $05
l17
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $1E, $32, $20, $21
    .by $32, $2C, $24, $25, $26, $47, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l18
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $2E, $1F, $20, $21
    .by $22, $23, $32, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l19
    .by $01, $04, $01, $01, $01, $01, $01, $04, $01, $01, $01, $1D, $32, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $04, $01, $01, $01, $01, $01, $01, $01, $05, $05
l20
gamescreen_lower1r
    .by $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $01, $01, $01, $07, $88, $01, $01, $01
    .by $01, $01, $01, $02, $01, $01, $01, $01, $03, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $21, $24, $25, $26, $02, $01, $01, $01, $5A, $5B, $09, $8A, $02, $01, $01
    .by $01, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $01, $5E, $5F, $5D, $5C, $64, $01, $01
    .by $01, $01, $01, $01, $03, $01, $01, $01, $82, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $03, $01, $E0, $E1, $62, $63, $E6, $67, $65, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $03, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $ED, $E8, $69, $6A, $EB, $6C, $64, $01, $01
    .by $01, $01, $82, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $ED, $EE, $EF, $70, $71, $72, $65, $01, $01
    .by $03, $01, $01, $01, $01, $03, $01, $01, $02, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $F3, $F4, $F4, $F4, $F4, $F5, $01, $82, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $76, $77, $78, $79, $7A, $7B, $01, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $27, $28, $28, $28, $28, $28
    .by $28, $28, $28, $28, $28, $29, $01, $7C, $7D, $01, $01, $7E, $7F, $01, $01, $01
gamescreen_lower2r
    .by $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    .by $01, $01, $01, $02, $01, $01, $01, $01, $03, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $02, $01, $01, $01, $06, $0B, $01, $01, $02, $01, $01
    .by $01, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $04, $0C, $0D, $01, $01, $01, $01, $01
    .by $01, $01, $01, $01, $03, $01, $01, $01, $82, $1D, $1E, $1F, $20, $21, $22, $23
    .by $24, $25, $26, $01, $01, $03, $01, $8E, $8F, $10, $11, $92, $93, $01, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $03, $01, $1D, $1E, $1F, $20, $21, $22, $23
    .by $24, $25, $26, $01, $01, $01, $01, $94, $95, $96, $97, $98, $99, $1A, $1B, $01
    .by $01, $01, $82, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21, $22, $23
    .by $24, $25, $26, $02, $01, $01, $01, $D0, $1C, $2C, $2D, $2E, $AF, $30, $31, $01
    .by $03, $01, $01, $01, $01, $03, $01, $01, $02, $1D, $1E, $1F, $20, $21, $22, $23
    .by $24, $25, $26, $01, $01, $01, $01, $F3, $F4, $F4, $F4, $F4, $F5, $01, $82, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21, $22, $23
    .by $24, $25, $26, $82, $01, $01, $01, $76, $77, $78, $79, $7A, $7B, $01, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $27, $28, $28, $28, $28, $28
    .by $28, $28, $28, $28, $28, $29, $01, $7C, $7D, $01, $01, $7E, $7F, $01, $01, $01
gamescreen_lower3r
    .by $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    .by $01, $01, $01, $02, $01, $01, $01, $01, $03, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $02, $01, $01, $01, $5A, $5B, $01, $01, $02, $01, $01
    .by $01, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $01, $5E, $5F, $01, $01, $01, $01, $01
    .by $01, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $01, $01, $01, $01, $01
    .by $01, $01, $01, $01, $01, $03, $01, $E0, $E1, $62, $63, $E6, $B2, $01, $01, $01
    .by $01, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $01, $01, $03, $01, $01
    .by $82, $01, $01, $33, $34, $36, $37, $B8, $B9, $3A, $3B, $BC, $BD, $01, $01, $01
    .by $01, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $01, $01, $01, $01, $01
    .by $01, $01, $01, $3E, $3F, $41, $42, $C3, $44, $45, $46, $CE, $CF, $01, $01, $01
    .by $01, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $01, $01, $01, $01, $01
    .by $03, $01, $01, $01, $01, $01, $01, $F3, $F4, $F4, $F4, $F4, $F5, $01, $82, $01
    .by $01, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $82, $01, $01, $01, $01
    .by $01, $01, $01, $82, $01, $01, $01, $76, $77, $78, $79, $7A, $7B, $01, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $27, $28, $28, $28, $28, $28
    .by $28, $28, $28, $28, $28, $29, $01, $7C, $7D, $01, $01, $7E, $7F, $01, $01, $01
gamescreen_lower4r
    .by $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    .by $01, $01, $01, $02, $01, $01, $01, $01, $03, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $02, $01, $01, $01, $06, $0B, $01, $01, $02, $01, $01
    .by $01, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $01, $04, $0C, $0D, $01, $01, $01, $01, $01
    .by $01, $01, $01, $01, $03, $01, $01, $01, $82, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $03, $01, $8E, $8F, $10, $11, $92, $93, $01, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $03, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $94, $95, $96, $97, $98, $99, $1A, $1B, $01
    .by $01, $01, $82, $01, $01, $01, $01, $01, $01, $01, $01, $1D, $1E, $1F, $20, $21
    .by $22, $23, $24, $25, $26, $01, $01, $D0, $1C, $2C, $2D, $2E, $AF, $30, $31, $01
    .by $03, $01, $01, $01, $01, $03, $01, $01, $02, $01, $01, $01, $01, $01, $01, $01
    .by $03, $01, $01, $01, $01, $01, $01, $F3, $F4, $F4, $F4, $F4, $F5, $01, $82, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $82, $01, $01, $01, $01
    .by $01, $01, $01, $82, $01, $01, $01, $76, $77, $78, $79, $7A, $7B, $01, $01, $01
    .by $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $27, $28, $28, $28, $28, $28
    .by $28, $28, $28, $28, $28, $29, $01, $7C, $7D, $01, $01, $7E, $7F, $01, $01, $01
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
.proc DLI
;--------------------------------------------------
    pha
    mva #$c6 COLPF0
    mva #>font_game_lower CHBASE
    mva #$0c COLPF2
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
    mwa #gamescreen_lower1r animation_addr
    jsr wait_for_press
    jsr wait_for_depress
    mwa #gamescreen_lower2r animation_addr
    jsr wait_for_press
    jsr wait_for_depress
    mwa #gamescreen_lower3r animation_addr
    jsr wait_for_press
    jsr wait_for_depress
    mwa #gamescreen_lower4r animation_addr

NoAuto
    jmp loop
LevelOver
    ; level over
    jsr wait_for_depress
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
    vdli DLI

                    
    ;VBI

    ;vmain vint,7
    
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
