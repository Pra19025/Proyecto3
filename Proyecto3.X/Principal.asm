 ;*******************************************************************************
;
;   Filename:	    Proyecto3 -> principal.asm
;   Date:		    25/11/2020
;   File Version:	    v.1
;   Author:		    Noel Prado
;   Company:	    UVG
;   Description:	    proyecto 3
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
    CONTROL_ADC	RES 1
	
	    
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

ISR_VECT    CODE 0X0004
 
    
PUSH:
    MOVWF	    W_TEMP
    SWAPF	   STATUS, W
    MOVWF	   STATUS_TEMP 
        
INT_ADC:
    
    BCF	PIR1, ADIF
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    
    
    MOVLW .0
    SUBWF   CONTROL_ADC, W
    BTFSC   STATUS, Z
    GOTO    CANAL0
    
    MOVLW .1
    SUBWF   CONTROL_ADC, W
    BTFSC   STATUS, Z
    GOTO    CANAL1
    
    MOVLW .2
    SUBWF   CONTROL_ADC, W
    BTFSC   STATUS, Z
    GOTO    CANAL2
    
    
    CANAL0:
    
    
    MOVWF CCPR1L
    BCF	ADCON0, CHS1
    BSF	ADCON0, CHS0 ;SE SELECCIONA CANAL 1
    
    INCF    CONTROL_ADC
    
    GOTO    REINICIOADC
    
    CANAL1:
    BSF	ADCON0, CHS1
    BCF	ADCON0, CHS0;SE SELECCIONA CANAL 2
    
    MOVWF   CCPR2L
    INCF    CONTROL_ADC
    
    GOTO    REINICIOADC
    
    CANAL2:
    BCF	ADCON0, CHS1
    BCF	ADCON0, CHS0;SE SELECCIONA CANAL 0
    
    CLRF    CONTROL_ADC
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
 
    CALL	CONFIG_IO
   
LOOP:
 
    
 

    GOTO LOOP
    GOTO $                          ; loop forever
    
    
    
    
    CONFIG_IO

    
    BANKSEL PORTA
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB
    
    BANKSEL TRISA
    CLRF    TRISB
    CLRF    TRISC
    BSF	TRISA, 0
    BSF	TRISA, 1
    BANKSEL ADCON1
    MOVLW B'00000000'
    MOVWF   ADCON1
    
    BANKSEL ANSEL
    BSF	ANSEL, 0
    BSF	ANSEL, 1
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
   
    MOVLW .255
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
    

   
   
    RETURN

    END