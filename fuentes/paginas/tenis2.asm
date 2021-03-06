; SAVE#D:TENIS2.MAC
;	*=  $3000
	org $3000
BLKDOS
	.BY $55,$55
ORIGEN 	= $3000
PROGRAMA = $CC00
	TYA
	BPL BLKOK
	JSR $EDC7
	JMP $C8FC
BLKOK
	LDA EORBLOCK1
	EOR #$FF
	STA EORBLOCK1
	INC BLKOK+6
	INC BLKOK+1
	BNE NOICRHI
	INC BLKOK+7
	INC BLKOK+2
NOICRHI
	LDA BLKOK+2
	CMP # >FINBLKDOS
	BNE BLKOK
	LDA BLKOK+1
	CMP # <FINBLKDOS
	BNE BLKOK
EORBLOCK1
	LDA $E45A
	STA SALTO
	LDA $E45B
	STA SALTO+1
	LDA # <RAMPROG+SET
	STA $E45A
	STA ROM
	LDA # >RAMPROG+SET
	STA $E45B
	STA ROM+1
	LDA # <RAMPROG
	STA RAM
	LDA # >RAMPROG
	STA RAM+1
	LDY #0
	LDX #3
ARRIBAROM
	LDA (RAM),Y
	STA (ROM),Y
	INY
	BNE ARRIBAROM
	INC RAM+1
	INC ROM+1
	DEX
	BPL ARRIBAROM
	LDX #$02
LOOPINTERRUPCION
	LDA JSRINTERRUPCION,X
	STA $EB59,X
	LDA ERRORYA,X
	STA $EB1D,X
	DEX
	BPL LOOPINTERRUPCION
	STX $02DB
	STX $03F8
	STX $FE0D
	LDX $62
	LDA #$00
	STA $0480
	STA $0481
	STA $FE91,X
	LDA #$32
	STA $FE93,X
	LDA #$EA
	STA $EBF3
	STA $EBF4
	LDA #$C0
	STA $6A
	LDA #133
	STA $FE48
	LDA #12
	STA 764
	LDX #$40
	LDA #$0C
	STA $0342,X
	JSR $E456
	LDX #$40
	LDA #$03
	STA $0342,X
	LDA #$04
	STA $034A,X
	LDA #$80
	STA $034B,X
	LDA # <C
	STA $0344,X
	LDA # >C
	STA $0345,X
	JSR $E456
	LDX #$40
	LDA # <GAMEA+Z
	STA $0344,X
	LDA # >GAMEA+Z
	STA $0345,X
	LDA # <FIN-GAMEA
	STA $0348,X
	LDA # >FIN-GAMEA
	STA $0349,X
	LDA #$07
	STA $0342,X
	LDA #$F0
	STA QUEBLK+SET+1
	JSR $E456
	JMP GAMEA+Z
C
	.BY "C:",$9B
JSRINTERRUPCION
	JSR INTERRUPCION+SET
ERRORYA
	JSR ERROR?+SET
RAMPROG
	LDA $0300
	CMP #$60
	BNE READBLOCK
NEXT
	JSR READBLOCK+SET
	BMI ERROR
VUELTABLK1
	LDA $0480
	STA QUEBLK+SET
	LDA $0481
	STA QUEBLK+SET+1
	LDX #$02
COUNTBLOCK
	DEC BLK+SET,X
	LDA BLK+SET,X
	CMP #$8f	;'0-33
	BNE FINCOUNT
	LDA #$99	;'9-32
	STA BLK+SET,X
	DEX
	BPL COUNTBLOCK
FINCOUNT
	LDY #$01
	RTS
READBLOCK
	JMP (SALTO+SET)
ERROR?
	BEQ ERRORAZO
	LDY $30
	BMI ERRORAZO
	LDA $0317
	BEQ ERRORAZO
	RTS
ERRORAZO
	PLA
	PLA
