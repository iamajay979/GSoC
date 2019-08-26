
	;  Copyright (C) 2019 Nira Tubert
	;	
	;  This program is free software: you can redistribute it and/or
	;  modify it under the terms of the GNU General Public License
	;  as published by the Free Software Foundation, either version
	;  3 of the License, or (at your option) any later version.
	;
	
PROCESSOR	16F1718
	RADIX		dec

	INCLUDE "p16f1718.inc"

	__config _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _MCLRE_ON & _BOREN_ON & _FCMEN_OFF
	__config _CONFIG2, _PLLEN_OFF & _ZCDDIS_ON & _PPS1WAY_OFF

P5	EQU	0x70		; RB5, cC, F1(5), C1(5)
P6	EQU	0x71		; RB6, HL, F1(6), C1(6)
TS1A	EQU	0x72		; RB2, dD, F1(2), C1(2)
TS1B	EQU	0x73		; RB3, eE, F1(3), C1(3)

S1A	EQU	0x74		; RA4, fF, F2(4), C2(4)
S1B	EQU	0x75		; RA3, gG, F2(3), C2(3)

TS2A	EQU	0x76		; RC2, iI, F3(2), C3(2)
TS2B	EQU	0x77		; RC3, jJ, F3(3), C3(3)

C1	EQU	0x78
C2	EQU	0x79
C3	EQU	0x7A

F1	EQU	0x7B		; (not) IOCBF flags
F2	EQU	0x7C
F3	EQU	0x7D

T0	EQU	0x7E		; initialized to 0x04 in init

	; reset vector

	PAGESEL init
	GOTO	init

	; interrupt vector

	ORG __VECTOR_INT

	BTFSS	INTCON,IOCIF
	BRA	_iocx

	BANKSEL IOCAF
	MOVLW	0xFF
	XORWF	IOCBF,W
	ANDWF	IOCBF,F
	MOVWF	F1
	
	MOVLW	0xFF
	XORWF	IOCAF,W
	ANDWF	IOCAF,F
	MOVWF	F2

	MOVLW	0xFF
	XORWF	IOCCF,W
	ANDWF	IOCCF,F
	MOVWF	F3

	BTFSC	F1,5
	BRA	_iocb5x		; bra to the next number
	MOVFW	P5
	BNZ	_bncb5		; bouncing here
	MOVFW	T0	
	MOVWF	P5

	BTFSS	C1,5
	BRA	_higb5

	BSF	IOCBP,IOCBP5
	BCF	IOCBN,IOCBN5
	BCF	C1,5	

	MOVLW	'c'
	CALL	dbg

	BRA	_iocb5x

_higb5:	BSF	IOCBN,IOCBN5
	BCF	IOCBP,IOCBP5
	BSF	C1,5

	MOVLW	'C'
	CALL	dbg	
	
_iocb5x:BTFSC	F1,6
	BRA	_iocb6x		; bra to the next number
	MOVFW	P6
	BNZ	_bncb6		; bouncing here
	MOVFW	T0	
	MOVWF	P6

	BTFSS	C1,6
	BRA	_higb6

	BSF	IOCBP,IOCBP6
	BCF	IOCBN,IOCBN6
	BCF	C1,6	

	MOVLW	'L'
	CALL	dbg

	BRA	_iocb6x

_higb6:	BSF	IOCBN,IOCBN6
	BCF	IOCBP,IOCBP6
	BSF	C1,6

	MOVLW	'H'
	CALL	dbg	
	
_iocb6x:BTFSC	F1,2
	BRA	_iocb2x		; bra to the next number
	MOVFW	TS1A
	BNZ	_bncb2		; bouncing here
	MOVFW	T0	
	MOVWF	TS1A

	BTFSS	C1,2
	BRA	_higb2

	BSF	IOCBP,IOCBP2
	BCF	IOCBN,IOCBN2
	BCF	C1,2	

	MOVLW	'd'
	CALL	dbg

	BRA	_iocb2x

_higb2:	BSF	IOCBN,IOCBN2
	BCF	IOCBP,IOCBP2
	BSF	C1,2

	MOVLW	'D'
	CALL	dbg
	
_iocb2x:
	BTFSC	F1,3
	BRA	_iocb3x		; bra to the next number
	MOVFW	TS1B
	BNZ	_bncb3		; bouncing here
	MOVFW	T0	
	MOVWF	TS1B

	BTFSS	C1,3
	BRA	_higb3

	BSF	IOCBP,IOCBP3
	BCF	IOCBN,IOCBN3
	BCF	C1,3

	MOVLW	'e'
	CALL	dbg

	BRA	_iocb3x

