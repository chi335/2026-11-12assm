
; Project3.asm
; MASM x86 + Windows API

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

ExitProcess PROTO STDCALL :DWORD
GetStdHandle PROTO STDCALL :DWORD
WriteConsoleA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

STD_OUTPUT_HANDLE EQU -11

.data

string_1 BYTE "abcde",0
string_2 BYTE "ABCDE",0

msg1 BYTE "string_1 and string_2 are equal",0
msg2 BYTE "string_1 is less than string_2",0
msg3 BYTE "string_2 is less than string_1",0
msg4 BYTE "Length of string_2 is: ",0

newline BYTE 13,10,0

written DWORD 0
numberBuffer BYTE 12 DUP(0)

.code

; --------------------------------
; Print string
; --------------------------------

print_string PROC pString:DWORD

    push esi

    mov esi, pString
    xor ecx, ecx

ps_loop:
    cmp BYTE PTR [esi+ecx], 0
    je ps_output

    inc ecx
    jmp ps_loop

ps_output:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    invoke WriteConsoleA, eax, pString, ecx, ADDR written, 0

    pop esi
    ret

print_string ENDP


; --------------------------------
; Print newline
; --------------------------------

print_newline PROC

    invoke print_string, OFFSET newline
    ret

print_newline ENDP


; --------------------------------
; Print decimal number
; --------------------------------

print_number PROC value:DWORD

    push ebx
    push edi

    mov eax, value
    lea edi, numberBuffer+10

    mov BYTE PTR [edi], 0
    mov ebx, 10

    cmp eax, 0
    jne pn_loop

    dec edi
    mov BYTE PTR [edi], '0'
    jmp pn_done

pn_loop:
    xor edx, edx
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz pn_loop

pn_done:
    invoke print_string, edi

    pop edi
    pop ebx
    ret

print_number ENDP


; --------------------------------
; Compare strings
; --------------------------------

compare_strings PROC

    mov esi, OFFSET string_1
    mov edi, OFFSET string_2

cs_loop:
    mov al, [esi]
    mov bl, [edi]

    cmp al, bl
    jb cs_less
    ja cs_greater

    cmp al, 0
    je cs_equal

    inc esi
    inc edi
    jmp cs_loop

cs_equal:
    invoke print_string, OFFSET msg1
    jmp cs_done

cs_less:
    invoke print_string, OFFSET msg2
    jmp cs_done

cs_greater:
    invoke print_string, OFFSET msg3

cs_done:
    call print_newline
    ret

compare_strings ENDP


; --------------------------------
; Print string length
; --------------------------------

print_length PROC

    mov esi, OFFSET string_2
    xor ecx, ecx

pl_loop:
    cmp BYTE PTR [esi+ecx], 0
    je pl_done

    inc ecx
    jmp pl_loop

pl_done:
    invoke print_string, OFFSET msg4
    invoke print_number, ecx

    call print_newline
    ret

print_length ENDP


; --------------------------------
; Main
; --------------------------------

main PROC

    call compare_strings
    call print_length

    invoke ExitProcess, 0

main ENDP

END main
