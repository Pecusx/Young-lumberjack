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
    ins 'art/muzyka_stripped.rmt',+5  ; my RMT 1.28 on WINE is apparently broken. I lost some hair here (5, not 6)
    .align $100
    icl 'art/rmtplayr.a65'
    ;---------------------------------------------------
    .align $400
font
    ins 'art/Mild West.fnt'  ; https://damieng.com/typography/zx-origins/mild-west/
dl 
    .by SKIP3
    dta MODE2+LMS,a(statusBuffer)
    ;.by $80+$50  # fancy shmancy vscroll square pixels
    ;dta $4f+$20,a(display)	 ;VSCROLL
    ;:((maxlines-1)/2) dta a($2f8f)	
    .by SKIP1+DLII
    .rept (maxlines-1), #
    :3 dta MODEF+LMS, a(display+screenBytes*:1)
    dta MODEF+LMS+DLII, a(display+screenBytes*:1)
    .endr
    ;----    
    .by MODE2+LMS+SCH ;Hscroll
DLracquetAddr0
    .wo racquetDisp
    .by JVB
    .wo dl
;---------------------------------------------------
;--------------------------------------------------
    icl 'lib/fileio.asm'
;--------------------------------------------------

;--------------------------------------------------
.proc vint
;--------------------------------------------------
    ;------------JOY-------------
    ;happy happy joy joy
    ;check for joystick now

    ldy PORTA
    tya
    and #$04 ;left
    bne jNotLeft
    ldx racquetPos
    cpx #racquetPosMin+1
    bcc jNotLeft
    dex
    stx racquetPos

jNotLeft
    tya
    and #$08 ;right
    bne jNotRight
    ldx racquetPos
    cpx #racquetPosMax
    bcs jNotRight
    inx
    stx racquetPos
jNotRight
/*
    ;fire
    lda TRIG0
    bne JNotFire
    ...
JNotFire
*/
  
    ;lda racquetPos

    sec
    lda #screenWidth-1
    sbc racquetPos
    lsr
    clc
    adc #<racquetDisp
    sta dlracquetAddr0
    lda #>racquetDisp
    adc #0
    sta dlracquetAddr0+1

    lda racquetPos
    lsr 
    and #$01
    ;sta HSCROL
    
/*  ;pos print
    lda racquetPos
    :4 lsr
    clc
    adc #'0'
    sta hexDump
 
    lda racquetPos
    and #$0F
    clc
    adc #'0'
    sta hexDump+1
*/ 

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
    ;sfx
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
skipSoundFrame

    jmp XITVBV
.endp
;--------------------------------------------------
.proc DLI
;--------------------------------------------------
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
    jsr MakeDarkScreen
    
    mva #$0 AutoPlay    
    jsr ScoreClear
    mva #"5" Lives
    jsr clearscreen
    mva #$0 LevelType
    jsr LoadLevelData.level000  ; set visible number to 000
    jsr BuildLevelFromBuffer
    jsr LevelScreen
    RMTSong song_ingame
gameloop
    jsr initialize.ClearTables
    jsr MainScreen
    jsr PlayLevel
    bit EndLevelFlag    ; reason for end level
    bmi EndOfLife   ; end of life :)
    ; end of level (level up)
    jsr MakeDarkScreen
    jsr NextLevel
    jsr LevelScreen
    ; RMTSong song_ingame
    jsr AudioInit   ; after I/O
    jmp gameloop
EndOfLife
    dec Lives   ; decrease Lives
    lda Lives
    cmp #"0"
    beq gameOver    ; if no lives - game over
    jsr NextLife
    jmp gameloop
gameOver
    ;game over
    RMTSong song_game_over 
    jsr HiScoreCheckWrite
    jsr GameOverScreen
@   lda RANDOM
    and #%00001110
    sta COLPF0
    lda CONSOL
    and #@consol(start) ; START
    beq main
    lda TRIG0   ; fire
    jeq main
    jmp @-

;--------------------------------------------------
.proc StartScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    mva #$ff AutoPlay
    sta LevelType   ; Title
    mva #"9" Lives
    jsr clearscreen
    jsr BuildLevelFromBuffer
    mwa #dl_start dlptrs
    lda #$0 ;+GTIACTLBITS
    sta GPRIOR
    sta COLBAKS
    lda #@dmactl(standard|dma) ; normal screen width, DL on, P/M off
    sta dmactls
    pause 1
StartLoop
    jsr PlayLevel
    bit EndLevelFlag    ; reason for end level
    bmi EndOfStartScreen
    ; end of level (level up)
    jsr NextLevel
    jmp StartLoop
EndOfStartScreen
    rts
.endp
;--------------------------------------------------
.proc NextLife
;--------------------------------------------------
    ldy #maxBalls
    sty eXistenZstackPtr
    ;OK, one ball starts!
    lda eXistenZstack,Y
    dey
    sty eXistenZstackPtr
    tax
    jsr randomStart ;just one random pixxxel 
                    ;previously the whole band of ballz
    rts
