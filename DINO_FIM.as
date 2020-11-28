;Constantes
TERM_WRITE      EQU     FFFEh
TERM_CURSOR     EQU     FFFCh
TERM_STATUS     EQU     FFFDh
TERM_READ       EQU     FFFFh
TERM_COLOR      EQU     FFFBh
TER_INIT        EQU     2000h

dim             EQU     80
SP              EQU     7000h

INT_MASK        EQU     FFFAh
INT_MASK_VAL    EQU     8001h

TMP_COUNTER     EQU     FFF6h
TMP_CONTROL     EQU     FFF7h
TMP_SETSTART    EQU     1
TMP_SETSTOP     EQU     0
COUNT_VAL       EQU     1

ALT_SALTO       EQU     5

DINO_POS        EQU     0Dh

ORIG            0000h

Terreno         TAB     80

ORIG            5000h
X               WORD    5
START_GAME      WORD    0
TIMER_TICK      WORD    0
CHAO_DINO       WORD    1F0Dh
TETO_DINO       WORD    1D0Dh
JMP_TICK        WORD    0
ALT_ATUAL       WORD    ALT_SALTO
DOWN_TICK       WORD    0
TerminalStr     STR     0,1,1200h,'                     █▀▀ ▄▀█ █▀▄▀█ █▀▀   █▀█ █░█ █▀▀ █▀█      ',0,0
TerminalStr2    STR     0,1,1300h,'                     █▄█ █▀█ █░▀░█ ██▄   █▄█ ▀▄▀ ██▄ █▀▄',0,0


ORIG            0000h


MAIN:           MVI     R6, SP
                MVI     R1, INT_MASK
                MVI     R2, INT_MASK_VAL
                STOR    M[R1], R2
                ENI
                
                

LOOP:           MVI     R1, START_GAME
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    LOOP
                
                MVI     R1, dim
                MVI     R2, Terreno
                JAL     limpa_terreno
                
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
                
                
TIMERLOOP:      MVI     R1, TIMER_TICK
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    TIMERLOOP
                JAL     PROCESS_TIME
                
                
callfun:        DSI
                MVI     R1, TERM_CURSOR
                MVI     R2, TER_INIT
                STOR    M[R1], R2
                
                MVI     R1, Terreno
                MVI     R2, dim
                JAL     atualizajogo
                
                MVI     R1, Terreno
                MVI     R2, dim
                JAL     escreveterreno
                
                MVI     R1, TERM_STATUS
                LOAD    R2, M[R1]
                CMP     R2, R0
                JAL.NZ  PROCESS_JUMP
                
                MVI     R1, JMP_TICK
                LOAD    R1, M[R1]
                CMP     R1, R0
                JAL.Z   escrevedino
                
                MVI     R1, JMP_TICK
                LOAD    R1, M[R1]
                CMP     R1, R0
                JAL.NZ  saltodino
                
                MVI     R1, Terreno
                JAL     game_over
                
                ENI
                BR      TIMERLOOP ;Atualiza o terreno varias vezes
                
                
PROCESS_TIME:   MVI     R2, TIMER_TICK
                DSI
                LOAD    R1, M[R2]
                DEC     R1
                STOR    M[R2], R1
                ENI
                
                JMP     R7
                
                
limpa_terreno:  MVI     R3, 0
                STOR    M[R2], R3
                INC     R2
                DEC     R1
                BR.Z    .RETURN
                BR      limpa_terreno
                
.RETURN:        JMP     R7
                
                
                

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
                
                
                STOR    M[R1], R3        ;Guardar valor do Cacto
                JMP     R7
                
                
geracato:       MVI     R3, X
                LOAD    R4, M[R3]
                
                MVI     R5, 1
                AND     R2, R4, R5        ;Verifica se é impar -> R2
                SHR     R4
                
                STOR    M[R3], R4
                
                CMP     R2, R5
                BR.NZ   .ELSE
                MVI     R5, b400h
                XOR     R4, R5, R4
                
                STOR    M[R3], R4
                
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
                
                
                
                
desenha_chao:   MVI     R5, TERM_WRITE
                MVI     R4, TERM_CURSOR
                
                STOR    M[R4], R2
                INC     R2
                
                CMP     R1, R0
                BR.Z    .RETURN
                
                MVI     R3, '█'
                STOR    M[R5], R3
                
                DEC     R1
                
                BR      desenha_chao
                
                
.RETURN:        JMP     R7



                
escreveterreno: 
                MVI     R5, TERM_WRITE
                MVI     R4, TER_INIT
                
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R1 
                DEC     R6
                STOR    M[R6], R4
                
                MVI     R1, TERM_CURSOR
                STOR    M[R1], R4
                
                MVI     R1, 4
                
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
                
.REPOR:         LOAD    R4, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                
.GUARDA: 
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R1 
                DEC     R6
                STOR    M[R6], R4               

.COMPARE:       DEC     R2
                CMP     R2, R0
                BR.Z    .RETURN
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    .SALTA
                
                DEC     R6
                STOR    M[R6], R2
                
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
                
.RETURN:        JMP     R7



escrevedino:    MVI     R5, TERM_CURSOR
                MVI     R4, TERM_WRITE
                
                MVI     R1, TERM_COLOR
                MVI     R3, C9h
                STOR    M[R1], R3
                
                MVI     R1, CHAO_DINO
                LOAD    R1, M[R1]
                MVI     R2, 'π'
                STOR    M[R5], R1
                STOR    M[R4], R2
                MVI     R3, 0100h
                SUB     R1, R1, R3
                STOR    M[R5], R1
                MVI     R2, '☺'
                STOR    M[R4], R2
                JMP     R7

saltodino:      DEC     R6
                STOR    M[R6], R7

                MVI     R3, DOWN_TICK
                LOAD    R3, M[R3]
                CMP     R3, R0
                BR.P    .DESCE
                BR.Z    .SOBE
                BR      .RETURN
                
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
                
                JAL     escrevedino
                
                MVI     R2, ALT_ATUAL
                LOAD    R1, M[R2]
                CMP     R1, R0
                BR.Z    .SETJUMP
                
                BR      .RETURN
                
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
                
                
.RESET:         MVI     R1, DOWN_TICK
                STOR    M[R1], R0

                MVI     R1, JMP_TICK
                STOR    M[R1], R0
                BR      .RETURN
                
                
.SETJUMP:       MVI     R1, DOWN_TICK
                MVI     R2, 1
                STOR    M[R1], R2
                BR      .RETURN
                
.RETURN:        LOAD    R7, M[R6]
                INC     R6
                JMP     R7




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



PROCESS_JUMP:   MVI     R1, TERM_READ
                LOAD    R2, M[R1]
                MVI     R1, 24
                CMP     R2, R1
                BR.NZ   .RETURN 
                MVI     R1, JMP_TICK
                MVI     R2, 1
                STOR    M[R1], R2
                
.RETURN:        JMP     R7





game_over:      DEC     R6
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
                BR.P    .RETURN
                JAL     RESET
                LOAD    R7, M[R6]
                INC     R6
                ENI
                JMP     LOOP
                
.RETURN:        LOAD    R7, M[R6]
                INC     R6
                JMP     R7
                
                
                
                
RESET:          MVI     R1, TERM_CURSOR
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

.End:           JMP     R7


ORIG            7F00h
                MVI     R1, START_GAME
                MVI     R2, 1
                STOR    M[R1], R2
                RTI



ORIG            7FF0h
                DEC     R6
                STOR    M[R6], R7
                
                JAL     TIMER_AUX
                
                LOAD    R7, M[R6]
                INC     R6
                RTI










