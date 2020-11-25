;Constantes
TERM_WRITE      EQU     FFFEh
TERM_CURSOR     EQU     FFFCh
TER_INIT        EQU     1000h
dim             EQU     80
SP              EQU     7000h


ORIG            0000h

Terreno         TAB     80

ORIG            5000h
X               WORD    5

ORIG            0000h

TESTE:          ;Apenas para efeitos de teste
                MVI     R1, Terreno
                MVI     R2, 4
                STOR    M[R1], R2
                MVI     R6, 13
                ADD     R1, R1, R6
                STOR    M[R1], R2


MAIN:           MVI     R6, SP

                
callfun:        MVI     R1, TERM_CURSOR
                MVI     R2, TER_INIT
                STOR    M[R1], R2
                MVI     R1, Terreno
                MVI     R2, dim
                JAL     atualizajogo
                MVI     R1, Terreno
                MVI     R2, dim
                JAL     escreveterreno
                BR      callfun        ;Atualiza o terreno varias vezes
                
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
                
                MVI     R1, 8        ;Altura máxima
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
                
                
                
escreveterreno: 
                MVI     R5, TERM_WRITE
                MVI     R4, TER_INIT
                
.GUARDA: 
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R1 
                DEC     R6
                STOR    M[R6], R4               
.COMUN:                         
                DEC     R2
                BR.Z    .RETURN
                LOAD    R3, M[R1]
                MVI     R1, 8
                CMP     R3, R0
                BR.Z    .ESCREVE
                

.CACTO_SERIO:   
                MVI     R1, TERM_CURSOR
                STOR    M[R1], R4
                MVI     R1, '0'
                STOR    M[R5], R1
                MVI     R2, 0100h
                SUB     R4, R4, R2
                DEC     R3
                BR.NZ   .CACTO_SERIO
                
                BR      .SALTA
                
                
.ESCREVE:       
                MVI     R2, TERM_CURSOR
                STOR    M[R2], R4
                MVI     R3, '0'
                STOR    M[R5], R3
                MVI     R2, 0100h
                SUB     R4, R4, R2
                BR      .APAGA
                
                
.APAGA:         DEC     R1
                BR.Z    .SALTA
                MVI     R2, TERM_CURSOR
                STOR    M[R2], R4
                MVI     R3, 0
                STOR    M[R5], R3
                MVI     R2, 0100h
                SUB     R4, R4, R2
                BR      .APAGA
                
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