.endp
;--------------------------------------------------
.proc NextLevel
;--------------------------------------------------
    lda LevelType
    beq level000
    bmi levelTitle
    ; load level from disk
loadNext
    jsr FileUp
    jsr LoadLevelData
levelTitle
    jsr clearscreen
    jsr BuildLevelFromBuffer
    jsr initialize.ClearTables
    rts ; start level
level000
    mva #1 LevelType    ; switch to files
    ; reset file number to 000
    ldx #2
@   lda StartLevelNumber,x
    sta LevelNumber,x
    dex
    bpl @-
    jmp loadNext
.endp

;--------------------------------------------------
.proc LevelScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    ldx #2
@     lda LevelNumber,x
      sec
      sbc #$20
      sta LevelText+16,x
      dex
    bpl @-
    mwa #dl_level dlptrs
    lda #@dmactl(standard|dma)  ; normal screen width, DL on, P/M off
    sta dmactls
    pause 100
    rts
.endp
;--------------------------------------------------
.proc GameOverScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    ldx #5
@     lda score,x
      sta OverText+33,x
      dex
    bpl @-
    mwa #dl_over dlptrs
    lda #%00110010  ; normal screen width, DL on, P/M off
    sta dmactls
    pause 20
    
    rts
.endp
;--------------------------------------------------
.proc MainScreen
;--------------------------------------------------
    jsr MakeDarkScreen
    mwa #dl dlptrs
    lda #$0 ;+GTIACTLBITS
    sta GPRIOR
    sta COLBAKS
    lda #@dmactl(standard|dma)  ; normal screen width, DL on, P/M off
    sta dmactls
    pause 1
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
       
    dec currBall
    jpl flight


    pause 1 ;all balls
    bit AutoPlay
    bpl NoAuto
    pause 1 ;additional pause if auto play mode (slower)
    lda CONSOL
    and #@consol(start) ; START
    beq LevelOver   ; Start pressed in Auto Play - exit
    lda TRIG0
    beq LevelOver
    
NoAuto
    lda eXistenZstackPtr
    cmp #maxBalls
    jne loop
LevelOver
    ; level over
    mva #$ff EndLevelFlag
    jsr wait_for_depress
    rts
    

;--------------------------------------------------
.proc ScoreUp
;--------------------------------------------------
    inc score+5
    lda score+5
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+5
    inc score+4
    lda score+4
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+4
    inc score+3
    lda score+3
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+3
    inc score+2
    ; bonus !!! :)
    lda Lives
    cmp #"9"
    beq noLivesUP
    inc Lives
    mva #05 sfx_effect
    mva #$ff COLBAKS
    pause 2 ; sorry
    inc COLBAKS
noLivesUP
    ;----------
    lda score+2
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+2
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
    ldx #4
@   sta score,x
    dex
    bpl @-
    rts
.endp
;--------------------------------------------------
.proc HiScoreCheckWrite
; It checks if the score is greater than hiscore.
; If yes - rewrites the score to hiscore.
;--------------------------------------------------
    lda HiScore
    cmp score
    bcc higher1
    bne lower
    lda HiScore+1
    cmp score+1
    bcc higher2
    bne lower
    lda HiScore+2
    cmp score+2
    bcc higher3
    bne lower
    lda HiScore+3
    cmp score+3
    bcc higher4
    bne lower
    lda HiScore+4
    cmp score+4
    bcc higher5
    bne lower
    lda HiScore+5
    cmp score+5
    bcc higher6
lower
    rts
higher1
    lda score
    sta HiScore
higher2
    lda score+1
    sta HiScore+1
higher3
    lda score+2
    sta HiScore+2
higher4
    lda score+3
    sta HiScore+3
higher5
    lda score+4
    sta HiScore+4
higher6
    lda score+5
    sta HiScore+5
    rts
.endp
;--------------------------------------------------
.proc clearScreen
;--------------------------------------------------
    lda #0
    tax
@
    :(maxLines*40/256+1) sta display+$100*#,x
    inx
    bne @-
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
     
    mva #>font CHBAS
    mva #$00 PCOLR0 ; = $02C0 ;- - rejestr-cień COLPM0

    mva #$7C COLBAKS

    mva #screenWidth/2-racquetSize/4 racquetPos    

    mva #0 dliCount
    sta RMT_blocked
    
    lda #$ff
    sta sfx_effect

    JSR AudioInit
    
    ;RMT INIT
    ldx #<MODUL                 ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    lda #0                      ;starting song line 0-255 to A reg
    jsr RASTERMUSICTRACKER      ;Init
    
    
    lda #@dmactl(standard|dma)
    sta dmactls
    mwa #dl dlptrs
    vdli DLI

ClearTables
    jsr cyclecolorsReset
    mwa #clear_vars_start temp
    ldy #0
@
    tya
    sta (temp),y
    inw temp
    cpw temp #clear_vars_end
    bne @-


                    
    ;VBI

    vmain vint,7
    
    rts
