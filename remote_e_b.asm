
	;  Copyright (C) 2018 H.Poetzl
	;	
	;  This program is free software: you can redistribute it and/or
	;  modify it under the terms of the GNU General Public License
	;  as published by the Free Software Foundation, either version
	;  2 of the License, or (at your option) any later version.
	;

	PROCESSOR	16F1718
	RADIX		dec

	INCLUDE "p16f1718.inc"

	__config _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _MCLRE_ON & _BOREN_ON & _FCMEN_OFF
	__config _CONFIG2, _PLLEN_OFF & _ZCDDIS_ON & _PPS1WAY_OFF


	;	0x2000	Bank 0		PORT, PIR, TMR 0/1/2
	;	0x2050	Bank 1		TRIS, PIE, OSC
	;	0x20A0	Bank 2		LAT, CM 1/2, DAC 1/2
	;	0x20F0	Bank 3		ANSEL, UART 1

	;	0x2140	Bank 4		WPU, SSP 1
	;	0x2190	Bank 5		ODCON, CCP 1/2
	;	0x21E0	Bank 6		SRLCON
	;	0x2230	Bank 7		INLVL, IOC

	;	0x2280	Bank 8		TMR 4/6
	;	0x22D0	Bank 9		NCO 1
	;	0x2320	Bank 10		OPA 1/2
	;	0x2370	Bank 11		

	;	0x23C0	Bank 12		PWM 3/4
	;	0x2410	Bank 13		COG 1
	;	0x2460	Bank 14		
	;	0x24B0	Bank 15		

	;	0x2500	Bank 16		
	;	0x2550	Bank 17
	;	0x25A0	Bank 18
	;	0x25F0	Bank 19		

	;	0x2640	Bank 20		
	;	0x2690	Bank 21
	;	0x26E0	Bank 22
	;	0x2730	Bank 23

	;	0x2780	Bank 24
	;	0x27D0	Bank 25


	;	FSR0H	0x25	Bank 16-19
	;		0x2500	Port A change flags
	;		0x2501	Port B change flags
	;		0x2502	Port C change flags

	;		0x2504	Port A status
	;		0x2505	Port B status
	;		0x2506	Port C status

	;		0x2510	Quadrature encoder 1
	;		0x2511	Quadrature encoder 2

	;		0x2520	PWM Red / Pattern
	;		0x2521	PWM Green / Pattern
	;		0x2522	PWM Blue / Pattern
	;		0x2523	PWM Load

	;		0x2530	Pattern Red 7:0
	;		0x2531	Pattern Reg 15:8
	;		0x2532	Pattern Green 7:0
	;		0x2533	Pattern Green 15:8
	;		0x2534	Pattern Blue 7:0
	;		0x2535	Pattern Blue 15:8
	;		0x2536	Pattern Load
	

	;	FSR1H	0x26	Bank 19-22


C1	EQU	0x70
C2	EQU	0x71
C3	EQU	0x72
C4	EQU	0x73


I0	EQU	0x78	;	interrupt temp


_adr	EQU	0x220	;	0x2140 I2C addr
_idx	EQU	0x221	;	0x2141 I2C index
_cnt	EQU	0x222	;	0x2142 I2C byte


	; reset vector

	ORG __VECTOR_RESET
	PAGESEL init
	GOTO	init


	; interrupt vector

	ORG __VECTOR_INT

	BANKSEL PIR1
	BTFSS	PIR1,SSP1IF
	BRA	_ssp1x

	BCF	PIR1,SSP1IF		; clear interrupt
	
	BANKSEL SSP1STAT
	BTFSS	SSP1STAT,BF		; data in buffer?
	BRA	_read

	BTFSC	SSP1STAT,D_NOT_A	; data or addr?
	BRA	_data

	MOVFW	SSP1BUF			; get address
	MOVWF	_adr			; save address
	MOVLW	0xFF
	MOVWF	_cnt			; set cnt to -1

	BTFSS	SSP1STAT,R_NOT_W
	GOTO	_ssp1x

_read:	BTFSC	SSP1CON1,CKP		; clock active??
	GOTO	_ssp1x

	MOVFW	_idx			; current index
	MOVWF	FSR0L

	MOVFW	INDF0			; get buf data
	MOVWF	SSP1BUF			; transmission
	BSF	SSP1CON1,CKP		; release SCL

	MOVLW	0x4			
	SUBWF	_idx,W			; idx < 4 ?
	SKPC
	CLRF	INDF0			; zero register

	INCF	_idx,F			; increment idx
	GOTO	_ssp1x

_data:	INCFSZ	_cnt,F			; index write?
	BRA	_write

	MOVFW	SSP1BUF			; get i2c index
	MOVWF	_idx			; update index
	GOTO	_ssp1x

_write:	MOVFW	_idx			; current index
	MOVWF	FSR0L

	MOVFW	SSP1BUF			; get i2c data
	MOVWF	INDF0			; store to buffer

	INCF	_idx,F			; increment idx

_ssp1x:	BANKSEL INTCON
	BTFSS	INTCON,IOCIF
	BRA	_iocx

	BANKSEL	IOCAF
	CLRF	FSR0L
	MOVFW	IOCAF
	BZ	_iocax

	IORWF	INDF0,F			; add change mask
	XORLW	0xFF
	ANDWF	IOCAF,F			; clear flag

	BANKSEL	PORTA
	MOVFW	PORTA
	MOVWI	4[FSR0]			; update port reg

	BANKSEL	IOCBF