_higb3:	BSF	IOCBN,IOCBN3
	BCF	IOCBP,IOCBP3
	BSF	C1,3

	MOVLW	'E'
	CALL	dbg	
	
_iocb3x:
	BANKSEL IOCAF
	BTFSC	F2,4
	BRA	_ioca4x		; bra to the next number
	MOVFW	S1A
	BNZ	_bnca4		; bouncing here
	MOVFW	T0	
	MOVWF	S1A

	BTFSS	C2,4
	BRA	_higa4

	BSF	IOCAP,IOCAP4
	BCF	IOCAN,IOCAN4
	BCF	C2,4

	MOVLW	'f'
	CALL	dbg

	BRA	_ioca4x

_higa4:	BSF	IOCAN,IOCAN4
	BCF	IOCAP,IOCAP4
	BSF	C2,4

	MOVLW	'F'
	CALL	dbg	
	
_ioca4x:
	BTFSC	F2,3
	BRA	_ioca3x		; bra to the next number
	MOVFW	S1B
	BNZ	_bnca3		; bouncing here
	MOVFW	T0	
	MOVWF	S1B

	BTFSS	C2,3
	BRA	_higa3

	BSF	IOCAP,IOCAP3
	BCF	IOCAN,IOCAN3
	BCF	C2,3

	MOVLW	'g'
	CALL	dbg

	BRA	_ioca3x

_higa3:	BSF	IOCAN,IOCAN3
	BCF	IOCAP,IOCAP3
	BSF	C2,3

	MOVLW	'G'
	CALL	dbg	
	
_ioca3x:
	BANKSEL IOCCF
	BTFSC	F3,2
	BRA	_iocc2x		; bra to the next number
	MOVFW	TS2A
	BNZ	_bncc2		; bouncing here
	MOVFW	T0	
	MOVWF	TS2A

	BTFSS	C3,2
	BRA	_higc2

	BSF	IOCCP,IOCCP2
	BCF	IOCCN,IOCCN2
	BCF	C3,2

	MOVLW	'i'
	CALL	dbg

	BRA	_iocc2x

_higc2:	BSF	IOCCN,IOCCN2
	BCF	IOCCP,IOCCP2
	BSF	C3,2

	MOVLW	'I'
	CALL	dbg	
	
_iocc2x:
	BTFSC	F3,3
	BRA	_iocc3x		; bra to the next number
	MOVFW	TS2B
	BNZ	_bncc3		; bouncing here
	MOVFW	T0	
	MOVWF	TS2B

	BTFSS	C3,3
	BRA	_higc3

	BSF	IOCCP,IOCCP3
	BCF	IOCCN,IOCCN3
	BCF	C3,3

	MOVLW	'j'
	CALL	dbg

	BRA	_iocc3x

_higc3:	BSF	IOCCN,IOCCN3
	BCF	IOCCP,IOCCP3
	BSF	C3,3

	MOVLW	'J'
	CALL	dbg	
	
_iocc3x:
	BRA	_iocx

_bncb5:	MOVLW	'5'
	CALL	dbg
	BRA	_iocb5x

_bncb6:	MOVLW	'6'
	CALL	dbg
	BRA	_iocb6x

_bncb2:	MOVLW	'2'
	CALL	dbg
	BRA	_iocb2x

_bncb3:	MOVLW	'3'
	CALL	dbg
	BRA	_iocb3x

_bnca4:	MOVLW	'4'
	CALL	dbg
	BRA	_ioca4x

_bnca3:	MOVLW	'1'
	CALL	dbg
	BRA	_ioca3x

_bncc2:	MOVLW	'7'
	CALL	dbg
	BRA	_iocc2x

_bncc3:	MOVLW	'8'
	CALL	dbg
	BRA	_iocc3x

_iocx:	BANKSEL PIR1
	BTFSS	PIR1,TMR1IF
	BRA	_tmr1x

	BCF	PIR1,TMR1IF

	; time set

	BANKSEL TMR1H		; FFFF - 7 (in hex) ... 31k*258us=8
	MOVLW	0xFF		; 258us delay
	MOVWF	TMR1H	
	MOVLW	0xF8	
	MOVWF	TMR1L	
	
	TSTF	P5
	BZ	_tmr1b5x	; if there is nothing we check next
	DECF	P5,F

_tmr1b5x:
	TSTF	P6
	BZ	_tmr1b6x	; if there is nothing we check next
	DECF	P6,F

