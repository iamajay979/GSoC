
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

S5	EQU	0x73
S6	EQU	0x74

C1	EQU	0x77
F1	EQU	0x78	;	(not) IOCBF flags

	; reset vector

	PAGESEL init
	GOTO	init

	; interrupt vector

	ORG __VECTOR_INT

	BTFSS	INTCON,IOCIF
	BRA	_iocx

	BANKSEL IOCBF
	MOVLW	0xFF
	XORWF	IOCBF,W
	ANDWF	IOCBF,F
	MOVWF	F1

	BTFSC	F1,5
	BRA	_iocb5x		; bra to the next number
	MOVFW	S5
	BNZ	_bncb5		; bouncing here
	MOVLW	0x02	
	MOVWF	S5

	BTFSS	C1,5
	BRA	_hig5

	BSF	IOCBP,IOCBP5
	BCF	IOCBN,IOCBN5
	BCF	C1,5	

	MOVLW	'c'
	CALL	dbg

	BRA	_iocb5x

_hig5:	BSF	IOCBN,IOCBN5
	BCF	IOCBP,IOCBP5
	BSF	C1,5

	MOVLW	'C'
	CALL	dbg	
	
	BRA	_iocb5x
	
_iocb5x:BTFSC	F1,6
	BRA	_iocb6x		; bra to the next number
	MOVFW	S6
	BNZ	_bncb6		; bouncing here
	MOVLW	0x02	
	MOVWF	S6

	BTFSS	C1,6
	BRA	_hig6

	BSF	IOCBP,IOCBP6
	BCF	IOCBN,IOCBN6
	BCF	C1,6	

	MOVLW	'L'
	CALL	dbg

	BRA	_iocb6x

_hig6:	BSF	IOCBN,IOCBN6
	BCF	IOCBP,IOCBP6
	BSF	C1,6

	MOVLW	'H'
	CALL	dbg	
	
_iocb6x:BRA	_iocx

_bncb5:	MOVLW	'5'
	CALL	dbg
	BRA	_iocb5x

_bncb6:	MOVLW	'6'
	CALL	dbg
	BRA	_iocb6x

_iocx:	BANKSEL PIR1
	BTFSS	PIR1,TMR1IF
	BRA	_tmr1x

	BCF	PIR1,TMR1IF

	; time set

	BANKSEL TMR1H	; FFFF - 7 (in hex) ... 31k*258us=8
	MOVLW	0xFF	; 258us delay
	MOVWF	TMR1H	
	MOVLW	0xF8	
	MOVWF	TMR1L	
	
	MOVFW	S5
	BZ	_tmr15x		; if there is nothing we check next
	DECF	S5,F
	;MOVLW	'^'
	;CALL	dbg

_tmr15x:MOVFW	S6
	BZ	_tmr1x		;if there is nothing we finish interrupt
	DECF	S6,F
	;MOVLW	'_'
	;CALL	dbg

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

	; setup Pin Properties

	BANKSEL	ANSELA
	CLRF	ANSELB

	BANKSEL OPTION_REG
	BCF	OPTION_REG,NOT_WPUEN

	; initialize

	CLRF	S5
	CLRF	S6
	CLRF	F1

	; setup IOC

	BANKSEL	IOCAP
	MOVLW	01111111b	; RB0-RB6
	;MOVWF	IOCBP		; we check falling edge first (N)
	MOVWF	IOCBN
	MOVLW	0xFF
	MOVWF	C1

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
