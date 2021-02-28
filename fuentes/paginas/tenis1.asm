turbo	= $b3
B00600 = $05CC  ;TIMER 600 BPS
B00800 = $0457  ;TIMER 800 BPS
	org $D301
	.BY $FE
	org $BC20
	.BY 1
	.WO NEWDL
VOLVERE
	org  $BB00
NEWDL
	.BY 112,112,66
	.WO LINE0
	.BY 48,1
	.WO VOLVERE
LINE0
	.SB +128,"  CON "
	.sb "S"
	.sb +128,"ubrutina    C-"
C?
	.SB +128,"000 SIN "
	.sb "R"
	.sb +128,"eset  "
MENSAJE.TV
		.SB +128,"    "
CON 	.SB +128,"CON"
SIN 	.SB +128,"SIN"
SECTOR	.BY "000",$9B
FACTOR	.BY "2.3",$9B
	org $8000
MENSAJE.NTSC
	.SB +128,"NTSC"
MENSAJE.PAL
	.SB +128,"PAL "
EORBYTE 	.BY $00
BYTEMULA	.BY $00
CANTR 		.WO $4000
CANTW 		.WO $4000
LASTCANT 	.WO $4000
DESDE	= $0C
HASTA = $0E
FRO =   $D4
RAM =   $CB
ROM =   $CD
FEOR .BYTE 0
FEOF .BYTE 0
BANCO .BYTE 0
GUARDABANCO .BYTE 0
SUB
	JSR USERSUB+Z
SINRES
	JMP $0392
CONRES
	JMP ($FFFC)
;SET =   PROGRAMA-RAMPROG
STRING
	.BY "D1:"
;0560 NOMBRE
;0570     org  *+20
nombre
:20	.sb " "
PABONITO
	.SB "000  BLOQUES A GRABAR "
GRABAMULA
	LDX #$08
	LDY PALNTS
	BEQ GRABAMULA.1
	DEX
GRABAMULA.1
	JSR GRABAMULA.WAIT
	LDA #139
	STA $D20F
	LDX #8
;   STA BYTEMULA
	LDY PALNTS
	BEQ GRABAMULA.2
	DEX
GRABAMULA.2
	JSR GRABAMULA.WAIT
	LDA #11
	STA $D20F
	LDX #16
	LDY PALNTS
;   JSR LINEA10?
	BEQ GRABAMULA.3
	LDX #13
GRABAMULA.3
	JSR GRABAMULA.WAIT
	LDA #139
	STA $D20F
	LDX #47
	LDY PALNTS
	BEQ GRABAMULA.4
;   LDA #163
	LDX #39
GRABAMULA.4
	JSR GRABAMULA.WAIT
	LDA #11
	STA $D20F
	RTS
;
;
;
;   STA $D20F
;   JSR LINEA10?
;   LDX #$07
LOOPMULA
;   LDA #163
;   ASL BYTEMULA
;   BCC MULA0
;   LDA #35
MULA0
;   STA $D20F
;   JSR LINEA10?
;   DEX
;   BPL LOOPMULA
;   LDA #35
;   STA $D20F
;   RTS
GRABAMULA.WAIT
	JSR LINEA10?
	DEX
	BNE GRABAMULA.WAIT
	RTS
;
; ESPERA X BARRIDOS
;
;
LINEA10?
	LDA $D40B
	CMP #10
	BNE LINEA10?
	STA $D40A
	STA $D40A
	RTS
;BAUD.600
;	LDA # <B00600
;	JSR BAUD.M1
;	LDA # >B00600
;	JMP BAUD.M2
;BAUD.800
;	LDA # <B00800
;	JSR BAUD.M1
;	LDA # >B00800
;BAUD.M2
;	STA $EBA8
;	STA $FD46
;	STA $FCE1
;	RTS
;BAUD.M1
;	STA $EBA3
;	STA $FD41
;	STA $FCDC
;	RTS
EOREO
	LDY #$00
	LDA (DESDE),Y
	EOR EORBYTE
	STA (DESDE),Y
	INC DESDE
	BNE NOINCDESDE1
	INC DESDE+1
NOINCDESDE1
	LDA DESDE+1
	CMP HASTA+1
	BNE EOREO
	LDA DESDE
	CMP HASTA
	BNE EOREO
	RTS
BANQUEO
	ORA #$08
	CLC
	ROL A
	ROL A
	PHA
	LDA #$C3
	AND $D301
	STA $D301
	PLA
	ORA $D301
	AND #$FE
	STA $D301
	RTS
SUBCLOSE
;	close1
	ldx #$10
	lda #$0c
	sta $0342,x
	jsr $e456
	RTS
SUBOPEN
;	OPEN  1,4,128,STRING
	ldx #$10
	lda #$03
	sta $0342,x
	lda #$04
	sta $034a,x
	lda #$80
	sta $034b,x
	lda #$1d
	sta $0344,x
	lda #$80
	sta $0345,x
	jsr $e456
	BPL OPENOK
	JSR SUBCLOSE
	JSR SUBDIRECTORIO
	JMP SUBOPEN
OPENOK
	RTS
SUBBGET
;	BGET  1,$4000,CANTR
	ldx #$10
	lda #$07
	sta $0342,x
	lda #$00
	sta $0344,x
	lda #$40
	sta $0345,x
	lda cantr
	sta $0348,x
	lda cantr+1
	sta $0349,x
	jsr $e456	
	RTS
SUBREAD
	JSR SUBOPEN
	LDA #$04
	STA BANCO
