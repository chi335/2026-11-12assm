
; StringLibraryDemo.asm
; Visual Studio + MASM + Windows API
; 32-bit x86

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

ExitProcess PROTO STDCALL :DWORD
GetStdHandle PROTO STDCALL :DWORD
WriteConsoleA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

STD_OUTPUT_HANDLE EQU -11

.data

string_1 BYTE "abcde////",0
string_2 BYTE "ABCDE",0

msg0 BYTE "string_1 in uppercase: ",0
msg1 BYTE "string_1 and string_2 are equal",0
msg2 BYTE "string_1 is less than string_2",0
msg3 BYTE "string_2 is less than string_1",0
msg4 BYTE "Length of string_2 is: ",0
msg5 BYTE "string_1 after trimming: ",0

newline BYTE 13,10,0

numberBuffer BYTE 12 DUP(0)
written DWORD 0
stringLength DWORD 0

.code

; --------------------------------
; 문자열 출력
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
; 줄바꿈
; --------------------------------

print_newline PROC

    invoke print_string, OFFSET newline
    ret

print_newline ENDP


; --------------------------------
; 대문자 변환
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

    ret

upper_case ENDP


; --------------------------------
; 문자열 비교
; --------------------------------

compare_strings PROC

    mov esi, OFFSET string_1
    mov edi, OFFSET string_2

compare_loop:

    mov al, [esi]
    mov bl, [edi]

    cmp al, bl
    jb string_less
    ja string_greater

    cmp al, 0
    je strings_equal

    inc esi
    inc edi

    jmp compare_loop

strings_equal:

    invoke print_string, OFFSET msg1
    jmp compare_done

string_less:

    invoke print_string, OFFSET msg2
    jmp compare_done

string_greater:

    invoke print_string, OFFSET msg3

compare_done:

    call print_newline
    ret

compare_strings ENDP


; --------------------------------
; 숫자 출력
; 여러 자리 숫자 지원
; --------------------------------

print_number PROC value:DWORD

    push ebx
    push edi

    mov eax, value

    lea edi, numberBuffer+10

    mov BYTE PTR [edi], 0

    mov ebx, 10

    cmp eax, 0
    jne convert_loop

    dec edi
    mov BYTE PTR [edi], '0'
    jmp number_done

convert_loop:

    xor edx, edx
    div ebx

    add dl, '0'

    dec edi
    mov [edi], dl

    test eax, eax
    jnz convert_loop

number_done:

    invoke print_string, edi

    pop edi
    pop ebx

    ret

print_number ENDP


; --------------------------------
; 문자열 길이 계산
; --------------------------------

print_length PROC

    mov esi, OFFSET string_2
    xor ecx, ecx

length_loop:

    cmp BYTE PTR [esi+ecx], 0
    je length_done

    inc ecx
    jmp length_loop

length_done:

    mov stringLength, ecx

    invoke print_string, OFFSET msg4

    invoke print_number, stringLength

    call print_newline

    ret

print_length ENDP


; --------------------------------
; 뒤쪽 '/' 제거
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

    ret

trim_string ENDP


; --------------------------------
; 메인 함수
; --------------------------------

main PROC

    ; 대문자 변환
    call upper_case

    invoke print_string, OFFSET msg0
    invoke print_string, OFFSET string_1
    call print_newline

    ; 문자열 비교
    call compare_strings

    ; 문자열 길이 출력
    call print_length

    ; 뒤쪽 슬래시 제거
    call trim_string

    invoke print_string, OFFSET msg5
    invoke print_string, OFFSET string_1
    call print_newline

    invoke ExitProcess, 0

main ENDP

END main
