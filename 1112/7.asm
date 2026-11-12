
;-----------------------------------------------------
; Average of Five Numbers
; Input five integers and calculate average
; MASM x86 + Windows API
;-----------------------------------------------------

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

ExitProcess PROTO :DWORD
GetStdHandle PROTO :DWORD
WriteConsoleA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ReadConsoleA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11

.data

msg1 BYTE "Enter five numbers:",13,10,0
msg2 BYTE "Enter number: ",0
msg3 BYTE "Average = ",0
newline BYTE 13,10,0

inputBuffer BYTE 64 DUP(0)
numberBuffer BYTE 16 DUP(0)

num1 SDWORD ?
num2 SDWORD ?
num3 SDWORD ?
num4 SDWORD ?
num5 SDWORD ?

total SDWORD ?

hInput DWORD ?
hOutput DWORD ?

charsRead DWORD ?
charsWritten DWORD ?

.code

;-----------------------------------------------------
; Print string
;-----------------------------------------------------

print_string PROC pText:DWORD, textLength:DWORD

    push eax
    push ecx
    push edx

    invoke WriteConsoleA, hOutput, pText, textLength, ADDR charsWritten, 0

    pop edx
    pop ecx
    pop eax

    ret

print_string ENDP


;-----------------------------------------------------
; Read integer from keyboard
;-----------------------------------------------------

read_integer PROC

    LOCAL signValue:DWORD

    push ebx
    push esi
    push edx

    ; Display input prompt
    invoke print_string, ADDR msg2, SIZEOF msg2 - 1

    ; Read keyboard input
    invoke ReadConsoleA, hInput, ADDR inputBuffer, 64, ADDR charsRead, 0

    mov esi, OFFSET inputBuffer
    mov signValue, 1

    ; Check negative sign
    cmp BYTE PTR [esi], '-'
    jne check_positive

    mov signValue, -1
    inc esi
    jmp parse_digits

check_positive:

    cmp BYTE PTR [esi], '+'
    jne parse_digits

    inc esi

parse_digits:

    xor eax, eax

read_loop:

    movzx edx, BYTE PTR [esi]

    cmp edx, '0'
    jb read_done

    cmp edx, '9'
    ja read_done

    imul eax, 10

    sub edx, '0'
    add eax, edx

    inc esi
    jmp read_loop

read_done:

    cmp signValue, -1
    jne read_exit

    neg eax

read_exit:

    pop edx
    pop esi
    pop ebx

    ret

read_integer ENDP


;-----------------------------------------------------
; Print signed integer
;-----------------------------------------------------

print_number PROC value:SDWORD

    push ebx
    push ecx
    push edx
    push edi

    mov eax, value

    lea edi, numberBuffer+15

    xor ebx, ebx

    ; Check negative number
    test eax, eax
    jns convert_loop

    neg eax
    mov ebx, 1

convert_loop:

    xor edx, edx
    mov ecx, 10

    div ecx

    add dl, '0'

    dec edi
    mov [edi], dl

    test eax, eax
    jnz convert_loop

    ; Add minus sign if needed
    cmp ebx, 1
    jne output_number

    dec edi
    mov BYTE PTR [edi], '-'

output_number:

    mov eax, OFFSET numberBuffer+15
    sub eax, edi

    invoke print_string, edi, eax

    pop edi
    pop edx
    pop ecx
    pop ebx

    ret

print_number ENDP


;-----------------------------------------------------
; Main
;-----------------------------------------------------

main PROC

    ; Get console handles
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hInput, eax

    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hOutput, eax

    ; Display title
    invoke print_string, ADDR msg1, SIZEOF msg1 - 1

    ; Input five numbers
    call read_integer
    mov num1, eax

    call read_integer
    mov num2, eax

    call read_integer
    mov num3, eax

    call read_integer
    mov num4, eax

    call read_integer
    mov num5, eax

    ; Calculate sum
    mov eax, num1
    add eax, num2
    add eax, num3
    add eax, num4
    add eax, num5

    mov total, eax

    ; Calculate average
    cdq
    mov ebx, 5
    idiv ebx

    ; Save average
    mov total, eax

    ; Display result
    invoke print_string, ADDR msg3, SIZEOF msg3 - 1

    invoke print_number, total

    invoke print_string, ADDR newline, SIZEOF newline - 1

    ; Exit
    invoke ExitProcess, 0

main ENDP

END main