LOOPBANCOS
	DEC BANCO
	LDA BANCO
	JSR BANQUEO
	JSR SUBBGET
	LDA 856	;$0358
	CMP CANTR
	BNE FINCARGA
	LDA 857
	CMP CANTR+1
	BEQ LOOPBANCOS
FINCARGA
	LDA BANCO
	STA GUARDABANCO
	LDA 856
	STA LASTCANT
	STA FRO
	LDA 857
	STA LASTCANT+1
	STA FRO+1
	LDX #$02
	LDA #$90	;'0-32
VUELVEA0
	STA PABONITO,X
	LDY FEOR
	BEQ NOEORFF
	EOR #$FF
NOEORFF
	STA TENMEBLK,X
	DEX
	BPL VUELVEA0
	LDX #$03
CALCULOASC
	CPX GUARDABANCO
	BEQ NOFINCALCULO
	CLC
	LDA FRO
	ADC CANTR
	STA FRO
	LDA FRO+1
	ADC CANTR+1
	STA FRO+1
	DEX
	BPL CALCULOASC
	NOFINCALCULO
	LDY #$01
	LDA FRO
	AND #$7F
	BEQ FINCALCULO
	INY
FINCALCULO
	LDX #$06
LOOPFINCALCULO
	LSR FRO+1
	ROR FRO
	DEX
	BPL LOOPFINCALCULO
	CLC
	TYA
	ADC FRO
	STA FRO
	LDA FRO+1
	ADC #$00
	STA FRO+1
	JSR $D9AA
	JSR $D8E6
	LDY #$00
LOOPPOSITIVO
	LDA ($F3),Y
	BMI ESNEGATIVO
	INY
	BPL LOOPPOSITIVO
ESNEGATIVO
	SEC
	SBC #32
	STA PABONITO+2
	LDX FEOR
	BEQ NOEORFF1
	EOR #$FF
NOEORFF1
	STA TENMEBLK+2
	DEY
	BMI NOQUEDANMAS
	LDA ($F3),Y
	ORA #$80
	SEC
	SBC #32
	STA PABONITO+1
	LDX FEOR
	BEQ NOEORFF2
	EOR #$FF
NOEORFF2
	STA TENMEBLK+1
	DEY
	BMI NOQUEDANMAS
	LDA ($F3),Y
	EOR #$80
	SEC
	SBC #32
	STA PABONITO
	LDX FEOR
	BEQ NOEORFF3
	EOR #$FF
NOEORFF3
	STA TENMEBLK
NOQUEDANMAS
	JMP SUBCLOSE
SUBDIRECTORIO
	LDA #$7d	;'}
	JSR PRINTBYTE
	;OPEN  1,6,0,"D:*.*"
	LDX #$10
	LDA #$03
	STA $0342,X
	LDA #$06
	STA $034A,X
	LDA #$00
	STA $034B,X
ALL
	.BY 'D:*.*'		;REPARAR
	.BY 0			;
?SUBDIRECTORIO
	LDA #<ALL
	STA $0344,X
	LDA #>ALL
	STA $0345,X
	JSR $E456
DIRECTORIO
	ldx #$10
	lda #$05
	sta $0342,x
	lda #$20
	sta $0344,x
	lda #$80
	sta $0345,x
	lda #$FF
	sta $0348,x
	lda #$00
	sta $0349,x
	jsr $e456
;	INPUT  1,NOMBRE
	BMI FINDIRECTORIO
;	PRINT  0,NOMBRE
	ldx #$00
	lda #$09
	sta $0342,x
	lda #$20
	sta $0344,x
	lda #$80
	sta $0345,x
	lda #$FF
	sta $0348,x
	lda #$00
	sta $0349,x
	jsr $e456
	JMP DIRECTORIO
FINDIRECTORIO
	JSR SUBCLOSE
	LDA #$9B
	JSR PRINTBYTE
	LDA #$9B
	JSR PRINTBYTE
;	PRINT  0,"  ELIJA FILE A GRABAR!"
PELIJA
	.BY "  ELIJA FILE A GRABAR!",$9B
PRINT
	ldx #$00
	lda #$09
	sta $0342,x
	lda #<PELIJA
	sta $0344,x
	lda #>PELIJA
	sta $0345,x
	lda #$17
	sta $0348,x
	lda #$00
	sta $0349,x
	jsr $e456
	LDA #$FF
	JSR BANQUEO
	LDX #19
	LDA #$00
SINNOMBRE
	STA NOMBRE,X
	DEX
	BPL SINNOMBRE
TOMEFILE
	LDA $58
	STA $00
	LDA $59
	STA $01
INVIERTA
	JSR INVERSO
QUEAPRETO?
	LDA #$FF
	STA 764
WTECLA
	LDA 764
	CMP #$FF
	BEQ WTECLA
	CMP #28
	BNE NOOTRO
	RTS
NOOTRO
	CMP #62
	BNE NOCSUB
	LDX #$00
	LDY #$02
	LDA LINE0,Y
	CMP #$A3	;'C-32
	BEQ PONSINSUB
PONCONSUB
	LDA CON,X
	STA LINE0,Y
	LDA SUB,X
	BIT FEOR
	BEQ NOEOR29A
	EOR #$29
NOEOR29A
	STA CONSUBRUTINA,X
	INY
	INX
	CPX #$03
	BNE PONCONSUB
	BEQ QUEAPRETO?
PONSINSUB
	LDA SIN,X
	STA LINE0,Y
	LDA #$EA
	BIT FEOR
	BEQ NOEOR29B
	EOR #$29
NOEOR29B
	STA CONSUBRUTINA,X
	INY
	INX
	CPX #$03
	BNE PONSINSUB
	BEQ QUEAPRETO?
