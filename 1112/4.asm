
;---------------------------------------------------------
; Project4.asm
; Calculate the sum of a row in a byte matrix
; MASM x86 + Windows API
;---------------------------------------------------------

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

ExitProcess PROTO :DWORD
GetStdHandle PROTO :DWORD
WriteConsoleA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

STD_OUTPUT_HANDLE EQU -11

.data

; 3 x 3 byte matrix
matrix BYTE 1,2,3
       BYTE 4,5,6
       BYTE 7,8,9

msg BYTE "Row sum: ",0
newline BYTE 13,10,0

written DWORD 0
numberBuffer BYTE 12 DUP(0)

.code

;---------------------------------------------------------
; Print string
;---------------------------------------------------------

print_string PROC pString:DWORD

    push esi

    mov esi, pString
    xor ecx, ecx

ps_loop:
    cmp BYTE PTR [esi+ecx],0
    je ps_output

    inc ecx
    jmp ps_loop

ps_output:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    invoke WriteConsoleA, eax, pString, ecx, ADDR written, 0

    pop esi
    ret

print_string ENDP


;---------------------------------------------------------
; Print number
;---------------------------------------------------------

print_number PROC value:DWORD

    push ebx
    push edi

    mov eax, value
    lea edi, numberBuffer+10

    mov BYTE PTR [edi],0
    mov ebx,10

pn_loop:
    xor edx,edx
    div ebx

    add dl,'0'
    dec edi
    mov [edi],dl

    test eax,eax
    jnz pn_loop

    invoke print_string,edi

    pop edi
    pop ebx
    ret

print_number ENDP


;---------------------------------------------------------
; calc_row_sum
; EBX = matrix address
; EAX = row index
; ECX = row size
; Returns EAX = sum
;---------------------------------------------------------

calc_row_sum PROC

    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Save matrix address
    mov esi,ebx

    ; Save row size
    mov edi,ecx

    ; Calculate row offset
    mul edi

    ; Calculate row address
    add esi,eax

    ; Initialize sum
    xor eax,eax

    ; Initialize column index
    xor ecx,ecx

row_loop:

    cmp ecx,edi
    jae row_done

    movzx edx,BYTE PTR [esi+ecx]

    add eax,edx

    inc ecx
    jmp row_loop

row_done:

    ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    ret

calc_row_sum ENDP


;---------------------------------------------------------
; Main
;---------------------------------------------------------

main PROC

    ; Calculate second row
    mov ebx,OFFSET matrix
    mov eax,1
    mov ecx,3

    call calc_row_sum

    ; Display result
    push eax

    invoke print_string,OFFSET msg

    pop eax
    invoke print_number,eax

    invoke ExitProcess,0

main ENDP

END main
