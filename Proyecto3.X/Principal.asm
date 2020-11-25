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
    CONTROL_PWM RES 1
    ADC0 RES 1
    ADC1 RES 1
    ADC2 RES 1
    CONTADOR_ADC RES 1 ;CONTADOR QUE INDICA QUE CANAL SE ESTA LEYENDO
    FLAGS RES 1
    CONTADOR_PWM RES 1
    AJUSTE_PWM RES 1 
    TRABAJO1 RES 1 
    TRABAJO2 RES 1 
		
    RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program


ISR_VECT    CODE 0X0004
 
PUSH:
    MOVWF	    W_TEMP
    SWAPF	   STATUS, W
    MOVWF	   STATUS_TEMP 

INT_TMR0:
    BTFSS   INTCON,T0IF
    GOTO    INT_ADC
    
    BCF	INTCON,T0IF
    MOVF    CONTROL_PWM,W
    ADDWF   PCL, F
    GOTO    INICIO_PERIODO ;este contador LLEVA EN CONTROL DE LA SECUENCIA PARA LA GENERACION PWM
    GOTO    PWM1
    CLRF     CONTROL_PWM
    
INICIO_PERIODO: ;EN LA PRIMERA FASE SE COLOCA EN 1 EL PIN RC0 Y RC3 SE ENCUENTRA EN 0
    
    BSF	PORTC, RC0 
    MOVF    TRABAJO1,W 
    CLRF	TMR0
    SUBWF   TMR0,F  ;TMRO =  256 - TRABAJO1
    INCF     CONTROL_PWM,F ;A LA SIGUIENTE ENTRADA SE EJECUTA PWM1
    GOTO INT_ADC
    
PWM1:
    BCF	PORTC,RC0 ;AL PASAR EL TIEMPO ESTABLECIDO POR LA VARIABLE TRABAJO 1
    MOVF   TRABAJO2,W
    CLRF TMR0
    SUBWF   TMR0,F ;256 - TRABAJO2
    INCF  CONTROL_PWM,F
    GOTO INT_ADC
   
INT_ADC:
    BTFSS   PIR1, ADIF 
    GOTO    POP
    BANKSEL ADRESH
    BCF	PIR1, ADIF
    MOVF    CONTADOR_ADC,W
    ADDWF   PCL,F   
    GOTO    ES_ADC0
    GOTO    ES_ADC1
    GOTO    ES_ADC2
    CLRF    CONTADOR_ADC
    
    ES_ADC0:
    MOVF    ADRESH, W
    MOVWF   ADC0
    BCF	ADCON0,CHS1
    BSF	ADCON0,CHS0 ;SE SELECCIONA EL CANAL 1
    GOTO FIN
    
    ES_ADC1:
    MOVF    ADRESH, W
    MOVWF   ADC1
    BSF	ADCON0,CHS1
    BCF	ADCON0,CHS0 ;SE SELECCIONA EL CANAL 2
    GOTO FIN
    
    ES_ADC2:
    MOVF    ADRESH,W
    MOVWF   ADC2
    BCF	ADCON0,CHS1
    BCF	ADCON0,CHS0 ;SE SELECCIONA CANAL 0
    
    FIN:
    INCF    CONTADOR_ADC,F
    BSF	ADCON0,GO ;INICIA CONVERSION
    
    
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
    
    MOVFW   ADC0
    MOVWF   CCPR1L
    
    MOVFW    ADC1
    MOVWF   CCPR2L
    
    MOVFW   ADC2
    MOVWF TRABAJO1
    	

    GOTO LOOP
    GOTO $                          ; loop forever


    
    
    CONFIG_IO
    
    BANKSEL PORTA
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB
    CLRF    CONTROL_PWM
    CLRF    ADC0
    CLRF    ADC1
    CLRF    ADC2
    CLRF    CONTADOR_ADC
    CLRF    FLAGS
  
    BANKSEL TRISA
    CLRF    TRISB
    CLRF    TRISC
    BSF	TRISA, 0
    BSF	TRISA, 1
    BSF	TRISA, 2
    
    ;PARTE DEL ADC
    BANKSEL ADCON1
    CLRF   ADCON1
    
    BANKSEL ANSEL
    BSF	ANSEL, 0
    BSF	ANSEL, 1
    BSF	ANSEL, 2
    CLRF    ANSELH
    BANKSEL ADCON0
    MOVLW   B'01000001'	
    MOVWF   ADCON0
    
    ;PARTE DE LA INTERRUPCION 
    BANKSEL TRISA
    BSF	PIE1, ADIE
    ;BSF	PIE1, TMR2IE
    BANKSEL PORTA
   BCF	PIR1, ADIF
   ; BCF	PIR1, TMR2IF
    
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
    BSF	T2CON, 2
    BSF	T2CON, 1    ;BIT DE ENCENDIDO
    BCF	T2CON, 0
    
    ;para timer 0, que se utiliza para el tercer servo

    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS;	RELOJ INTERNO
    BCF	    OPTION_REG, PSA;	PRESCALER A TMR0
    BCF	    OPTION_REG, PS2;	SE PONE 111 PARA PRESCALER DE 256
    BSF	    OPTION_REG, PS1
    BSF	    OPTION_REG, PS0
    BANKSEL PORTA
    CLRF	    TMR0
    BSF	    INTCON, T0IE
    BCF	    INTCON, T0IF
    RETURN
    
    BANKSEL PORTA
    BSF	INTCON, GIE
    BSF	INTCON, PEIE

    END