ERROR
	JSR $EDC7
	CPY #136
	BNE NOESEOF
	TYA
	RTS
NOESEOF
	LDX #$0A
LOOPCORRIGIENDO
	LDA CORRECCION+SET,X
	STA LEYENDO+SET,X
	DEX
	BPL LOOPCORRIGIENDO
	CLC
	LDA 560
	STA $00
	LDA 561
	STA $01
	LDY #$0A
SAVEVIEJO
	LDA ($00),Y
	PHA
	INY
	CPY #$0D
	BNE SAVEVIEJO
JUSTO
	LDA $D40B
	BMI JUSTO
	LDY #$0A
	LDA #$01
	STA ($00),Y
	LDA 561
	CMP # >DISPLIST+SET
	BNE NOTENNIS
	LDA # <DL1+SET
	LDX # >DL1+SET
	BNE SITENNIS
NOTENNIS
	LDA # <DL2+SET
	LDX # >DL2+SET
SITENNIS
	INY
	STA ($00),Y
	TXA
	INY
	STA ($00),Y
	JSR $F2F8
JUSTO1
	LDA $D40B
	BMI JUSTO1
	LDY #$0C
RESTAURA
	PLA
	STA ($00),Y
	 DEY
	CPY #$09
	BNE RESTAURA
	LDA #$34
	STA $D302
	LDA $14
	CLC
	ADC #50
WMOTOR
	CMP $14
	BNE WMOTOR
ESPERE
	LDY $D40B
	LDX #$05
ESPERE1
	STX $D40A
ESIRG
	LDA $D20F
	AND #$10
	BEQ ESPERE
	CPY $D40B
	BNE ESIRG
	DEX
	BNE ESPERE1
NOESIGUAL
	LDA #$40
	STA $0303
	JSR READBLOCK+SET
	BPL NOERRORFALSO
	JSR $EDC7
	LDA #$34
	STA $D302
	BNE ESPERE
NOERRORFALSO
	LDA QUEBLK+SET+1
	BPL NOBLK1
	LDA $0480
	ORA $0481
	BNE VALLAERROR
	JSR CHANGEMSG+SET
CHANGEMSG
	JMP VUELTABLK1+SET
	LDX #$0A
LOOPLECTURA
	LDA LECTURA+SET,X
	STA LEYENDO+SET,X
	DEX
	BPL LOOPLECTURA
	LDY #$01
	RTS
NOBLK1
	LDX #$01
LOOPLUGAR
	LDA $0480,X
	CMP QUEBLK+SET,X
	BCC NOESIGUAL
	BNE VALLAERROR
	DEX
	BPL LOOPLUGAR
	JSR CHANGEMSG+SET
	JMP NEXT+SET
VALLAERROR
	JMP ERROR+SET
INTERRUPCION
	LDA LEYENDO+SET
	AND #$7F
	BEQ BYTESLOOP
	BNE NOES9I
BYTESLOOP
	LDX #$04
BYTESLOOP1
	INC BYTES+SET,X
	LDA BYTES+SET,X
	CMP #$9a	;'9-31
	BNE NOES9I
	LDA #$90	;'0-32
	STA BYTES+SET,X
	DEX
	BPL BYTESLOOP1
NOES9I
	LDA $D20D
	RTS
SALTO 	.DB 0
QUEBLK 	.DB 0,0,0
TENMEBLK
	.BY "000"
MENSAJEERROR
	.SB "   REBOBINE SU CASSETTE 3 VUELTAS DE    "
	.SB "   CONTADOR, PRESIONE  PLAY Y RETURN    "
PANTALLA
	.BY "********************"
PERS 	.SB "  "
NUMERO1 .SB "000"
		.SB "     * 1 JUGADOR-FRONTON *    "
NUMERO2 .SB "000  "
MENSAJE
		.SB "  MPM    * CARGANDO  PROGRAMA *    MPM  "
		.SB "  "
LEYENDO
		.SB " (R)-1988   BYTES:"