.endp
;--------------------------------------------------
.proc FileUp
;--------------------------------------------------
    inc LevelNumber+2
    lda LevelNumber+2
    cmp #'9'+1  ; 9+1 character code
    bne NumberReady
    lda #'0'    ; 0 character code
    sta LevelNumber+2
    inc LevelNumber+1
    lda LevelNumber+1
    cmp #'9'+1  ; 9+1 character code
    bne NumberReady
    lda #'0'    ; 0 character code
    sta LevelNumber+1
    inc LevelNumber
NumberReady
    rts
.endp
;--------------------------------------------------
.proc LoadLevelData
;--------------------------------------------------
    lda LevelType
    beq level000
    bmi levelTitle
    ; load level from disk
    ; prepare number in filename
    ldx #2
@   lda LevelNumber,x
    sta fname+7,x
    dex
    bpl @-
    ; clear buffer
    mwa #LevelFileBuff temp
    ldy #0
@   tya
    sta (temp),y
    inw temp
    cpw temp #LevelFileBuffEnd
    bne @-
    ; try to load file
    jsr close
    jsr open
    bmi open_error
    jsr bget
    bmi bget_error
go_close    jsr close
    rts
bget_error
    cpy #136 ; EOF
    beq go_close
open_error
    mva #0 LevelType    ; set level to internal 000
level000
    ; reset file number to 000
    ldx #2
@   lda StartLevelNumber,x
    sta LevelNumber,x
    dex
    bpl @-
levelTitle
    rts 
.endp   
;--------------------------------------------------
.proc displaydec5 ;decimal (word), displayposition  (word)
;--------------------------------------------------
; displays decimal number as in parameters (in text mode)
; leading zeroes are removed
; the range is (00000..65565 - two bytes)

    ldy #4  ; there will be 5 digits
NextDigit
    ldx #16 ; 16-bit dividee so Rotate 16 times
    lda #$00
Rotate000
    aslw decimal
    rol  ; scroll dividee
    ; (as highest byte - additional - byte is A)
    cmp #10  ; divider
    bcc TooLittle000 ; if A is smaller than divider
    ; there is nothing to substract
    sbc #10  ; divider
    inc decimal     ; lowest bit set to 1
    ; because it is 0 and this is the fastest way
TooLittle000 dex
    bne Rotate000 ; and Rotate 16 times, Result will be in decimal
    tax  ; and the rest in A
    ; (and it goes to X because
    ; it is our decimal digit)
    lda digits,x
    sta decimalresult,y
    dey
    bpl NextDigit ; Result again /10 and we have next digit

;rightnumber
    ; displaying without leading zeroes (if zeroes exist then display space at this position)
    ldy #0
    ldx #0    ; digit flag (cut leading zeroes)
displayloop
    lda decimalresult,y
    cpx #0
    bne noleading0
    cpy #4
    beq noleading0    ; if 00000 - last 0 must stay
    cmp zero
    bne noleading0
    lda #space
    beq displaychar    ; space = 0 !
noleading0
    inx        ; set flag (no leading zeroes to cut)
displaychar
    sta (displayposition),y
nexdigit
    iny
    cpy #5
    bne displayloop

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
    mvx #$ff RMT_blocked
    ldx #<MODUL                ; low byte of RMT module to X reg
    ldy #>MODUL                ; hi byte of RMT module to Y reg
    jsr RASTERMUSICTRACKER     ; Init
    mva #0 RMT_blocked
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
LevelType
    .byte 0 ; level type $00 - first level, $01 - level from buffer, $ff - title screen  
Numbers
    .byte '0123456789'
digits
zero
    .byte "0123456789"
space = 0
    .byte " "
decimal
    .word 0
decimalresult
    .byte "     "
lineAdrL
    :margin .byte <marginLine ;8 lines of margin space
    :maxLines .byte <(display+screenBytes*#)
    :256-maxLines-1*margin .by <marginLine  ; (display+40*#) ;just to let the plot smear on full .byte ypos
lineAdrH
    :margin .byte >marginLine
    :maxLines .byte >(display+screenBytes*#)
    :256-maxLines-1*margin .by >marginLine  ; (display+40*#) ;just to let the plot smear on full .byte ypos
bittable
    .byte %11110000
debittable
    .byte %00001111
    .byte %11110000
RNColtable ; Right Nibble color Table
    .byte %00000000
    .byte %00000001
    .byte %00000010
    .byte %00000011
    .byte %00000100
    .byte %00000101
    .byte %00000110
    .byte %00000111
    .byte %00001000
LNColtable ; Left Nibble color Table
    .byte %00000000
    .byte %00010000
    .byte %00100000
    .byte %00110000
    .byte %01000000
    .byte %01010000
    .byte %01100000
    .byte %01110000
    .byte %10000000
;--------------------------------
clear_vars_start
    ; PUT VARS HERE
clear_vars_end
;--------------------------------
statusBar
    dta d"rc$"
hexDump
    dta d"   dx$"
dxDisp
    dta d"   dy$"
dyDisp
    dta d"   balls$"
ballDisp
    dta d"  "
marginLine  .ds screenBytes
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
