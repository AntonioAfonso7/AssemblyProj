;=================================================================
; CONSTANTES
;-----------------------------------------------------------------
;Text window
TERM_WRITE      EQU     FFFEh
TERM_CURSOR     EQU     FFFCh
TERM_STATUS     EQU     FFFDh
TERM_READ       EQU     FFFFh
TERM_COLOR      EQU     FFFBh
TER_INIT        EQU     2000h

; 7 segment display
DISP7_D0        EQU     FFF0h
DISP7_D1        EQU     FFF1h
DISP7_D2        EQU     FFF2h
DISP7_D3        EQU     FFF3h
DISP7_D4        EQU     FFEEh
DISP7_D5        EQU     FFEFh

;Interrupções
INT_MASK        EQU     FFFAh
INT_MASK_VAL    EQU     8009h

;Temporizador
TMP_COUNTER     EQU     FFF6h
TMP_CONTROL     EQU     FFF7h
TMP_SETSTART    EQU     1
TMP_SETSTOP     EQU     0
COUNT_VAL       EQU     1

;Relativas ao jogo
dim             EQU     80
SP              EQU     7000h
ALT_SALTO       EQU     6
DINO_POS        EQU     0Dh

;<iniciaçização do vetor do terreno
ORIG            0000h

Terreno         TAB     80

;=================================================================
; VARIÁVEIS GLOBAIS 
;-----------------------------------------------------------------
                ORIG    5000h
;Temporizador
START_GAME      WORD    0
TIMER_TICK      WORD    0

;Sobre o jogo
CHAO_DINO       WORD    1F0Dh
TETO_DINO       WORD    1D0Dh
JMP_TICK        WORD    0
ALT_ATUAL       WORD    ALT_SALTO
DOWN_TICK       WORD    0
TerminalStr     STR     0,1,1200h,'                     █▀▀ ▄▀█ █▀▄▀█ █▀▀   █▀█ █░█ █▀▀ █▀█      ',0,0
TerminalStr2    STR     0,1,1300h,'                     █▄█ █▀█ █░▀░█ ██▄   █▄█ ▀▄▀ ██▄ █▀▄',0,0
PONT            TAB     7
UP_TICK         WORD    0
X               WORD    5

ORIG            0000h

;===============================================================================
; MAIN: O PONTO DE PARTIDA DO PROGRAMA
;-------------------------------------------------------------------------------
MAIN:           MVI     R6, SP
                MVI     R1, INT_MASK
                MVI     R2, INT_MASK_VAL
                STOR    M[R1], R2
                ENI     ; ativa as interrupções 
                
;-------------------------------------------------------------------------------               
; LOOP: Espera que o jogo comece, e inicializa algumas das variáveis 
;-------------------------------------------------------------------------------
LOOP:           MVI     R1, START_GAME
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    LOOP
                
                DSI
                MVI     R1, dim
                MVI     R2, Terreno
                JAL     limpa_terreno
                
                MVI     R2, PONT
                MVI     R1, 7
                JAL     limpa_pontuacao
                
                MVI     R1, TERM_CURSOR
                MVI     R2, FFFFh
                STOR    M[R1], R2
                
                MVI     R1, START_GAME
                STOR    M[R1], R0
                
                MVI     R1, TERM_COLOR
                MVI     R3, F4h
                STOR    M[R1], R3
                
                MVI     R1, dim
                MVI     R2, TER_INIT
                JAL     desenha_chao
                
                MVI     R1, TMP_COUNTER
                MVI     R2, COUNT_VAL
                STOR    M[R1], R2
                MVI     R1, TMP_CONTROL
                MVI     R2, TMP_SETSTART
                STOR    M[R1], R2
                ENI
;-------------------------------------------------------------------------------
;TIMERLOOP: Espera que a variável TIMER_TICK fique com o valor 1, ou seja,
;           aguarda para que algum evento relacionado com o cronómetro aconteça
;-------------------------------------------------------------------------------
TIMERLOOP:      MVI     R1, TIMER_TICK
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    TIMERLOOP
                JAL     PROCESS_TIME
                