NOCSUB
	CMP #40
	BNE NOCRES
	LDX #$00
;   LDY #28
	LDY #25
	LDA LINE0,Y
	CMP #$A3	;'C-32
	BEQ PONSINRES
PONCONRES
	LDA CON,X
	STA LINE0,Y
	LDA CONRES,X
	BIT FEOR
	BEQ NOEOR29C
	EOR #$29
NOEOR29C
	STA SINRESET,X
	INY
	INX
	CPX #$03
	BNE PONCONRES
	JMP QUEAPRETO?
PONSINRES
	LDA SIN,X
	STA LINE0,Y
	LDA SINRES,X
	BIT FEOR
	BEQ NOEOR29D
	EOR #$29
NOEOR29D
	STA SINRESET,X
	INY
	INX
	CPX #$03
	BNE PONSINRES
	JMP QUEAPRETO?
NOCRES
	CMP #15
	BNE NOUPALE
	JSR INVERSO
	CLC
	LDA $00
	ADC #40
	STA $00
	LDA $01
	ADC #$00
	STA $01
	LDY #$03
	LDA ($00),Y
	BEQ NOTOMEFIL
	JMP TOMEFILE
NOTOMEFIL
	JMP INVIERTA
NOUPALE
	CMP #14
	BNE NOBAJALE
	JSR INVERSO
	LDA $00
	CMP $58
	BNE BAJE
	LDA $01
	CMP $59
	BNE BAJE
	JMP TOMEFILE
BAJE
	SEC
	LDA $00
	SBC #40
	STA $00
	LDA $01
	SBC #$00
	STA $01
	JMP INVIERTA
NOBAJALE
	CMP #12
	BEQ ELCOK
	JMP QUEAPRETO?
ELCOK
	JSR INVERSO
	LDY #$04
	LDX #$00
ESTAFILE
	LDA ($00),Y
	BEQ PUNTO
	CLC
	ADC #$20
	STA NOMBRE,X
	INX
	INY
	CPY #$0C
	BNE ESTAFILE
PUNTO
	LDY #$0C
	LDA #$2e	;'.
	STA NOMBRE,X
	INX
LOPUNTO
	LDA ($00),Y
	BEQ FINPUNTO
	CLC
	ADC #$20
	STA NOMBRE,X
	INX
	INY
	CPY #$0F
	BNE LOPUNTO
FINPUNTO
	RTS
INVERSO
	LDY #$0F
LOINVIERTO
	LDA ($00),Y
	EOR #$80
	STA ($00),Y
	DEY
	CPY #$03
	BNE LOINVIERTO
	LDY #$02
	LDA #$90	;'0-32
BORREC
	STA C?,Y
	DEY
	BPL BORREC
	LDY #$10
	LDX #$00
TOMENUM
	LDA ($00),Y
	CLC
	ADC #$20
	STA SECTOR,X
	INY
	INX
	CPX #$03
	BNE TOMENUM
	LDA # <FACTOR
	STA $F3
	LDA # >FACTOR
	STA $F4
	LDA #$00
	STA $F2
	JSR $D800
	BCC NOC1000
	JMP C1000?
NOC1000
	JSR $DDB6
	LDA # <SECTOR
	STA $F3
	LDA # >SECTOR
	STA $F4
	LDA #$00
	STA $F2
	SR $D800
	BCS C1000?
	JSR $DADB
	BCS C1000?
	JSR $DDB6
	LDA #87
	STA $D4
	LDA #$00
	STA $D5
	JSR $D9AA
	JSR $DA66
	JSR $DDB6
	LDA #30
	STA $D4
	LDA #$00
	STA $D5
	JSR $D9AA
	LDY #$05
FR1FR0
	LDA $D4,Y
	PHA
	LDA $E0,Y
	STA $D4,Y
	PLA
	STA $E0,Y
	DEY
	BPL FR1FR0
	JSR $DB28
	BCS C1000?
	JSR $D9D2
	BCS C1000?
	INC $D4
	BNE NOINCD5
	INC $D5
NOINCD5
	JSR $D9AA
	JSR $D8E6
	LDY #$00
ESASC?
	LDA ($F3),Y
	BMI FINASC
	INY
	BNE ESASC?
FINASC
	LDA ($F3),Y
	SEC
	SBC #32
	STA C?+2
	DEY
	BMI C1000?
	LDA ($F3),Y
	SEC
	SBC #32
	ORA #$80
	STA C?+1
	DEY
	BMI C1000?
	LDA ($F3),Y
	SEC
	SBC #32
	ORA #$80
	STA C?
