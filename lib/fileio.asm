.IF *>0 ;this is a trick that prevents compiling this file alone

;--------------------------------------------------
.proc open
;--------------------------------------------------
; OPEN #1,4,0,"D:LEVEL000.DAT"
 
    ldx #$10            ;IOCB #1
    lda #$03            ;komenda: OPEN
    sta ICCOM,x
    lda #<fname         ;adres nazwy pliku
    sta ICBAL,x
    lda #>fname
    sta ICBAH,x
    lda #04             ;kod dostępu: $04 odczyt, $08 zapis, $09 dopisywanie, $0c odczyt/zapis
    sta ICAX1,x
    lda #$00            ;dodatkowy parametr, $00 jest zawsze dobre
    sta ICAX2,x 
    jmp ciov
.endp
;--------------------------------------------------
.proc bget 
;--------------------------------------------------
; BGET #1,LevelFileBuff,LevelFileBuffLen-2

    ldx #$10            ;IOCB #1
    lda #$07            ;komenda: GET BYTES / BINARY READ
    sta ICCOM,x
    lda #<LevelFileBuff        ;adres w pamieci, gdzie maja trafic dane
    sta ICBAL,x
    lda #>LevelFileBuff
    sta ICBAH,x
    lda #<(LevelFileBuffLen-2)        ;wielkosc bloku danych w bajtach
    sta ICBLL,x
    lda #>(LevelFileBuffLen-2)
    sta ICBLH,x
    jmp ciov
.endp
;--------------------------------------------------
.proc close 
;--------------------------------------------------
; CLOSE #1
    ldx #$10            ;IOCB #1
    lda #$0c            ;komenda: CLOSE
    sta ICCOM,x
    jmp ciov
.endp


.ENDIF