_iocax:	INCF	FSR0L,F
	MOVFW	IOCBF
	BZ	_iocbx

	IORWF	INDF0,F			; add change mask
	XORLW	0xFF
	ANDWF	IOCBF,F			; clear flag

	BANKSEL	PORTB
	MOVFW	PORTB
	MOVWI	4[FSR0]			; update port reg

	BANKSEL	IOCCF
_iocbx:	INCF	FSR0L,F
	MOVFW	IOCCF
	BZ	_iocx
	
	IORWF	INDF0,F			; add change mask
	XORLW	0xFF
	ANDWF	IOCCF,F			; clear flag

	BANKSEL	PORTC
	MOVFW	PORTC
	MOVWI	4[FSR0]			; update port reg

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
	CLRF	ANSELA
	CLRF	ANSELB
	CLRF	ANSELC

	BANKSEL	ODCONA
	CLRF	ODCONA
	CLRF	ODCONB
	CLRF	ODCONC

	BANKSEL WPUA
	MOVLW	10011011b	; inputs up
	MOVWF	WPUA
	MOVLW	11111111b	; all up
	MOVWF	WPUB
	MOVLW	11111111b	; all up
	MOVWF	WPUC

	BANKSEL INLVLA
	MOVLW	11111111b	; all ST
	MOVWF	INLVLA
	MOVWF	INLVLB
	MOVWF	INLVLC

	BANKSEL OPTION_REG
	BCF	OPTION_REG,NOT_WPUEN


	; setup PPS


	BANKSEL	PPSLOCK
	BCF	PPSLOCK, PPSLOCKED

	MOVLW	01111b		; RB7
	MOVWF	SSPDATPPS
	MOVLW	01110b		; RB6
	MOVWF	SSPCLKPPS

	MOVLW	11000b		; disable
	MOVWF	INTPPS
	MOVWF	COGINPPS


	BANKSEL	RB7PPS
	MOVLW	10001b		; SDA
	MOVWF	RB7PPS
	MOVLW	10000b		; SCL
	MOVWF	RB6PPS


	; setup indirect memory

	MOVLW	0x25		; 0x25xx
	MOVWF	FSR0H	
	MOVLW	0x26		; 0x26xx
	MOVWF	FSR1H	

	; setup oscillator

	BANKSEL	OSCCON
	MOVLW	01111000b
	MOVWF	OSCCON


	; initialize ram

        BANKSEL _adr
	CLRF	_adr
	CLRF	_cnt
	CLRF	_idx


	; setup SSP1

	BANKSEL	SSP1STAT
	CLRF	SSP1STAT
	BSF	SSP1STAT,SMP

	MOVLW	0110b		; 7bit slave mode
	MOVWF	SSP1CON1
	BSF	SSP1CON1,SSPEN	; enable I2C
	BSF	SSP1CON1,CKP	; enable I2C clock

	CLRF	SSP1CON2
	BCF	SSP1CON2,SEN	; clock stretching disabled
	BSF	SSP1CON2,GCEN	; general call enabled

	CLRF	SSP1CON3
	BSF	SSP1CON3,BOEN	; buffer override enabled
	BSF	SSP1CON3,SCIE	; start condition irq
	BCF	SSP1CON3,PCIE	; stop condition irq

	MOVLW	00100000b	; address 0x10
	MOVWF	SSP1ADD
	MOVLW	11111110b	; address mask
	MOVWF	SSP1MSK

	
	; setup IOC

	BANKSEL	IOCAP
	MOVLW	00000011b	; RA0,RA1
	MOVWF	IOCAP
	MOVWF	IOCAN

	MOVLW	00111111b	; RB0-RB5
	MOVWF	IOCBP
	MOVWF	IOCBN

	MOVLW	11111100b	; RC2-RC7
	MOVWF	IOCCP
	MOVWF	IOCCN


	; enable IRQ

	BANKSEL	PIR1
	BCF	PIR1,SSP1IF	; clear I2C IRQ
	
	BANKSEL PIE1
	BSF	PIE1,SSP1IE	; enable I2C IRQ

	BANKSEL	INTCON
	BSF	INTCON,IOCIE	; enable IOC IRQ
	BSF	INTCON,PEIE	; enable peripheral IRQ
	BSF	INTCON,GIE	; enable global IRQ

	goto	main




delay:	MOVLW	0x01
	MOVWF	C3
dloop:	DECFSZ	C1,F
	GOTO	dloop
	DECFSZ	C2,F
	GOTO	dloop
	; DECFSZ	C3,F
	; GOTO	dloop
	RETURN



main:	

; blink on both LED (S2)
	BANKSEL	TRISA
	MOVLW	10011001b	; RA1,RA2,RA5,RA6 out
	MOVWF	TRISA

	CALL delay
	CALL dloop

	BANKSEL	TRISA
	MOVLW	10011010b	; RA0,RA2,RA5,RA6 out
	MOVWF	TRISA

	CALL delay
	CALL dloop

	BANKSEL	TRISA
	MOVLW	10011000b	; RA0,RA1,RA2,RA5,RA6 out
	MOVWF	TRISA

	CALL delay
	
; end blink


	GOTO	main
	end