BYTES
		.SB "00000  BLOQUE:"
BLK
		.SB "000   "
		.BYTE "********************"
PER2
		.SB "  000     * 2 JUGADORES-TENIS *    000  "
PER1
		.SB "  000     * 1 JUGADOR-FRONTON *    000  "
CORRECCION
	.SB "CORRECCION"
LECTURA
	.SB " (R)-1988 "
CARGADO
	.SB "    PROGRAMA CARGADO, PRESIONE START    "
DL2
	.BY 64+2
	.WO MENSAJEERROR+SET
	.BY 2,65
	.WO $BC20
DL1
	.BY 64+2
	.WO MENSAJEERROR+SET
	.BY 2,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112
	.BY 64+2
	.WO MENSAJE+SET
	.BY 2,8,8
	.BY 65
	.WO DISPLIST+SET
DISPLIST
	.BY 64+8
	.WO PANTALLA+SET
	.BY 8,2,112,112,112,112,112,112,112
AQUIJUMP
	.BY 112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,112,0
	.BY 64+2
CUALPANTALLA
	.WO MENSAJE+SET
	.BY 2,8,8
	.BY 65
	.WO DISPLIST+SET
BUFFER
FINBLKDOS
;	*=  $4000
	org $4000
GAMEA
Z   =   $D800-org
	LDA # <GAME1A+Z
	STA $CB
	LDA # >GAME1A+Z
	STA $CC
	LDY #$00
EOR29LOOP
	LDA ($CB),Y
	EOR #$29
	STA ($CB),Y
	INC $CB
	BNE BCC
	INC $CC
BCC
	LDA $CC
	CMP # >FIN+Z
	BNE EOR29LOOP
	LDA $CB
	CMP # <FIN+Z
	BNE EOR29LOOP
GAME1A
	JMP COMIENZOLOAD+Z
SETCANT
	LDX #$10
	STA $0348,X
	TYA
	STA $0349,X
	RTS
READ2
	LDA #$02
	LDY #$00
	JSR SETCANT+Z
READ3
	LDA # <FIN+Z
	LDY # >FIN+Z
SETPOS
	STA $0344,X
	TYA
	STA $0345,X
	LDA #$07
	STA $0342,X
	JSR $E456
	BPL NOEOF
	JMP INICIOBOOT+Z
NOEOF
	LDX #$10
	RTS
BYTELENTO .BY $00
LEEMULA
	LDA #$01
	STA BYTELENTO+Z
LEEMULA1
	LDA $D20F
	AND #$10
	BEQ LEEMULA1
FINSTART
	LDA $D20F
	AND #$10
	BNE FINSTART
;   LDA #$00-12
	LDA #$00-10
	STA 20
ESPERO12
	LDA 20
	BNE ESPERO12
LEOBIT
	CLC
	LDA $D20F
	AND #$10
	BEQ LEICERO
	SEC
LEICERO
	ROL BYTELENTO+Z
	BCS FINBYTELENTO
;   LDA #$00-8
	LDA #$00-7
	STA 20
	BNE ESPERO12
FINBYTELENTO
	LDA BYTELENTO+Z
	RTS
COMIENZOLOAD
	LDY $D40B
	BMI COMIENZOLOAD
	LDA # <$E45F
	STA $0222
	LDA # >$E45F
	STA $0223
	LDA #$00
	STA $D200
	STA $D201
	STA $D202
BORRAMEM
	LDA #$04
	STA $01
	LDA #$00
	STA $00
	TAY
ERASERAM
	STA ($00),Y
	INY
	BNE ERASERAM
	INC $01
	LDX $01
PONERC0
	CPX #$C0
	BNE ERASERAM
	LDX #$02
ZLOOPCEROS
	LDA TENMEBLK+SET,X
	STA BLK+SET,X
	LDA #$90	;'0-32
	STA BYTES+2+SET,X
	DEX
	BPL ZLOOPCEROS
	STA BYTES+1+SET
	LDX #$03
	LDA #$00