;-------------------------------------------------------------------------------              
;callfun: Chama todas as funções necessárias para o correto funcionamento do
;         jogo
;-------------------------------------------------------------------------------
callfun:        
                MVI     R1, TERM_CURSOR
                MVI     R2, TER_INIT
                STOR    M[R1], R2
                
                MVI     R1, Terreno
                MVI     R2, dim
                JAL     atualizajogo
                
                MVI     R1, UP_TICK
                LOAD    R1, M[R1]
                CMP     R1, R0
                JAL.Z   escrevedino
                
                MVI     R1, UP_TICK
                LOAD    R1, M[R1]
                CMP     R1, R0
                JAL.NZ  saltodino
                
                MVI     R1, Terreno
                MVI     R2, dim
                JAL     escreveterreno
                
                MVI     R1, Terreno
                JAL     game_over
                
                MVI     R1, PONT
                JAL     PONTUACAO
                

                BR      TIMERLOOP ;Atualiza o terreno varias vezes
                
;-------------------------------------------------------------------------------
;PROCESS_TIME: apenas é invocada quando a variável TIMER_TICK está a 1
;              coloca, novamente, esta variável a 0
;-------------------------------------------------------------------------------
PROCESS_TIME:   MVI     R2, TIMER_TICK
                DSI
                LOAD    R1, M[R2]
                DEC     R1
                STOR    M[R2], R1
                ENI
                
                JMP     R7
;--------------------------------------------------------------------------------           
;limpa_terreno: É invocada quando o jogo começa (ou recomeça)
;              - limpa o terreno, de forma a que se gere um novo e diferente jogo
;--------------------------------------------------------------------------------
limpa_terreno:  MVI     R3, 0
                STOR    M[R2], R3
                INC     R2
                DEC     R1
                BR.Z    .RETURN
                BR      limpa_terreno
                
;Regressa ao endereço de retorno
.RETURN:        JMP     R7

;-------------------------------------------------------------------------------
;limpa_pontuacao: É invocada quando o jogo começa (ou recomeça)
;               -limpa a pontuação, para que uma nova pontuação possa ser escrita
;--------------------------------------------------------------------------------
limpa_pontuacao:
                MVI     R3, 0
                STOR    M[R2], R3
                INC     R2
                DEC     R1
                BR.Z    .RETURN
                BR      limpa_pontuacao
                
;retorno da função, inicializando os 6 displays
.RETURN:        MVI     R1, DISP7_D0
                STOR    M[R1], R0
                MVI     R1, DISP7_D1
                STOR    M[R1], R0
                MVI     R1, DISP7_D2
                STOR    M[R1], R0
                MVI     R1, DISP7_D3
                STOR    M[R1], R0
                MVI     R1, DISP7_D4
                STOR    M[R1], R0
                MVI     R1, DISP7_D5
                STOR    M[R1], R0
                
                JMP     R7
                
                
;================================================================================
;atualizajogo: A função vai deslocar todos os elementos do vector uma posição 
;              para a esquerda (isto é, do endereço n para o endereço n-1). 
;              Como tal, o  valor contido na posição mais à esquerda vai ser 
;              eliminado do vector
;================================================================================
atualizajogo:   ;Guardar valores
                DEC     R6
                STOR    M[R6], R7
                DEC     R6
                STOR    M[R6], R4
                
                ;Guardar valor do vetor de R1 + 1
                DEC     R6
                STOR    M[R6], R1
                
                INC     R1
                
                LOAD    R4, M[R1]
                
                LOAD    R1, M[R6]
                INC     R6
                
                ;Guarda em R1 o valor do vetor em R1 + 1
                STOR    M[R1], R4
                
                ;Repor valores para não estragar a stack no loop
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R7, M[R6]
                INC     R6
                
                INC     R1
                DEC     R2
                CMP     R2, R0        ;Verifica se chegamos ao fim do vetor
                BR.NZ   atualizajogo
                
                ;Guardar valores antes da chamada da função
                DEC     R6
                STOR    M[R6], R7
                DEC     R6
                STOR    M[R6], R1
                
                MVI     R1, 4        ;Altura máxima
                JAL     geracato
                
                ;Repor valores
                LOAD    R1, M[R6]
                INC     R6
                LOAD    R7, M[R6]
                INC     R6
                
                
                STOR    M[R1], R3    ;Guardar valor do Cacto
                JMP     R7
                
