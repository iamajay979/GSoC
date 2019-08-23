
PROCESSOR	16F1718
	RADIX		dec

	INCLUDE "p16f1718.inc"

	__config _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _MCLRE_ON & _BOREN_ON & _FCMEN_OFF
	__config _CONFIG2, _PLLEN_OFF & _ZCDDIS_ON & _PPS1WAY_OFF


S1	EQU	0x74
S2	EQU	0x75
L1	EQU	0x76
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

	BTFSC	S2,0
	BRA	_bnc		; bouncing here
	BSF	S1,0
	;BRA	_swc		; we could just switch (IOC)

	; check button		; but we check the change
	BANKSEL	PORTB
	BTFSS	PORTB,0x03
	BRA	_rel

	BTFSC	L1,0		; check if the button was pushed before
	BRA	_iocx		; if it was nothing happens
	BRA	_swc		; if not it has swithced
	
_rel:	BTFSS	L1,0
	BRA	_iocx
	
_swc:	MOVLW	0x03		; button's state has changed!
	XORWF	L1,F
	BTFSS	L1,0		; switch led every time button is pushed
	BRA	_iocx
	BANKSEL	TRISA
	MOVLW	0x02
	XORWF	TRISA,F

	BANKSEL PIR1
	BTFSS	PIR1,TMR1IF
	BRA	_tmr1x

	; time set

	BANKSEL TMR1H	; FFFF - 7 (in hex) ... 31k*225us=7
	MOVLW	0xFF	; 225us delay
	MOVWF	TMR1H	
	MOVLW	0xF8	
	MOVWF	TMR1L	
	
	BTFSS	S1,0
	BRA	_tmr1x

	BTFSC	S2,1	; 2 timer interrupts done
	BRA	_intcl
	
	MOVLW	0xFF
	XORWF	S2,W		; sumar un a S2
	ANDWF 	S2,F

_intcl:	BCF	S2,1	; change later for different number than 2
	BCF	S1,0
	BRA	_tmr1x

_bnc:	BANKSEL	TRISA
	MOVLW	0x01
	XORWF	TRISA,F
	RETFIE

_iocx:	RETFIE

_tmr1x:	BANKSEL PIR1
	BCF	PIR1,TMR1IF
	RETFIE


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