C1000?
5321     RTS
5322 NO.IRG
5323     LDX #$04
5324     LDA #$EA    ;NOP
5325 NO.IRG.LOOP
5326     STA $EBC6,X
5327     DEX
5328     BPL NO.IRG.LOOP
5329     RTS
5330 SI.IRG
5331     LDX #$04
5332 SI.IRG.LOOP
5333     LDA SI.IRG.TABLA,X
5334     STA $EBC6,X
5335     DEX
5336     BPL SI.IRG.LOOP
5337     RTS
5338 SI.IRG.TABLA
5339     .BYTE $AD,$17,$03,$D0,$FB
5340 IRG.100
5341     LDA #$06
5342     STA $EE11
5343     STA $EE15
5344     LDA #$05
5345     STA $EE12
5346     STA $EE16
5347     RTS
5349 INICIOPROGRAMA
5350     LDA #$00
5360     STA FEOR
5370     LDA #$FE
5380     STA $D301
5390     STA $0244
5400     LDA #112
5410     STA 16
5420     STA 53774
5421     LDA #$03
5422     STA $FE8D
5423     LDA #$02
5424     STA $FE8E
5425     LDA #$0C
5426     STA $FE8F
5427     LDA #$8A
5428     STA $FE90
5429 ; QUEDAMOS CON IRG DE 14 SEGUNDOS
5430 ;   LDA #$EA
5440 ;   STA 64881
5450 ;   STA 64882
5451     JSR IRG.100
5457 ;
5458 ; IRG CORTO DE 100 MILISEGUNDOS
5459 ;
5460     LDA #$60
5470     STA 65020   ; NO BEEP BEEP!
5471     LDA #$34
5472     STA $FDD7   ; NO APAQUE MOTOR!
5480     LDA #$00
5490     STA 710
5500     LDA #1
5510     STA 752
5511     JSR DETECTA.PAL ;A DETECTAR PAL
!
5512     LDX #$03
5513 INICIOPROGRAMA.LOOP
5514     LDA MENSAJE.NTSC,X
5515     LDY PALNTS
5516     BEQ INICIOPROGRAMA.LOOP2
5517     LDA MENSAJE.PAL,X
5518 INICIOPROGRAMA.LOOP2
5519     STA MENSAJE.TV,X
5520     DEX
5521     BPL INICIOPROGRAMA.LOOP
5529 ;   LDX #4
5530 ;   LDA #$EA
5540 ;LOOPIRG1
5550 ;   STA $EBC6,X
5560 ;   DEX
5570 ;   BPL LOOPIRG1
5575     JSR NO.IRG
5580     LDA #TURBO
5590     STA $CF
5600 CAMBIADISCO
5610      PRINT  0,"}  INGRESE DISCO CON
 FILE A GRABAR"