;================================================================================
;geracato: A função gera um número aleatório, que pode ser zero com uma 
;          probabilidade predefinida de 95%, ou um valor uniformemente 
;          distribuído entre 1 e o valor máximo passado como parâmetro.
;================================================================================
geracato:       MVI     R3, X
                LOAD    R4, M[R3]
                
                MVI     R5, 1
                AND     R2, R4, R5   ;Verifica se é impar -> R2
                SHR     R4
                
                STOR    M[R3], R4
                
                CMP     R2, R5
                BR.NZ   .ELSE
                MVI     R5, b400h
                XOR     R4, R5, R4
                
                STOR    M[R3], R4
                
; Enquanto o valor de R2 não for ímpar, salta para o .ELSE
.ELSE:          MVI     R5, f332h
                CMP     R4, R5
                BR.NC   .RETURN         
                MOV     R3, R0 ;Se x < 62258
                
                JMP     R7

.RETURN:        ;mod(x, altura) + 1
                DEC     R1
                AND     R3, R4, R1
                INC     R3
                
                JMP     R7
                
                
;--------------------------------------------------------------------------------                
;desenha_chao: Através de alguns caracteres especiais, esta função desenha 
;              o chão no qual o dinossauro andará por cima
;--------------------------------------------------------------------------------
desenha_chao:   DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5

                MVI     R5, TERM_WRITE
                MVI     R4, TERM_CURSOR
                
                STOR    M[R4], R2
                INC     R2
                
                CMP     R1, R0
                BR.Z    .RETURN
                
                MVI     R3, '█'
                STOR    M[R5], R3
                
                DEC     R1
                
                BR      desenha_chao
                
; Regressa para o endereço de retorno (guardado em R7)                
.RETURN:        LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7



;--------------------------------------------------------------------------------
;escreveterreno: Esta função escreve o vetor do terreno atualizado através da
;                função atualizajogo
;--------------------------------------------------------------------------------
escreveterreno: DEC     R6 
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5

                MVI     R5, TERM_WRITE
                MVI     R4, TER_INIT
                
                ;Guarda os valores de R2, R1 e R4, respetivamente
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R1 
                DEC     R6
                STOR    M[R6], R4
                
                MVI     R1, TERM_CURSOR
                STOR    M[R1], R4
                
                MVI     R1, 4

; apaga o início do terreno
.APAGA_INICIO:  CMP     R1, R0
                BR.Z    .REPOR
                MVI     R2, TERM_CURSOR
                MVI     R3, 0100h
                SUB     R4, R4, R3
                STOR    M[R2], R4
                
                
                MVI     R2, 0
                STOR    M[R5], R2
                
                DEC     R1
                BR      .APAGA_INICIO

; Repõe os valores salvaguardados na stack
.REPOR:         LOAD    R4, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                
; Guarda os valores salvaguardados na stack                
.GUARDA: 
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R1 
                DEC     R6
                STOR    M[R6], R4               

; Verifica se o terreno já chegou ao fim
.COMPARE:       DEC     R2
                CMP     R2, R0
                BR.Z    .RETURN
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    .SALTA
                
                DEC     R6
                STOR    M[R6], R2
                
; Escreve o cacto
.CACTO:         MVI     R1, TERM_CURSOR
                MVI     R3, 0100h
                SUB     R4, R4, R3
                STOR    M[R1], R4
                
                MVI     R1, TERM_COLOR
                MVI     R3, Ch
                STOR    M[R1], R3
                
                MVI     R1, '┤'
                STOR    M[R5], R1
                DEC     R2
                
                BR.NZ   .CACTO
                
                LOAD    R2, M[R6]
                INC     R6
                
                INC     R4