NIRUNNISTART
	STA $02E0,X
	DEX
	BPL NIRUNNISTART
	STA FBOOT+Z
PMBASE = $DC
JOYST = $D300
BOTON1 = $D010
BOTON2 = $D011
COLORP0 = $02C0
HPOSP0 = $D000
HPOSP1 = $D001
HPOSP2 = $D002
DIVISION = $D007
CONSOL = $D01F
RANDOM = $D20A
BOLITA = PMBASE*$0100+768+16
P0  =   PMBASE*$0100+512+16
P1  =   PMBASE*$0100+640+16
INICIO
	LDY #17
	LDA #$EA
NOPDLIVBI
	STA $C137,Y
	DEY
	BPL NOPDLIVBI
	LDY #$02
NOSHADOWS
	STA $C16F,Y
	STA $C178,Y
	DEY
	BPL NOSHADOWS
	LDA #0
	STA START+Z
	LDX #$82
LOOPCLR
	STA BOLITA,X
	STA P0-2,X
	STA P1-2,X
	DEX
	CPX #$FF
	BNE LOOPCLR
	INX
LOOPCLR1
	STA $DE00,X
	STA $DF00,X
	DEX
	BNE LOOPCLR1
	LDA #191
	STA HPOSP0
	LDA #0
	STA HPOSP1
	LDA #191
	STA HPOSP2
	LDX #42
	STX $D004
	LDX #206
	STX $D005
	JSR SETPERS+Z
	LDA #63
	STA $D00C
	LDA #$03
	LDX YPOS0+Z
	LDY #$0C
DIBP1
	STA P0,X
	STA P1,X
	INX
	DEY
	BPL DIBP1
	LDA #1
	LDX YPOS2+Z
	STA BOLITA,X
WFORSET
	LDA $D40B
	BMI WFORSET
	LDA # <VBI+Z
	STA $0222
	LDA # >VBI+Z
	STA $0223
	JMP OPEN+Z
SETPERS
	LDA #2
	STA 623
	STA $D01D
	LDA #PMBASE
	STA $D407
	LDX #0
	STX DIVISION
	LDA #$7F
	STA $D011
	RTS
YPOS0 	.BY 48
YPOS1 	.BY 48
YPOS2 	.BY 48
XPOS2 	.BY 191
XPOS1 	.BY 0
FX  	.BY $FF
FY  	.BY 0
START 	.BY 0
IMPULSO .BY 0
SELECT 	.BY 0
JUEGO 	.BY $FF
SAVEVBI .DB 0
VBI
	LDA # >DISPLIST+SET
	STA $D403
	STA $0244
	STA 561
	LDA # <DISPLIST+SET
	STA $D402
	STA 560
	LDA #0
	STA 77
	STA $D018
	LDA #$E0
	STA $D409
	LDA #$0E
	STA $D012
	STA $D013
	STA $D014
	STA $D016
	STA $D017
	STA $D019
	LDA #212
	STA $D01A
	LDA #42
	STA $D400
	LDA #$A0
	STA $D201
	LDA #$00
	STA $D200
	LDA CONSOL
	CMP #$05
	BNE SELECT0
	LDA SELECT+Z
	BNE NOCAMBIO
	LDA #1
	STA SELECT+Z
	LDA #0
	STA START+Z
	LDY #39
	LDA JUEGO+Z
	EOR #$FF
	STA JUEGO+Z
	BMI ESUNO
CHANGE ;        2 PERS
	LDA PER2+SET,Y
	STA PERS+SET,Y
	DEY
	BPL CHANGE
	LDA #50
	STA HPOSP1
	STA XPOS1+Z
	LDA #127
	STA DIVISION
	BNE TERMINELO
ESUNO ;         1PER
	LDA PER1+SET,Y
	STA PERS+SET,Y
	DEY
	BPL ESUNO
	LDA #0
	STA HPOSP1
	STA XPOS1+Z
	STA DIVISION