5620     LDA #$FF
5630     STA 764
5640     JSR GETBYTE
5650     JSR SUBDIRECTORIO
5660     JSR SUBREAD
5670 OTRACOPIA
5680      PRINT  0,"}   RETURN PARA COME
NZAR GRABACION"
5690     LDY #130
5700     LDX #0
5710 LOOPBONITO
5720     LDA PABONITO,X
5730     STA ($58),Y
5740     INY
5750     INX
5760     CPX #21
5770     BNE LOOPBONITO
5780     LDY #216
5790     LDX #$00
5800 BELLO
5810     LDA NOMBRE,X
5820     SEC
5830     SBC #$20
5840     BMI FINBELISIMO
5850     STA ($58),Y
5860     INY
5870     INX
5880     BNE BELLO
5890 FINBELISIMO
5900     LDA #$FF
5910     STA 764
5920     JSR GETBYTE
5930     CMP #'?
5940     BNE NOCAMBIADISCO
5950     JMP CAMBIADISCO
5960 NOCAMBIADISCO
5970     LDA #'}
5980     JSR $F2B0
5990     LDY #215
6000     LDX #$00
6010 NUMEROSCREEN
6020     LDA PABONITO,X
6030     STA ($58),Y
6040     INY
6050     INX
6060     CPX #$03
6070     BNE NUMEROSCREEN
6080     INY
6090 NOMBRESCREEN
6100     LDA STRING,X
6110     SEC
6120     SBC #$20
6130     BMI ENDNAME
6140     STA ($58),Y
6150     INX
6160     INY
6170     BNE NOMBRESCREEN
6180 ENDNAME
6190     LDX #$08
6200 NUEVEBLKS
6210     LDY #217
6220 NUEVEBLKS1
6230     LDA ($58),Y
6240     CLC
6250     ADC #$01
6260     CMP #'9-31
6270     BEQ NUEVE9
6280     STA ($58),Y
6290     DEX
6300     BPL NUEVEBLKS
6310     BMI FINNUEVE
6320 NUEVE9
6330     LDA #'0-32
6340     STA ($58),Y
6350     DEY
6360     CPY #214
6370     BNE NUEVEBLKS1
6380 FINNUEVE
6390     LDA #$FF
6400     JSR BANQUEO
6401     LDA #$D0
6402     STA $FD71
6403     LDA #$F7
6404     STA $FD72   ; HABILITA LEAD
6410     JSR GRABABLKUNO
6411     LDA #$EA
6412     STA $FD71
6413     STA $FD72   ; DESHABILITA LEAD
6414     LDA #$00-210
6415     LDX PALNTS
6416     BEQ BLKUNO.NTSC
6417     LDA #$00-175
6418 BLKUNO.NTSC
6419     STA 20
6420 BLKUNO.LOOP
6421     LDA 20
6422     BNE BLKUNO.LOOP
6429     LDA #$00
6430     STA 20
6440     STA $0480
6450     STA $0481
6460     STA FEOF
6470     LDA # <FIN-GAMEA
6480     STA CANTW
6490     LDA # >FIN-GAMEA
6500     STA CANTW+1
6510     JSR WRITETOCASSETTE
6520 ;   LDA #$00-8
6521     LDA #$00-156
6522     LDX PALNTS
6523     BEQ BLK2.NTSC
6524     LDA #$00-130
6525 BLK2.NTSC
6530     STA 20
6540 W1SEG
6550     LDA 20
6560     BNE W1SEG
6570     LDA #$10
6580     STA 20
6590     LDA #1
6600     STA FEOF
6610     LDA CANTR
6620     STA CANTW
6630     LDA CANTR+1
6640     STA CANTW+1
6650     LDA #$04
6660     STA BANCO
6670     JSR WRITETOCASSETTE
6680 ;   LDA #$00-8
6681     LDA #$00-52
6682     LDY PALNTS
6683     BEQ LOPLEAD1.NTSC
6684     LDA #$00-43
6685 LOPLEAD1.NTSC
6690     STA 20
6700 LOPLEAD1
6710     LDA 20
6720     BNE LOPLEAD1
6730     LDY #$02
6740 SAVEC0LENTO
6741     TYA
6742     PHA
6750     LDA #$C0
6760     JSR GRABAMULA
6761     PLA
6762     TAY
6770     DEY
6780     BPL SAVEC0LENTO
6781     LDA #10
6782     STA 20
6783 FINAL.LOOP
6784     LDA 20
6785     BNE FINAL.LOOP
6786 ; LE DAMOS TIEMPO PARA QUE CIERRE E
L ARCHIVO.
6787 ;
6788     LDA #$3C
6789     STA $D302
6790     JMP OTRACOPIA
6800 WRITETOCASSETTE
6810     JSR $FD34
6820 LEADERTIME
6830     LDA 20
6840     CMP #$20
6850     BCC LEADERTIME
6860     LDA FEOF
6870     BEQ NOLASTBANCO
6880 GRABANDOP02
6890     DEC BANCO
6900     LDA BANCO
6910     PHA
6920     JSR BANQUEO
6930     PLA
6940     CMP GUARDABANCO
6950     BNE NOLASTBANCO
6960     LDA LASTCANT
6970     STA CANTW
6980     LDA LASTCANT+1
6990     STA CANTW+1
7000     LDA #$FF
7010     STA FEOF
7020 NOLASTBANCO
7030     LDA # <$4000
7040     STA $00
7050     LDA # >$4000
7060     STA $01
7070     LDA #$00
7080     STA $02
7090     STA $03
7100 WRITECASSETTE
7110     LDA $D01F
7120     CMP #$03
7130     BNE SIGAGRBANDO
7140     JMP $FDD6
7150 SIGAGRBANDO
7151     JSR SI.IRG
7160     LDY #$00
7170     LDA ($00),Y
7180     JSR $FDB4
7190     BNE NONUEVOBLK
7191     JSR NO.IRG
7200     LDY #135
7210 BUFSCREEN
7220     LDA $03FF,Y
7230     STA ($58),Y
7240     DEY
7250     BNE BUFSCREEN
7260     LDY #217
7270     LDX #$02
7280 DECBELLO
7290     LDA ($58),Y
7300     SEC
7310     SBC #$01
7320     CMP #'0-33
7330     BEQ NINEBELLO
7340     STA ($58),Y
7350     BNE FINBELLO
7360 NINEBELLO
7370     LDA #'9-32
7380     STA ($58),Y
7390     DEY
7400     DEX
7410     BPL DECBELLO
7420 FINBELLO
7430     INC $0480
7440     BNE NONUEVOBLK
7450     INC $0481
7460 NONUEVOBLK
7470     INC $00
7480     BNE NOINCHIBIS
7490     INC $01
7500 NOINCHIBIS
7510     INC $02
7520     BNE NOINCHIS
7530     INC $03
7540 NOINCHIS
7550     LDA $03
7560     CMP CANTW+1
7570     BNE WRITECASSETTE
7580     LDA $02
7590     CMP CANTW
7600     BNE WRITECASSETTE
7610     LDA FEOF
7620     BEQ FINP01
7630     BMI FINP01
7640     JMP GRABANDOP02
7650 FINP01
7660     LDX $3D
7670     BEQ TERMINOWRITE
7680     LDY #$7F
7690 POKEANDOESPERO
7700     STY $D40A
7710     DEY
7720     BNE POKEANDOESPERO
7730     STX $047F
7740     LDA #$FA
7750     JSR $FE7C
7760 TERMINOWRITE
7770     INC $0480
7780     BNE NOINC481
7790     INC $0481
7800 NOINC481
7810     LDA FEOF
7820     BNE SIEOF
7830     JMP $FDD6
7840 SIEOF
7850     LDX #$7F
7860     LDA #$00
7870 FILLBUFFER
7880     STA $0400,X
7890     STA $D40A
7900     DEX
7910     BPL FILLBUFFER
7920     LDA #$FE
7930     JSR $FE7C
7940     JMP $FDD6
7950     *=  $02E0
7960     .WORD INICIOPROGRAMA
7970 EORLEN = FINFIRST-AEOREAR+1
7980 ADR =   $0380-3
7990 RESTABYTE = $03FF
8000 DIF =   $A000-ADR
8010     *=  ADR+DIF
8020 AGRABAR
8030     .BYTE $55,$55
8040     .BYTE $FA
8050 BLKUNO
8060     .BYTE $00
8070     .BYTE $01
8080     .WORD *-2-DIF
8090     .WORD $E456
8100     LDX #EORLEN
8110     TXS
8120 EORLOOP
8130     SEC
8140     LDA AEOREAR-DIF,X
8150     TAY
8160     SBC RESTABYTE
8170     STY RESTABYTE
8180     PHA
8190     DEX
8200     BPL EORLOOP
8210     RTS
8220 AEOREAR
8230     .BYTE $01
8240     .BYTE $01
8250     LDX #$01
8260     STX $0244
8270     DEX
8280     STX $022F
8290     STX $D400
8300     STX $41
8310 RELOS
8320     LDX #$00-20
8330     STX 20
8340 ESPERASINCRO
8350     LDA $D20F
8360     AND #$10
8370     BNE RELOS
8380     LDX 20
8390     BNE ESPERASINCRO
8400 TERMINA0
8410     LDA $D20F
8420     AND #$10
8430     BEQ TERMINA0
8440     LDX #$0B
8450 TRANSFER
8460     LDA DATIX1-DIF,X
8470     STA $0300,X
8480     DEX
8490     BPL TRANSFER
8500     JSR $E459
8510     LDX #$FF
8520     TXS
8530     JMP ($0304)
8540 FINFIRST
8550     PLA
8560     RTI
8570 DATIX1
8580     .BYTE $60
8590     .BYTE $00
8600     .BYTE $52
8610     .BYTE $40
8620     .WORD BLKFALSO
8630     .BYTE $23
8640     .BYTE $00
8650     .WORD FINBLKFALSO-BLKFALSO
8660     .BYTE $00
8670     .BYTE $80
8680     *=  $03EA+DIF
8690     .BYTE $00
8700     *=  AGRABAR+$84
8710 GRABABLKUNO
8720     LDA FEOR
8730     BEQ EORNOLISTO
8740     JMP EORLISTO
8750 EORNOLISTO
8760     LDA # <EORBLOCK
8770     STA DESDE
8780     LDA # >EORBLOCK
8790     STA DESDE+1
8800     LDA # <FINBLKFALSO
8810     STA HASTA
8820     LDA # >FINBLKFALSO
8830     STA HASTA+1
8840     LDA #$46
8850     STA EORBYTE
8860     JSR EOREO
8870     LDA # <EORBLOCK1
8880     STA DESDE
8890     LDA # >EORBLOCK1
8900     STA DESDE+1
8910     LDA # <FINBLKDOS
8920     STA HASTA
8930     LDA # >FINBLKDOS
8940     STA HASTA+1
8950     LDA #$FF
8960     STA EORBYTE
8970     JSR EOREO
8980     LDA # <GAME1A
8990     STA DESDE
9000     LDA # >GAME1A
9010     STA DESDE+1
9020     LDA # <FIN
9030     STA HASTA
9040     LDA # >FIN
9050     STA HASTA+1
9060     LDA #$29
9070     STA EORBYTE
9080     JSR EOREO
9090     LDX #EORLEN
9100     STX FEOR
9110 EORLOOP1
9120     CLC
9130     LDA AEOREAR,X
9140     ADC SUMABYTE
9150     STA SUMABYTE
9160     STA AEOREAR,X
9170     DEX
9180     BPL EORLOOP1
9190     LDA #0
9200     STA CHKSUM
9210     LDX #$82
9220     LDA #$01
9230     STA AGRABAR,X
9240 ADCHKSUM
9250     LDA AGRABAR,X
9260     CLC
9270     ADC CHKSUM
9280     ADC #0
9290     STA CHKSUM
9300     DEX
9310     CMP #$FF
9320     BNE ADCHKSUM
9330     LDX #$83
9340     STA BLKUNO,X
9350 EORLISTO
9351     JSR BAUD.600
9360     JSR $FD34   ; GRABA LEADER
9370     CLC
9371     LDA #100
9372     LDX PALNTS
9373     BEQ LEADER.NTSC
9374     LDA #83
9375 LEADER.NTSC
9376     ADC 20
9380 ;   LDA 20
9390 ;   ADC #100
9400 WLEADERTIME
9410     CMP 20
9420     BNE WLEADERTIME
9430     LDX #$0B
9440 ?LOOP
9450     LDA DATA1,X
9460     STA $0300,X
9470     DEX
9480     BPL ?LOOP
9490     JSR $E459   ; GRABA PRIMER BLOQ
UE
9495     JSR BAUD.800
9500     CLC
9501     LDA #$0F    ; 0.25 SEC NTSC
9502     LDX PALNTS
9503     BEQ PRIMERBLOQUE.NTSC
9504     LDA #$0C    ; 0.25 SEC PAL
9505 PRIMERBLOQUE.NTSC
9506     ADC 20
9510 ;   LDA 20
9520 ;   ADC #$0F
9530 ESPERIX
9540     CMP 20
9550     BNE ESPERIX
9560     JSR GRABATRAMPA
9570     CLC
9580     LDA 20
9590     ADC #$0F
9600 WFALSO
9610     CMP 20
9620     BNE WFALSO
9630     LDX #$0B
9640 SAVEFALSO
9650     LDA DATAFALSA,X
9660     STA $0300,X
9670     DEX
9680     BPL SAVEFALSO
9690     JSR $E459
9700     CLC
9701     LDA #40
9702     LDX PALNTS
9703     BEQ WFORIRGTIME.NTSC
9704     LDA #33
9705 WFORIRGTIME.NTSC
9706     ADC 20
9710 ;   LDA 20
9720 ;   ADC #6
9730 WFORIRGTIME
9740     CMP 20
9750     BNE WFORIRGTIME
9760     LDX #$0B
9770 ?LOOP1
9780     LDA DATA2,X
9790     STA $0300,X
9800     DEX
9810     BPL ?LOOP1
9820     JSR $E459
9830 ;   LDA #60
9831     LDA #$34
9840     STA 54018
9850     RTS
9860 CHKSUM
9870     .BYTE 0
9880 DATA1
9890     .BYTE $60,0,$57,$80
9900     .WORD AGRABAR
9910     .BYTE $23,0
9920     .WORD $83
9930     .BYTE 0,$80
9940 DATA2
9950     .BYTE $60,0,$57,$80
9960     .WORD BLKDOS
9970     .BYTE $23,0
9980     .WORD FINBLKDOS-BLKDOS
9990     .BYTE 0
010000   .BYTE $80
010010 DATAFALSA
010020   .BYTE $60,0,$57,$80
010030   .WORD BLKFALSO
010040   .BYTE $23,0
010050   .WORD FINBLKFALSO-BLKFALSO
010060   .BYTE 0,$80
010070 SUMABYTE
010080   .BYTE $FA
010090   *=  $7000-4
010100 TRAMPA
010110   .BYTE $55,$55,$FC
010120   .BYTE $01
010130   .WORD $7000
010140   .WORD $E456
010150   LDA #$00
010160   LDY #$02
010170   STA ($58),Y
010180   STA 710
010190   STA $41
010200   LDX #$10
010210   LDA #$03
010220   STA $02EC,X
010230   STA $0342,X
010240   LDA #$04
010250   STA $034A,X
010260   LDA #$80
010270   STA $034B,X
010280   LDA # <$C431
010290   STA $0344,X
010300   LDA # >$C431
010310   STA $0345,X
010320   JSR $E456
010330   LDA #$00
010340   STA $0344,X
010350   STA $0348,X
010360   LDA #$07
010370   STA $0345,X
010380   LDA #$06
010390   STA $0349,X
010400   LDA #$07
010410   STA $0342,X
010420   JSR $E456
010430   DEY
010440 LOOPTRAMPA
010450   LDA $0700,Y
010460   EOR $0800,Y
010470   STA $0700,X
010480   DEY
010490   BNE LOOPTRAMPA
010500   LDA # <DLTRAMPA+2
010510   STA 560
010520   LDA # >DLTRAMPA+2
010530   STA 561
010540   JMP $0700
010550 DLTRAMPA
010560   .BYTE 112,112,112,64+6
010570   .WORD TEXTOTRAMPA+2
010580   .BYTE 65
010590 TEXTOTRAMPA
010600   .SBYTE "    turbo SOFTWARE
"
010610   *=  $707F
010620 CHEQUEO
010630   .BYTE 0
010640 FCHK
010650   .BYTE 0
010660 GRABATRAMPA
010670   LDA FCHK
010680   BNE CHEQUEOK
010690   INC FCHK
010700   LDA #$00
010710   STA CHEQUEO
010720   LDX #$82
010730 CHKTRAMPA
010740   LDA TRAMPA,X
010750   CLC
010760   ADC #$00
010770   ADC CHEQUEO
010780   STA CHEQUEO
010790   DEX
010800   CPX #$FF
010810   BNE CHKTRAMPA
010820   LDX #$83
010830   STA TRAMPA,X
010840 CHEQUEOK
010850   LDX #$0B
010860 LOOPTRAMPIX
010870   LDA DATATRAMPA,X
010880   STA $0300,X
010890   DEX
010900   BPL LOOPTRAMPIX
010910   JSR $E459
010920   CLC
010921   LDA #$0F
010922   LDX PALNTS
010923   BEQ TRAMPA.NTSC
010924   LDA #$0C
010925 TRAMPA.NTSC
010926   ADC 20
010930 ; LDA 20
010940 ; ADC #$0F
010950 ESPERATRAMPA
010960   CMP 20
010970   BNE ESPERATRAMPA
010980   LDA #$83
010990   STA $FE48   ; BLOQUE DE 131 BYT
ES (ESTANDAR ATARI)
011000   JSR $FDEA   ; GRABA EOF
011010   LDA #133
011020   STA $FE48   ; AGREGA 2 BYTES BL
OQUE (PARA AGREGAR CONTADOR)
011030 ; LDA #163
011031   LDA #139
011040   STA $D20F
011050   LDX #$28    ; VALOR ORIGINAL: 4

