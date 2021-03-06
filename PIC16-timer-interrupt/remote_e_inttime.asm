
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

	
	; reset vector

	PAGESEL init
	GOTO	init

	; interrupt vector

	ORG __VECTOR_INT

	BANKSEL PIR1
	BTFSS	PIR1,TMR1IF
	BRA	_tmr1x

	; time set

	BANKSEL TMR1H	; FFFF - 15500 (in hex) ... 31k*0,5s=15500
	MOVLW	0xC3	; 500ms delay
	MOVWF	TMR1H	
	MOVLW	0x73	
	MOVWF	TMR1L	

	BANKSEL	TRISA
	MOVLW	0x02
	XORWF	TRISA,F
	
	BANKSEL PIR1
	BCF	PIR1,TMR1IF

_tmr1x:	RETFIE


init:	; setup Pin Properties

	BANKSEL OPTION_REG
	BCF	OPTION_REG,NOT_WPUEN

	; enable IRQ

	BANKSEL	INTCON
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


main:	GOTO	main
	end
