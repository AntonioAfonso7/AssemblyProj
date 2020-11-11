;Constantes

dim             EQU     80
SP              EQU     7000h

ORIG            0000h

Terreno         TAB     80

ORIG            0000h

TESTE:          ;Apenas para efeitos de teste
                MVI     R1, Terreno
                MVI     R2, 4
                STOR    M[R1], R2
                MVI     R6, 13
                ADD     R1, R1, R6
                STOR    M[R1], R2


MAIN:           MVI     R6, SP
                MVI     R4, 5        ;Define a seed
                
callfun:        MVI     R1, Terreno
                MVI     R2, dim
                JAL     atualizajogo
                
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
                DEC     R6
                STOR    M[R6], R4
                
                MVI     R1, 16        ;Altura máxima
                JAL     geracato
                
                ;Repor valores
                LOAD    R1, M[R6]
                INC     R6
                LOAD    R7, M[R6]
                INC     R6
                
                STOR    M[R1], R3        ;Guardar valor do Cacto
                JMP     R7
                
                
geracato:       LOAD    R4, M[R6]        ;Seed
                INC     R6
                
                MVI     R5, 1
                AND     R2, R4, R5        ;Verifica se é impar -> R2
                SHR     R4
                
                CMP     R2, R5
                BR.NZ   .ELSE
                MVI     R5, b400h
                XOR     R4, R5, R4
                
.ELSE:          MVI     R5, f332h
                CMP     R4, R5
                BR.O    .RETURN         
                MOV     R3, R0 ;Se x < 62258
                
                JMP     R7

.RETURN:        ;mod(x, altura) + 1
                DEC     R1
                AND     R3, R4, R1
                INC     R3
                
                JMP     R7