011051   LDY PALNTS
011052   BEQ LOOPLINEA.NTSC
011053   LDX #$21
011054 LOOPLINEA.NTSC
011060   LDY $D40B
011070 LOOPLINEA
011080   CPY $D40B
011090   BEQ LOOPLINEA
011100 WLINE
011110   CPY $D40B
011120   BNE WLINE
011130   DEX
011140   BPL LOOPLINEA.NTSC
011150 ; LDA #35
011151   LDA #11
011160   STA $D20F
011170   RTS
011180 DATATRAMPA
011190   .BYTE $60,$00,$57,$80
011200   .WORD TRAMPA
011210   .BYTE $23,$00
011220   .WORD $83
011230   .BYTE $00,$80
011240   *=  $2000
011250 BLKFALSO
011260   .BYTE $55,$55
011270   TYA
011280   BPL BLOCKOK
011290   LDA #34
011300   STA 559
011310   JSR $EDC7
011320   JMP $C8FC
011330 BLOCKOK
011340   LDA EORBLOCK
011350   EOR #$46
011360   STA EORBLOCK
011370   INC BLOCKOK+6
011380   INC BLOCKOK+1
011390   BNE NOINCBLOCK2
011400   INC BLOCKOK+7
011410   INC BLOCKOK+2
011420 NOINCBLOCK2
011430   LDA BLOCKOK+2
011440   CMP # >FINBLKFALSO
011450   BNE BLOCKOK
011460   LDA BLOCKOK+1
011470   CMP # <FINBLKFALSO
011480   BNE BLOCKOK
011490 EORBLOCK
011500   LDA #$00
011510   STA 710
011520   LDA #$FF
011530   STA $D301
011540   JSR ROMARAM
011550   LDA #34
011560   STA 559
011570   STA $D400
011580   LDA # <DL
011590   STA 560
011600   LDA # >DL
011610   STA 561
011620 LINEAPOSITIVA
011630   LDY $D40B
011640   BMI LINEAPOSITIVA
011650   LDA #$FF
011660   STA $50
011670   LDA # <MUS
011680   STA $0222
011690   LDA # >MUS
011700   STA $0223
011710   LDX #$0B
011720 CARGALASTBLOCK
011730   LDA DATALAST,X
011740   STA $0300,X
011750   DEX
011760   BPL CARGALASTBLOCK
011770   LDA #$FF-2
011780   STA 20
011790 WVBI
011800   LDA 20
011810   BNE WVBI
011820   LDY #19
011830 CHECKTURBO
011840   CLC
011850   LDA DATA,Y
011860   ADC BITLOCO+1
011870   ADC #$00
011880   STA BITLOCO+1
011890   DEY
011900   BPL CHECKTURBO
011910 BITLOCO
011920   LDA #$00
011930   SEC
011940   SBC #$9A
011950   BMI NODIO
011960   BEQ SIDIO
011970   BPL NODIO
011980 SIDIO
011990   JSR $E459
012000 NODIO
012010   JMP ($0304)
012020 MUS
012030   LDA #$82
012040   STA $D203
012050   DEC SCUIS
012060   LDA SCUIS
012070   BNE NO0SCUIS
012080   LDA #120
012090   STA SCUIS
012100 NO0SCUIS
012110   STA $D202
012120   DEC VOLUME
012130   LDA VOLUME
012140   STA $D201
012150   CMP #$A2
012160   BNE FINMUS
012170   LDA #$AA
012180   STA VOLUME
012190   INC QUENOTA
012200   LDX QUENOTA
012210   LDA TONOS,X
012220   CMP #$FF
012230   BNE NOFINMUS
012240   LDA #23
012250   STA QUENOTA
012260   JMP MUS
012270 NOFINMUS
012280   STA $D200
012290 FINMUS
012291   LDA PALNTS
012292   BEQ FINMUS.FIN
012293   DEC FINMUS.CONTADOR
012294   BNE FINMUS.FIN
012295   LDA #6
012296   STA FINMUS.CONTADOR
012297   BNE MUS
012298 FINMUS.FIN
012300   JMP $E45F
012301 FINMUS.CONTADOR
012302   .BYTE 6
012310 VOLUME .BYTE $AA
012320 SCUIS .BYTE 130
012330 QUENOTA .BYTE 0
012340 TONOS
012350   .BYTE 0,0,0,0,0,0,0,0,0,0,0,0
012360   .BYTE 0,0,0,0,0,0,0,0,0,0,0,0
012370   .BYTE 162,81,81,81,81,81,91,81,
81,81,81,81
012380   .BYTE 102,81,81,81,81,81,108,81
,81,81,81,81
012390   .BYTE 121,81,81,81,81,81,121,91
,136,102,144,108
012400   .BYTE 162,121,144,108,136,102,1
44,108,162,121,182,136
012410   .BYTE 162,121,144,108,136,102,1
44,108,162,121,182,136
012420   .BYTE 204,144,217,162,243,204,2
43,182,217,162,204,217
012430   .BYTE 162,121,144,108,136,102,1
44,108,162,121,182,136
012440   .BYTE 162,121,144,108,136,102,1
44,108,162,121,182,136
012450   .BYTE 108,0,108,108,0,121,0,0,0
,0,0,0
012460   .BYTE 136,0,136,136,0,144,0,0,0
,0,0,0
012470   .BYTE 162,0,162,0,162,0,144,0,1
44,0,144,0
012480   .BYTE 136,0,136,0,144,0,162,0,0
,0,0,0
012490   .BYTE 108,0,108,108,0,121,0,0,0
,0,0,0
012500   .BYTE 136,0,136,136,0,144,0,0,0
,0,0,0
012510   .BYTE 162,0,162,0,0,162,144,0,1
44,0,0,144
012520   .BYTE 136,0,136,144,0,162,0,0,0
,0,0,0,$FF
012530 DATALAST
012540   .BYTE $60
012550   .BYTE $00
012560   .BYTE $52
012570   .BYTE $40
012580   .WORD BLKDOS
012590   .BYTE $23
012600   .BYTE $00
012610   .WORD FINBLKDOS-BLKDOS
012620   .BYTE $00
012630   .BYTE $80
012640 DL
012650   .BYTE 112,112,112,64+6
012660 CAMBIO1
012670   .WORD DATA
012680   .BYTE 112,112,112,112,112,112,1
12,112,112,112
012690   .BYTE 65
012700   .WORD DL
012710 DATA
012720   .SBYTE "   turbo SOFTWARE   "
012730 ROMARAM
012740   LDA #$40
012750   PHA
012760   TAX
012770   LDA #$00
012780   PHA
012790   TAY
012800   STY ROM
012810   STY RAM
012820 REENTRE
012830   STX RAM+1
012840   LDX #$C0
012850 LOOPCITO
012860   STX ROM+1
012870 LOOP1
012880   LDA (ROM),Y
012890   STA (RAM),Y
012900   DEY
012910   BNE LOOP1
012920   INC RAM+1
012930   INC ROM+1
012940   INX
012950   BEQ ROMOFF
012960   CPX #$D0
012970   BNE LOOP1
012980   LDX #$D8
012990   BNE LOOPCITO
013000 ROMOFF
013010   SEI
013020   PLA
013030   STA $D40E
013040   LDA $D301
013050   AND #$FE
013060   STA $D301
013070 RETURN
013080   LDA #RAM
013090   STA LOOP1+1
013100   LDA #ROM
013110   STA LOOP1+3
013120   LDA #$60
013130   STA ROMOFF+5
013140   LDA #$58
013150   STA ROMOFF
013160   LDX #$40
013170   JMP REENTRE
013180 FINBLKFALSO