; Apaga a posição anterior onde o cato esteve
.APAGA:         
                MVI     R3, 0
                STOR    M[R5], R3
                
                MVI     R1, TERM_CURSOR
                MVI     R3, 0100h
                ADD     R4, R4, R3
                STOR    M[R1], R4
                
                DEC     R2
                BR.NZ   .APAGA
                
                DEC     R4

; Atualiza os valores de R4, R2, R1 e R3, respetivamente 
.SALTA:         LOAD    R4, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                
                INC     R4
                
                DEC     R2
                INC     R1
                MOV     R3, R0
                BR      .GUARDA        
                
; Regressa ao endereço de retorno, salvaguardado em R7
.RETURN:        LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7


;===============================================================================
;escrevedino: Esta função vai desenha o dinossauro
;===============================================================================
escrevedino:    DEC     R6 
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                MVI     R5, TERM_CURSOR
                MVI     R4, TERM_WRITE
                
                MVI     R1, TERM_COLOR
                MVI     R3, C9h
                STOR    M[R1], R3
                
                MVI     R1, CHAO_DINO
                LOAD    R1, M[R1]
                MVI     R2, 'π'         ; <--- arquitetura do dino, pt.1
                STOR    M[R5], R1
                STOR    M[R4], R2


                MVI     R3, 0100h
                SUB     R1, R1, R3
                STOR    M[R5], R1
                MVI     R2, '☺'        ; <--- arquitetura do dino, pt.2 
                STOR    M[R4], R2
                
                ;Repõe os valores da pilha e regressa para o endereço de retorno
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7
;===============================================================================
;saltodino: Esta função permite ao dinossauro executar o salto, sem que o terreno
;           se mova com ele
;===============================================================================
saltodino:      DEC     R6 
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                DEC     R6
                STOR    M[R6], R7
                
                ; Verifica se o dinossauro está a subir ou a descer
                MVI     R3, DOWN_TICK
                LOAD    R3, M[R3]
                CMP     R3, R0
                BR.P    .DESCE
                BR.Z    .SOBE
                BR      .RETURN

; Caso o dinossauro esteja a subir, a sua posição vai elevar-se em 1 linha
.SOBE:          MVI     R2, ALT_ATUAL
                LOAD    R1, M[R2]
                DEC     R1
                STOR    M[R2], R1
                
                MVI     R1, TETO_DINO
                LOAD    R2, M[R1]
                
                MVI     R3, 0100h
                SUB     R2, R2, R3
                STOR    M[R1], R2
                
                MVI     R1, CHAO_DINO
                LOAD    R2, M[R1]
                
                MVI     R5, TERM_CURSOR
                STOR    M[R5], R2
                
                MVI     R5, TERM_WRITE
                MVI     R3, 0
                STOR    M[R5], R3
                
                MVI     R3, 0100h
                SUB     R2, R2, R3
                STOR    M[R1], R2
                
; aquando da posição de salto, esccreve-se o dinossauro 
                JAL     escrevedino
                
                MVI     R2, ALT_ATUAL
                LOAD    R1, M[R2]
                CMP     R1, R0
                BR.Z    .SETJUMP
                
                BR      .RETURN

; Caso o dinossauro esteja a descer, a sua posição vai diminuir-se em 1 linha
.DESCE:         MVI     R2, ALT_ATUAL
                LOAD    R1, M[R2]
                INC     R1
                STOR    M[R2], R1
                
                MVI     R1, CHAO_DINO
                LOAD    R2, M[R1]
                MVI     R3, 0100h
                ADD     R2, R2, R3
                STOR    M[R1], R2
                
                JAL     escrevedino
                
                MVI     R1, TETO_DINO
                LOAD    R2, M[R1]
                
                MVI     R3, 0100h
                ADD     R2, R2, R3
                STOR    M[R1], R2
                
                MVI     R5, TERM_CURSOR
                STOR    M[R5], R2
                
                MVI     R5, TERM_WRITE
                MVI     R3, 0
                STOR    M[R5], R3
                
                MVI     R2, ALT_ATUAL
                LOAD    R1, M[R2]

                MVI     R3, ALT_SALTO
                CMP     R3, R1
                BR.Z    .RESET
                
                BR      .RETURN
                
