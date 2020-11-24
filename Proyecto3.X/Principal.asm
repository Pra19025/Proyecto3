 ;*******************************************************************************
;
;   Filename:	    Proyecto3 -> Principal.asm
;   Date:		    12/11/2020
;   File Version:	    v.1
;   Author:		    Noel Prado
;   Company:	    UVG
;   Description:	    Proyecto3
;
;*******************************************************************************  

    #include "p16f887.inc"

; CONFIG1
; __config 0xE0D5
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    GPR_VAR	    UDATA
    STATUS_TEMP	RES 1
    W_TEMP	RES 1
    CONT1		RES 1
    POT3		RES 1
    CONTROL_CANAL RES 1
		
    RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program


ISR_VECT    CODE 0X0004
 
PUSH:
    MOVWF	    W_TEMP
    SWAPF	   STATUS, W
    MOVWF	   STATUS_TEMP 

    BTFSC	PIR1, ADIF
    GOTO	INT_ADC
    BTFSC	INTCON, T0IF
    GOTO	INT_TMR0
    BTFSC	PIR1, TMR2IF
    GOTO	INT_TMR2
    GOTO	POP    
   
    
INT_TMR0:
    BCF	INTCON, T0IF
    MOVLW   .237
    MOVWF   TMR0
    INCF	CONT1, F
    MOVFW   CONT1
    SUBWF   POT3, W
    BTFSS   STATUS, C
    COMF    PORTC, RC0
    
    GOTO POP
        
INT_ADC:
    BCF	PIR1, ADIF
    
    MOVLW .0
    SUBWF   CONTROL_CANAL, W
    BTFSC   STATUS, Z
    GOTO    CANAL0
    
    MOVLW   .1
    SUBWF   CONTROL_CANAL, W
    BTFSC   STATUS, Z
    GOTO    CAMBIO_CANAL1
    
    MOVLW   .2
    SUBWF   CONTROL_CANAL, W
    BTFSC   STATUS, Z
    GOTO    CAMBIO_CANAL2
    
    
CANAL0:
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    MOVWF CCPR1L
    BANKSEL ADCON0
    BSF   ADCON0, 2
    GOTO REINICIOADC
    
CAMBIO_CANAL1:
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    MOVWF   CCPR2L
    BANKSEL ADCON0  
    BCF   ADCON0, 2
    BSF   ADCON0, 3
    GOTO    REINICIOADC

    
CAMBIO_CANAL2:
    CLRF    CONTROL_CANAL
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    MOVWF   POT3
    BANKSEL ADCON0
    BCF	ADCON0, 2
    BCF	ADCON0, 3
    GOTO    REINICIOADC
    
INT_TMR2:
    BCF	PIR1, TMR2IF
    GOTO POP
    
REINICIOADC:
    NOP
    NOP
    NOP
    NOP
    NOP
    BANKSEL ADCON0
    BSF ADCON0, GO
    
    
POP:
    SWAPF	    STATUS_TEMP, W
    MOVWF	    STATUS
    SWAPF	    W_TEMP, F
    SWAPF	    W_TEMP, W
    BSF	    INTCON, GIE
 
    RETFIE

MAIN_PROG CODE                      ; let linker place main program

START

    CALL    CONFIG_IO
    
LOOP:
    
    GOTO LOOP
    GOTO $                          ; loop forever

    
    CONFIG_IO
    
    BANKSEL PORTA
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB
    CLRF    CONTROL_CANAL
    CLRF    POT3
    BANKSEL TRISA
    CLRF    TRISB
    CLRF    TRISC
    BSF	TRISA, 0
    BSF	TRISA, 1
    BSF	TRISA, 2
    BANKSEL ADCON1
    MOVLW B'00000000'
    MOVWF   ADCON1
    
    BANKSEL ANSEL
    BSF	ANSEL, 0
    BSF	ANSEL, 1
    BSF	ANSEL, 2
    BANKSEL ADCON0
    MOVLW   B'01000001'	
    MOVWF   ADCON0
    
    ;PARTE DE LA INTERRUPCION 
    BANKSEL TRISA
    BSF	PIE1, ADIE
    BSF	PIE1, TMR2IE
    BANKSEL PORTA
    BSF	INTCON, GIE
    BSF	INTCON, PEIE
    BCF	PIR1, ADIF
    BCF	PIR1, TMR2IF
    
    ;PARA PWM
   
    MOVLW .187
    MOVWF    PR2
    
    BANKSEL  CCP1CON
    BCF	CCP1CON, 7
    BCF	CCP1CON, 6

    BSF	CCP1CON, 3
    BSF	CCP1CON, 2
    BCF	CCP1CON, 1
    BCF	CCP1CON, 0

        
    BANKSEL  CCP1CON 
    BSF	CCP2CON, 3
    BSF	CCP2CON, 2
    BCF	CCP2CON, 1  
    BCF	CCP2CON, 0
   
    BCF	T2CON, 6
    BCF	T2CON, 5
    BCF	T2CON, 4
    BCF	T2CON, 3
   
   
    BSF	T2CON, 1
    BSF	T2CON, 0
    BSF	T2CON, TMR2ON
    
    ;para timer 0, que se utiliza para el tercer servo

    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS;	RELOJ INTERNO
    BCF	    OPTION_REG, PSA;	PRESCALER A TMR0
    BSF	    OPTION_REG, PS2;	SE PONE 111 PARA PRESCALER DE 256
    BSF	    OPTION_REG, PS1
    BSF	    OPTION_REG, PS0
    BANKSEL PORTA
    MOVLW   .237
    MOVWF   TMR0
    BSF	    INTCON, T0IE
    BCF	    INTCON, T0IF
    RETURN
    
    
    
    END