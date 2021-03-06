
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


S1	EQU	0x74

I0	EQU	0x78	;	interrupt temp


	; reset vector

	PAGESEL init
	GOTO	init


	; interrupt vector

	ORG __VECTOR_INT

	BANKSEL INTCON
	BTFSS	INTCON,IOCIF
	BRA	_iocx
	BANKSEL	IOCBF
	MOVLW	0xFF
	XORWF	IOCBF,W
	ANDWF 	IOCBF,F


	; check button
	BANKSEL	PORTB
	BTFSS	PORTB,0x03
	BRA	_iocx

	BANKSEL S1
	BTFSS	S1,0
	BRA 	_afndj

	; change state
	BANKSEL	TRISA
	MOVLW	10011001b	; RA1,RA2,RA5,RA6 out
	MOVWF	TRISA
	BANKSEL	S1
	BCF	S1,0
	GOTO	_iocx

_afndj:	BANKSEL	TRISA
	MOVLW	10011011b	; RA2,RA5,RA6 out
	MOVWF	TRISA
	BANKSEL	S1
	BSF	S1,0


_iocx:	RETFIE


init:	BANKSEL	LATA
	CLRF	LATA
	CLRF	LATB
	CLRF	LATC

	BANKSEL	TRISA
	MOVLW	10011011b	; RA2,RA5,RA6 out
	MOVWF	TRISA
	MOVLW	11111111b	; all in
	MOVWF	TRISB
	MOVLW	11111111b	; all in
	MOVWF	TRISC

	; setup Pin Properties

	BANKSEL	ANSELA
	CLRF	ANSELB


	BANKSEL OPTION_REG
	BCF	OPTION_REG,NOT_WPUEN

	
	; setup IOC

	BANKSEL	IOCAP
	MOVLW	00111111b	; RB0-RB5
	MOVWF	IOCBP
	MOVWF	IOCBN


	; enable IRQ

	BANKSEL	INTCON
	BSF	INTCON,IOCIE	; enable IOC IRQ
	BSF	INTCON,PEIE	; enable peripheral IRQ--
	BSF	INTCON,GIE	; enable global IRQ

	goto	main


main:	GOTO	main
	end