;Repõe a variável DOWN_TICK ao valor 0             
.RESET:         MVI     R1, DOWN_TICK
                STOR    M[R1], R0

                MVI     R1, UP_TICK
                STOR    M[R1], R0
                BR      .RETURN
                
;Coloca a variável DOWN_TICK a 1              
.SETJUMP:       MVI     R1, DOWN_TICK
                MVI     R2, 1
                STOR    M[R1], R2
                BR      .RETURN
                
;Regressa ao endereço de retorno, repondo os valores da stack
.RETURN:        LOAD    R7, M[R6]
                INC     R6
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7



;-------------------------------------------------------------------------------
;TIMER_AUX: Função auxiliar ao temporizador 
;-------------------------------------------------------------------------------
TIMER_AUX:      DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2

                MVI     R1, TIMER_TICK
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2
                
                MVI     R1, TMP_COUNTER
                MVI     R2, COUNT_VAL
                STOR    M[R1], R2
                MVI     R1, TMP_CONTROL
                MVI     R2, TMP_SETSTART
                STOR    M[R1], R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                JMP     R7


;================================================================================
;gameover: Função que verifica se o jogador perdeu o jogo, ou seja, se tocou
;          num cato. Para averiguar o gameover, verifica-se se, no momento em 
;          que o jogador está na mesma coluna que um certo cato, se a sua altura
;          é menor ou igual à do mesmo (se for esse o caso, significa que perdeu)
;================================================================================
game_over:      ;salvaguardar o contexto
                DEC     R6
                STOR    M[R6], R7

                MVI     R2, DINO_POS
                ADD     R1, R1, R2
                
                LOAD    R2, M[R1]        ;ALTURA DO CACTO -> R2
                CMP     R2, R0
                BR.Z    .RETURN 
                
                MVI     R1, CHAO_DINO
                LOAD    R1, M[R1]
                
                MVI     R3, 8
.LOOP:          SHR     R1
                DEC     R3
                BR.NZ   .LOOP
                
                MVI     R3, 20h
                SUB     R1, R3, R1
                DEC     R1
                
                CMP     R1, R2        ;R1 <= R2 -> R1 - R2 <= 0
                
                ; se altura_dino > altura_cato, o jogo continua
                BR.P    .RETURN
                ; se altura_dino <= altura_cato, o jogo acaba
                JAL     RESET
                LOAD    R7, M[R6]
                INC     R6

                JMP     LOOP
                
; Regressa ao endereço de retorno, salvaguardado em R7
.RETURN:        LOAD    R7, M[R6]
                INC     R6
                JMP     R7
                
                
; Caso o jogador perca, o sinal 'GAME OVER' deverá aparecer

; As funções que se seguem são obtidas do editor de texto da placa gráfica
; de forma a que o sinal 'GAME OVER' seja corretamente desenhado e centrado 
; no ecrã do programa 
RESET:          DEC     R6 
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                MVI     R1, TERM_CURSOR
                MVI     R2, FFFFh
                STOR    M[R1], R2
                
                MVI     R1, TERM_WRITE
                MVI     R2, TERM_CURSOR
                MVI     R3, TERM_COLOR
                MVI     R4, TerminalStr

.TerminalLoop:
                LOAD    R5, M[R4]
                INC     R4
                CMP     R5, R0
                BR.Z    .Control
                STOR    M[R1], R5
                BR      .TerminalLoop

.Control:
                LOAD    R5, M[R4]
                INC     R4
                DEC     R5
                BR.Z    .Position
                DEC     R5
                BR.Z    .Color
                BR      .End1

.Position:
                LOAD    R5, M[R4]
                INC     R4
                STOR    M[R2], R5
                BR      .TerminalLoop

.Color:
                LOAD    R5, M[R4]
                INC     R4
                STOR    M[R3], R5
                BR      .TerminalLoop