TERMINELO
	JMP $E45F
SELECT0
	LDA #0
	STA SELECT+Z
NOCAMBIO
	LDA START+Z
	BNE STARTED
	LDA #0
	LDX YPOS2+Z
	STA BOLITA,X
	LDA CONSOL
	CMP #$06
	BNE NOSTART
	LDA #$FF
	STA START+Z
NOSTART
	LDA XPOS2+Z
	BPL BOTON2?
	LDA BOTON1
	BNE JOY
	LDA YPOS0+Z
	STA YPOS2+Z
	LDA #190
	STA XPOS2+Z
EMPIEZELO
	LDA #$FF
	STA START+Z
	BNE TERMINELO
BOTON2?
	LDA BOTON2
	BNE JOY
	LDA YPOS1+Z
	STA YPOS2+Z
	LDA #51
	STA XPOS2+Z
	BNE EMPIEZELO
JOY
	JMP JOYSTS+Z
STARTED
	LDA FX+Z
	BPL INCRX
	JSR DECREX+Z
	JMP UD+Z
INCRX
	JSR INCREX+Z
UD
	LDA #0
	LDX YPOS2+Z
	STA BOLITA,X
	LDA FY+Z
	BPL INCRY
	JSR DECREY+Z
	JMP JOYSTS+Z
INCRY
	JSR INCREY+Z
	JMP JOYSTS+Z
DECREX
	LDA $D00E
	AND #$02
	BEQ NOREBOTE
	LDA #$33
	STA $D200
	LDA #$AC
	STA $D201
	LDA JOYST
	LSR A
	LSR A
	LSR A
	LSR A
	CMP #$0F
	BEQ NOIMPULSE1
	LDA #$FF
NOIMPULSE1
	STA IMPULSO+Z
	LDX XPOS2+Z
	JMP CHANGEXF+Z
NOREBOTE
	DEC XPOS2+Z
	DEC XPOS2+Z
	LDX XPOS2+Z
	CPX #45
	BCS FINDECREX
	LDA XPOS1+Z
	CMP #40
	BCC OUT2
	LDA #0
	STA START+Z
OUT2
	LDA #$88
	STA $D200
	LDA #$AC
	STA $D201
	LDY #2
ZERO1
	LDA NUMERO1+SET,Y
	CMP #'9-32+128
	BEQ NINE1
	CLC
	ADC #1
	STA NUMERO1+SET,Y
	BNE CHANGEXF
NINE1
	LDA #'0+128-32
	STA NUMERO1+SET,Y
	DEY
	BPL ZERO1
CHANGEXF
	LDA FX+Z
	EOR #$FF
	STA FX+Z
FINDECREX
	STX XPOS2+Z
	STX HPOSP2
	RTS
INCREX
	LDA $D00E
	AND #$01
	BEQ NOREBOTE1
	LDA #$AC
	STA $D201
	LDA #$33
	STA $D200
	LDA JOYST
	AND #$0F
	CMP #$0F
	BEQ NOIMPULSE
	LDA #$FF
NOIMPULSE
	STA IMPULSO+Z
	LDX XPOS2+Z
	JMP CHANGEXF+Z
NOREBOTE1
	INC XPOS2+Z
	INC XPOS2+Z
	LDX XPOS2+Z
	CPX #205
	BCC FINDECREX
SELEFUE
	LDA #0
	STA START+Z
	LDA #$88
	STA $D200
	LDA #$AC
	STA $D201
	LDY #2
ZERO2
	LDA NUMERO2+SET,Y
	CMP #'9-32+128
	BEQ NINE2
	CLC
	ADC #1
	STA NUMERO2+SET,Y
	BNE CHANGEXF
NINE2
	LDA #'0+128-32
	STA NUMERO2+SET,Y
	DEY
	BPL ZERO2
	BMI CHANGEXF
