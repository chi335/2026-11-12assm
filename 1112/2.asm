
; StringLibraryDemo.asm
; Visual Studio MASM x86
; Windows API

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

; Windows API declarations
ExitProcess PROTO STDCALL :DWORD
GetStdHandle PROTO STDCALL :DWORD
WriteConsoleA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

STD_OUTPUT_HANDLE EQU -11

.data

string_1 BYTE "abcde////",0

msg0 BYTE "string_1 in uppercase: ",0
msg5 BYTE "string_1 after trimming: ",0

newline BYTE 13,10,0

written DWORD 0

.code

; --------------------------------
; Print string
; --------------------------------

print_string PROC pString:DWORD

    push esi

    mov esi, pString
    xor ecx, ecx

count_loop:
    cmp BYTE PTR [esi+ecx], 0
    je output_string

    inc ecx
    jmp count_loop

output_string:

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
; Trim trailing '/'
; --------------------------------

trim_string PROC

    mov esi, OFFSET string_1

find_end:

    cmp BYTE PTR [esi], 0
    je trim_check

    inc esi
    jmp find_end

trim_check:

    dec esi

trim_loop:

    cmp esi, OFFSET string_1
    jb trim_done

    cmp BYTE PTR [esi], '/'
    jne trim_done

    mov BYTE PTR [esi], 0

    dec esi
    jmp trim_loop

trim_done:

    invoke print_string, OFFSET msg5
    invoke print_string, OFFSET string_1

    call print_newline

    ret

trim_string ENDP


; --------------------------------
; Convert lowercase to uppercase
; --------------------------------

upper_case PROC

    mov esi, OFFSET string_1

upper_loop:

    mov al, [esi]

    cmp al, 0
    je upper_done

    cmp al, 'a'
    jb upper_next

    cmp al, 'z'
    ja upper_next

    sub BYTE PTR [esi], 20h

upper_next:

    inc esi
    jmp upper_loop

upper_done:

    invoke print_string, OFFSET msg0
    invoke print_string, OFFSET string_1

    call print_newline

    ret

upper_case ENDP


; --------------------------------
; Main procedure
; --------------------------------

main PROC

    call trim_string

    call upper_case

    invoke ExitProcess, 0

main ENDP

END main