_tmr1b6x:
	TSTF	TS1A
	BZ	_tmr1b2x	; if there is nothing we check next
	DECF	TS1A,F

_tmr1b2x:
	TSTF	TS1B
	BZ	_tmr1b3x	;if there is nothing we finish interrupt
	DECF	TS1B,F

_tmr1b3x:
	TSTF	S1A
	BZ	_tmr1a4x	;if there is nothing we finish interrupt
	DECF	S1A,F

_tmr1a4x:
	TSTF	S1B
	BZ	_tmr1a3x	;if there is nothing we finish interrupt
	DECF	S1B,F

_tmr1a3x:
	TSTF	TS2A
	BZ	_tmr1c2x	;if there is nothing we finish interrupt
	DECF	TS2A,F

_tmr1c2x:
	TSTF	TS2B
	BZ	_tmr1x		;if there is nothing we finish interrupt
	DECF	TS2B,F

_tmr1x:	RETFIE

init:	BANKSEL	LATA
	CLRF	LATA
	CLRF	LATB
	BSF	LATB,7		; RB7 default high
	CLRF	LATC

	BANKSEL	TRISA
	MOVLW	10011011b	; RA2,RA5,RA6 out
	MOVWF	TRISA
	MOVLW	01111111b	; RB7 out
	MOVWF	TRISB
	MOVLW	11111111b	; all in
	MOVWF	TRISC

	BANKSEL	INLVLA
	BSF	INLVLA,3	; ST thresholds
	BSF	INLVLA,4
	BSF	INLVLB,2
	BSF	INLVLB,3
	BSF	INLVLC,2
	BSF	INLVLC,3

	; setup Pin Properties

	BANKSEL	ANSELA
	CLRF	ANSELA
	CLRF	ANSELB
	CLRF	ANSELC

	BANKSEL OPTION_REG
	BCF	OPTION_REG,NOT_WPUEN

	; initialize

	MOVLW	0x04	
	MOVWF	T0

	CLRF	P5
	CLRF	P6
	CLRF	TS1A
	CLRF	TS1B
	CLRF	S1A
	CLRF	S1B
	CLRF	TS2A
	CLRF	TS2B
	CLRF	F1
	CLRF	F2
	CLRF	F3

	; setup IOC

	BANKSEL	IOCAP
	MOVLW	10011011b
	;MOVWF	IOCAP		; we check falling edge first (N)
	MOVWF	IOCAN
	MOVLW	0xFF
	MOVWF	C2

	MOVLW	01111111b
	;MOVWF	IOCBP
	MOVWF	IOCBN
	MOVLW	0xFF
	MOVWF	C1

	MOVLW	11111111b
	;MOVWF	IOCCP
	MOVWF	IOCCN
	MOVLW	0xFF
	MOVWF	C3

	; enable IRQ

	BANKSEL	INTCON
	BSF	INTCON,IOCIE	; enable IOC IRQ
	BSF	INTCON,PEIE	; enable peripheral IRQ--
	BSF	INTCON,GIE	; enable global IRQ
	BANKSEL	PIE1
	BSF	PIE1,TMR1IE	; enable

	; configure timer1	

	BANKSEL T1CON
	BSF	T1CON,6		
	BSF	T1CON,7
	BSF	T1CON,TMR1ON	; enable Timer1 On bit
	MOVLW	0xFF	
	IORWF	TMR1H,F	
	IORWF	TMR1L,F

	; setup EUSART Asynchronous Mode

	BANKSEL	TX1STA
	MOVLW	0        	; Baud rate 1Mbps
	MOVWF	SPBRG

	BSF	TX1STA,BRGH	; High speed baud rate
	BSF	RC1STA,SPEN
	BSF	TX1STA,TXEN	; Configures TX1STA

	BANKSEL	OSCCON    
	MOVLW	01111000b	; IRCF to 16MHz
	MOVWF	OSCCON

	BANKSEL	RB7PPS
	MOVLW	10100b		; Output Source Selection TX/CK
	MOVWF	RB7PPS
	GOTO	main

dbg:    BANKSEL	TX1STA
dbgl:	BTFSS	TX1STA,TRMT
	GOTO	dbgl
	MOVWF	TX1REG
	RETURN

wait:	BANKSEL	OSCSTAT
waitl:	BTFSS	OSCSTAT,HFIOFS
	GOTO	waitl
	RETURN

main:	CALL	wait
	MOVLW	'A'
	CALL	dbg

idle:	GOTO	idle    	
	end