INCREY
	INC YPOS2+Z
	LDA IMPULSO+Z
	BPL BOTAR1
	INC YPOS2+Z
BOTAR1
	LDX YPOS2+Z
	CPX #92
	BCC FININCRY
CHANGEFY
	LDA FY+Z
	EOR #$FF
	STA FY+Z
	LDA #$50
	STA $D200
	LDA #$AC
	STA $D201
FININCRY
	LDA #1
	STA BOLITA,X
	RTS
DECREY
	DEC YPOS2+Z
	LDA IMPULSO+Z
	BPL BOTAR2
	DEC YPOS2+Z
BOTAR2
	LDX YPOS2+Z
	BMI CHANGEFY
	BPL FININCRY
JOYSTS
	LDA #0
	STA $D01E
	LDA JOYST
	AND #$0F
	CMP #15
	BEQ JOY2
	CMP #14
	BNE DWN1
	JSR J1UP+Z
	JMP JOY2+Z
DWN1
	CMP #13
	BNE JOY2
	JSR J1DWN+Z
JOY2
	LDA JOYST
	LSR A
	LSR A
	LSR A
	LSR A
	CMP #15
	BEQ EXIT
	CMP #14
	BNE DWN2
	JSR J2UP+Z
	JMP $E45F
DWN2
	CMP #13
	BNE EXIT
	JSR J2DWN+Z
EXIT
	JMP $E45F
J1UP
	LDY YPOS0+Z
	BEQ FINJ1UP
	LDX #16
LOOPJ1UP
	LDA P0,Y
	STA P0-2,Y
	INY
	DEX
	BPL LOOPJ1UP
	DEC YPOS0+Z
	DEC YPOS0+Z
FINJ1UP
	RTS
J2UP
	LDY YPOS1+Z
	BEQ FINJ2UP
	LDX #16
LOOPJ2UP
	LDA P1,Y
	STA P1-2,Y
	INY
	DEX
	BPL LOOPJ2UP
	DEC YPOS1+Z
	DEC YPOS1+Z
FINJ2UP
	RTS
J1DWN
	LDY YPOS0+Z
	CPY #80
	BEQ FINJ1DWN
	TYA
	CLC
	ADC #14
	TAY
	LDX #16
LOOPJ1DWN
	LDA P0-2,Y
	STA P0,Y
	DEY
	DEX
	BPL LOOPJ1DWN
	INC YPOS0+Z
	INC YPOS0+Z
FINJ1DWN
	RTS
J2DWN
	LDY YPOS1+Z
	CPY #80
	BEQ FINJ2DWN
	TYA
	CLC
	ADC #14
	TAY
	LDX #16
LOOPJ2DWN
	LDA P1-2,Y
	STA P1,Y
	DEY
	DEX
	BPL LOOPJ2DWN
	INC YPOS1+Z
	INC YPOS1+Z
FINJ2DWN
	RTS
OPEN
	LDA #$FF
	STA $0340
	LDX #$10
	LDA #$03
	STA $0342,X
	LDA # <DEVICE+Z
	STA $0344,X
	LDA # >DEVICE+Z
	STA $0345,X
	LDA #$04
	STA $034A,X
	LDA #$80
	STA $034B,X
	LDA #$0C
	STA 764
	JSR $E456
ZREAD
	JSR READ2+Z
	LDA FIN+Z
	AND FIN+1+Z
	CMP #$FF
	BNE SERABOOT?
	LDA # <$E474-1
	STA $0C
	LDA # >$E474-1
	STA $0D
	LDA #$01
	STA FBOOT+Z
	BNE ZREAD
SERABOOT?
	LDA $02E0
	ORA $02E1
	BNE RUNOK
	LDA FIN+Z
	STA $02E0
	LDA FIN+1+Z
	STA $02E1
RUNOK
	LDA FBOOT+Z
	BNE NOESBOOT
	JMP ESBOOT+Z