.End1:          

                MVI     R1, TERM_WRITE
                MVI     R2, TERM_CURSOR
                MVI     R3, TERM_COLOR
                MVI     R4, TerminalStr2

.TerminalLoop2:
                LOAD    R5, M[R4]
                INC     R4
                CMP     R5, R0
                BR.Z    .Control2
                STOR    M[R1], R5
                BR      .TerminalLoop2

.Control2:
                LOAD    R5, M[R4]
                INC     R4
                DEC     R5
                BR.Z    .Position2
                DEC     R5
                BR.Z    .Color2
                BR      .End

.Position2:
                LOAD    R5, M[R4]
                INC     R4
                STOR    M[R2], R5
                BR      .TerminalLoop2

.Color2:
                LOAD    R5, M[R4]
                INC     R4
                STOR    M[R3], R5
                BR      .TerminalLoop2

.End:           LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7


;================================================================================
;PONTUACAO: Esta função é usada para reproduzir a pontuação que o jogador obteve
;           no jogo. Deste modo, em cada atualizacao do terreno, o jogador recebe
;           1 valor de score, que será reproduzido e atualizado no ecrã LCD
;================================================================================
PONTUACAO:      DEC     R6 
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                LOAD    R2, M[R1]
                
                INC     R2
                MVI     R3, Ah
;Como o valor reproduzido no ecrã seria em hexadecimal, tem de se passar este 
;valor para decimal, ou seja, sempre que algum dos dígitos atingir o número Ah
;(10 em decimal) significa que esse dígito do display deverá passar a ter o valor
; 0, e o dígito do LCD seguinte o valor 1 (isto apenas é válido porque os 9 
;primeiros valores em hexadecimal e decimal são iguais)
                CMP     R2, R3
                BR.Z    .EXCECAO
                
                STOR    M[R1], R2
                
; Quando as necessárias condições se verificarem, escreve-se então o número no
; display LCD
.ESCREVE:                       
                MVI     R1, PONT
                LOAD    R2, M[R1]
                MVI     R4, DISP7_D0
                STOR    M[R4], R2
                
                INC     R1
                LOAD    R2, M[R1]
                MVI     R4, DISP7_D1
                STOR    M[R4], R2
                
                INC     R1
                LOAD    R2, M[R1]
                MVI     R4, DISP7_D2
                STOR    M[R4], R2
                
                INC     R1
                LOAD    R2, M[R1]
                MVI     R4, DISP7_D3
                STOR    M[R4], R2
                
                INC     R1
                LOAD    R2, M[R1]
                MVI     R4, DISP7_D4
                STOR    M[R4], R2
               
                INC     R1
                LOAD    R2, M[R1]
                MVI     R4, DISP7_D5
                STOR    M[R4], R2
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6

;Após escrever o valor da pontuação, regressa para o endereço de retorno
                JMP     R7
                
;Caso o valor seja Ah, tem de se converter esta nomenclatura para decimal
.EXCECAO:       STOR    M[R1], R0
                INC     R1
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2
                MVI     R3, Ah
                CMP     R2, R3
                BR.Z    .EXCECAO
                
                BR      .ESCREVE

; Coloca-se a variável START_GAME a 1, e regressa-se ao endereço das interrupções
ORIG            7F00h
                MVI     R1, START_GAME
                MVI     R2, 1
                STOR    M[R1], R2
                RTI

; Coloca-se a variável UP_TICK a 1, e regressa-se ao endereço das interrupções
ORIG            7F30h
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R1
                
                MVI     R1, UP_TICK
                MVI     R2, 1
                STOR    M[R1], R2

                LOAD    R1, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                RTI
; Endereço usado para invocar a função TIMER_AUX, e regressa-se ao endereço das 
; interrupções
ORIG            7FF0h
                DEC     R6
                STOR    M[R6], R7
                
                JAL     TIMER_AUX
                
                LOAD    R7, M[R6]
                INC     R6
                RTI

;===============================================================================
;------------------------------------FIM----------------------------------------