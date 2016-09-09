; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *     DISCIPLINA DE MICROCONTROLADORES
; *     VICTOR HUGO BRAGUIM CANTO
; *     PROJETO
; *     
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P16F873A.INC>
	__CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_ON & _PWRTE_ON & _WDT_OFF & _HS_OSC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         DEFINIÇÃO DAS VARIÁVEIS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; VARIÁVEIS DO USUÁRIO LOCALIZADAS A PARTIR DO ENDEREÇO 0X20 DA RAM

;	CBLOCK	0X20
;		CONT0                   ;ARMAZENA VALORES DE CONTAGEM TEMPORARIAMENTE
;		CONT                    ;VARIÁVEL QUE ARMAZENA O QUE SE PEDE
;	ENDC

CONT1			EQU		0X20
CONT2			EQU		0X21


; VARIÁVEIS COM ENDEREÇO ESPECÍFICO

W_TEMP			EQU		0X7F
STATUS_TEMP		EQU		0X7E
PCLATH_TEMP		EQU		0X7D

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      DEFINIÇÃO DOS BANCOS DE RAM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE  BANK1  BSF	STATUS,RP0 	; SELECIONA BANK1 DA MEMORIA RAM
#DEFINE  BANK0  BCF	STATUS,RP0	; SELECIONA BANK0 DA MEMORIA RAM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  POSIÇÃO INICIAL PARA EXECUÇÃO DO PROGRAMA

		ORG		0X0000		; ENDEREÇO DO VETOR DE RESET
		GOTO	INICIO		; DESVIA PARA O INÍCIO DO PROGRAMA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             INTERRUPÇÕES
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

		ORG		0x0004			; ENDEREÇO DO VETOR DE INTERRUPÇÕES
		MOVWF	W_TEMP			; W -> W_TEMP
		SWAPF	STATUS,W		; TROCA NIBBLES STATUS -> W
		MOVWF	STATUS_TEMP		; W -> STATUS_TEMP
		SWAPF	PCLATH,W		; TROCA NIBBLES STATUS -> W
		MOVWF	PCLATH_TEMP		; W -> STATUS_TEMP
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		BCF		STATUS,RP0		; Assegura o BANCO 0 ativo

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
FIMINT	SWAPF	PCLATH_TEMP,W	; TROCA NIBBLES DE STATUS_TEMP -> W
		MOVWF	PCLATH			; W -> STATUS
		SWAPF	STATUS_TEMP,W	; TROCA NIBBLES DE STATUS_TEMP -> W
		MOVWF	STATUS			; W -> STATUS
		SWAPF	W_TEMP,F		; TROCA NIBBLES DE W_TEMP -> W_TEMP
		SWAPF	W_TEMP,W		; TROCA NIBBLES DE W_TEMP -> W
		RETFIE					; FINALIZA A INTERRUPÇÃO

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    		    DEFINES
; *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE  SENSOR		PORTC,0	; BOTÃO DEVE SER LIGADO EM PORTC.0
#DEFINE  SAIDA		PORTB,0	; LED DEVE SER LIGADO EM PORTB.0


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         PROGRAMA PRINCIPAL
; *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;LIGAR O BOTÃO NO PORTC PARA SIMULAR O SENSOR DE UMIDADE E UM LED NO PORTB
;PARA SIMULAR A SAÍDA PARA O SISTEMA DE IRRIGAÇÃO

INICIO

		BANK0					;ALTERA PARA O BANCO 0
		MOVLW	0x00			;ESCREVE 0x00H NO ACUMULADOR
		MOVWF	PORTA			;SETA TODOS OS BITS DO PORTA EM ZERO
		MOVWF	PORTB			;EXECUTA A MESMA FUNÇÃO ANTERIOR
		MOVWF	PORTC			;IDEM
		

		BANK1					;MUDA PARA O BANCO 1
		MOVWF	TRISB			;DEFINE TODOS OS BITS DO PORTB COMO SAÍDA
		MOVLW	0xFF			;ESCREVE 0xFF NO ACUMUDADOR
		MOVWF	TRISC			;DEFINE TODOS OS BITS DO PORTC COMO ENTRADA
		BANK0					;RETORNA AO BANCO 0
		
		GOTO	LESENSOR		;FAZ A LEITURA DO NÍVEL LÓGICO DO SENSOR


LESENSOR
		BTFSC	SENSOR			;BIT TEST FILE SKIP IF CLEAR (TESTA O BIT DO SENSOR, SE FOR ZERO PULA A LINHA IMEDIATAMENTE ABAIXO)
		GOTO	LIGA			;SE O TESTE ACIMA FOR 1, LIGA O SISTEMA
		GOTO	DESLIGA			;VAI PARA A ROTINA QUE DESLIGA O SISTEMA
		

LIGA	
		BSF		SAIDA			;SETA A SAÍDA EM NÍVEL LÓGICO 1
		GOTO	DELAY			;CHAMA A SUB-ROTINA PARA ESPERAR DEBOUNCE DA TECLA
		GOTO	LESENSOR		;VOLTA À LEITURA DO SENSOR

DESLIGA
		BCF		SAIDA			;FAZ A MESMA COISA, COM A DIFERENÇA QUE LIMPA A SAÍDA
		GOTO	DELAY
		GOTO	LESENSOR

;A SUBROTINA À SEGUIR FAZ COM QUE O uC NÃO FAÇA NADA POR UM TEMPO
;O TEMPO APROXIMADO DE DURAÇÃO DA SUBROTINA DELAY É DE APROXIMADAMENTE
;100ms. SERÁ CHAMADA SEMPRE QUE A LEITURA DO SENSOR FOR REALIZADA.
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            SUBROTINAS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

DELAY
		MOVLW	0xFF 		;MOVE 0xFF PARA O ACUMULADOR
		MOVWF	CONT1		;MOVE O CONTEÚDO DO ACUMULADOR PARA A PRIMEIRA VARIÁVEL DE CONTAGEM
		MOVWF	CONT2		;MOVE O CONTEÚDO DO ACUMULADOR PARA A SEGUNDA VARIÁVEL DE CONTAGEM
X1		DECFSZ	CONT2,F		;DECREMENTA CONT2, PULA A LINHA SE CONT2 FOR ZERO
		GOTO	X1			;RETORNA À LINHA X1
		DECFSZ	CONT1,F		;DECREMENTA CONT1, PULA A LINHA SE CONT1 FOR ZERO
		GOTO	X1			;RETORNA À LINHA X1
		RETURN				;RETORNA PARA A O PROGRAMA PRINCIAL

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            FIM DO PROGRAMA
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

		END				; FIM DO PROGRAMA