NOESBOOT
	LDA FIN+Z
	STA $0240
	LDA FIN+1+Z
	STA $0241
	JSR READ2+Z
	SEC
	LDA FIN+Z
	SBC $0240
	STA $0348,X
	LDA FIN+1+Z
	SBC $0241
	STA $0349,X
	INC $0348,X
	BNE NOCARRYY
	INC $0349,X
NOCARRYY
	LDA $0240
	LDY $0241
	JSR SETPOS+Z
	LDA $02E2
	ORA $02E3
	BEQ NOSUBRUTIN
CONSUBRUTINA
	JSR USERSUB+Z
	LDA #$00
	STA $02E2
	STA $02E3
NOSUBRUTIN
	JMP ZREAD+Z
USERSUB
	JMP ($02E2)
CORREPROGRAMA
	LDA #$FF
	STA $D301
	JMP ($02E0)
INICIOBOOT
	LDA #$00-30
	STA 20
WRELOS
	LDA $D20F
	AND #$10
	BEQ INICIOBOOT
	LDA 20
	BNE WRELOS
	LDY #$02
LEOLENTO
	JSR LEEMULA+Z
	STA $03E0,Y
	DEY
	BPL LEOLENTO
	LDA $03E0
	CMP $03E2
	BEQ JUSTOAHORA
	CMP $03E1
	BEQ JUSTOAHORA
	LDA $03E2
	CMP $03E1
	BEQ JUSTOAHORA
LEYODISTINTO
	LDA #$03
	STA PONERC0+Z+1
	JMP BORRAMEM+Z
JUSTOAHORA
	LDA #$3C
	STA $D302
	LDX #39
PROGRAMAENMEMORIA
	LDA CARGADO+SET,X
	STA MENSAJE+SET,X
	DEX
	BPL PROGRAMAENMEMORIA
PRESIONOCAMBIO?
	LDA CONSOL
	CMP #$06
	BNE PRESIONOCAMBIO?
PRESIONOCAMBIO?2
	LDA CONSOL
	CMP #$07
	BNE PRESIONOCAMBIO?2
; SUELTA START ANTES DE EMPEZAR
;
;
;
;
	LDX #$07
LLEVARAM
	LDA CORREPROGRAMA+Z,X
	STA $0392,X
	DEX
	BPL LLEVARAM
JUSTO2
	LDA $D40B
	BMI JUSTO2
	LDA # <$E45F
	STA $0222
	LDA # >$E45F
	STA $0223
	LDA #$00
	STA 623
	LDX #$1F
PMARGEN
	STA $D000,X
	DEX
	BPL PMARGEN
	LDA #$00
	STA $0244
	LDA #$02
	STA $09
	LDA $02E0
	STA $02
	STA $0A
	LDA $02E1
	STA $03
	STA $0B
	LDA $0D
	PHA
	LDA $0C
	PHA
SINRESET
	JMP $0392
ESBOOT
	LDA FIN+Z
	STA $0240
	LDA FIN+1+Z
	STA $0241
	JSR READ2+Z
	CLC
	LDA FIN+Z
	ADC #$06
	STA $04
	LDA FIN+1+Z
	ADC #$00
	STA $05
	JSR READ2+Z
	LDA FIN+Z
	STA $0C
	LDA FIN+1+Z
	STA $0D
	LDY #$06
MULTIPLICA
	ASL $0241
	ROL $0240
	DEY
	BPL MULTIPLICA
	LDA $0240
	STA $0349,X
	LDA $0241
	STA $0348,X
	LDA $04
	STA $0344,X
	STA $02E0
	LDA $05
	STA $0345,X
	STA $02E1
	LDA #$07
	STA $0342,X
	JSR $E456
	SEC
	LDA $0C
	SBC #$01
	STA $0C
	LDA $0D
	SBC #$00
	STA $0D
	JMP INICIOBOOT+Z
FBOOT
	.BY 0
DEVICE
	.BY "C:",$9B
FIN
	.END
