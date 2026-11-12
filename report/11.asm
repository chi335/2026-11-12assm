.386
.model flat, stdcall
.stack 4096

; ---------------------------------------------------------------
; 윈도우 기본 API 함수 직접 선언 (외부 .inc 파일 포함 X)
; ---------------------------------------------------------------
ExitProcess PROTO, dwExitCode:DWORD
GetStdHandle PROTO, nStdHandle:DWORD
WriteConsoleA PROTO, 
    hConsoleOutput:DWORD, 
    lpBuffer:PTR BYTE, 
    nNumberOfCharsToWrite:DWORD, 
    lpNumberOfCharsWritten:PTR DWORD, 
    lpReserved:PTR DWORD

; 프로토타입 선언
GenerateMatrix PROTO
RandomRange PROTO, nRange:DWORD
IsVowel PROTO, charVal:BYTE
CheckAndPrintSet PROTO, c0:BYTE, c1:BYTE, c2:BYTE, c3:BYTE
PrintString PROTO, pStr:PTR BYTE

.data
vowels      BYTE "AEIOU", 0                       ; 5개 모음
consonants  BYTE "BCDFGHJKLMNPQRSTVWXYZ", 0       ; 21개 자음

matrix      BYTE 16 DUP(?)                       ; 4x4 행렬 저장 공간 (16바이트)
seed        DWORD 987654321                      ; 난수 생성용 시드(Seed) 값

outHandle   DWORD ?
bytesWritten DWORD ?

charBuffer  BYTE 2 DUP(0)                        ; 단일 문자 출력용 버퍼
setBuf      BYTE 6 DUP(0)                        ; 4글자 집합 + CRLF 출력용 버퍼
newlineStr  BYTE 13, 10, 0                       ; 줄바꿈
msgMatrix   BYTE "[ Generated 4x4 Matrix ]", 13, 10, 0
msgResult   BYTE 13, 10, "[ Sets with Exactly 2 Vowels ]", 13, 10, 0

.code

; ---------------------------------------------------------------
; 널 종료 문자열의 길이를 자동 계산하여 콘솔에 안전하게 출력하는 프로시저
; ---------------------------------------------------------------
PrintString PROC USES eax ecx edi, pStr:PTR BYTE
    mov edi, pStr
    mov ecx, 0

L_len:
    cmp BYTE PTR [edi], 0
    je L_print
    inc edi
    inc ecx
    jmp L_len

L_print:
    cmp ecx, 0
    je L_exit
    INVOKE WriteConsoleA, outHandle, pStr, ecx, OFFSET bytesWritten, 0

L_exit:
    ret
PrintString ENDP

; ---------------------------------------------------------------
; LCG 기반 난수 생성 프로시저
; ---------------------------------------------------------------
RandomRange PROC USES ebx edx, nRange:DWORD
    mov eax, seed
    imul eax, eax, 1103515245
    add eax, 12345
    mov seed, eax

    shr eax, 16
    and eax, 07FFFh

    mov ebx, nRange
    mov edx, 0
    div ebx
    mov eax, edx
    ret
RandomRange ENDP

; ---------------------------------------------------------------
; GetRandomLetter 프로시저 (50% 확률로 모음/자음 선택)
; ---------------------------------------------------------------
GetRandomLetter PROC USES ebx
    INVOKE RandomRange, 2
    cmp eax, 0
    je L_vowel

L_consonant:
    INVOKE RandomRange, 21
    mov al, consonants[eax]
    ret

L_vowel:
    INVOKE RandomRange, 5
    mov al, vowels[eax]
    ret
GetRandomLetter ENDP

; ---------------------------------------------------------------
; IsVowel 프로시저 (모음이면 EAX=1, 아니면 EAX=0)
; ---------------------------------------------------------------
IsVowel PROC USES edi ecx, charVal:BYTE
    mov al, charVal
    mov edi, OFFSET vowels
    mov ecx, 5

L_chk:
    cmp al, [edi]
    je L_is_vowel
    inc edi
    loop L_chk

    mov eax, 0
    ret

L_is_vowel:
    mov eax, 1
    ret
IsVowel ENDP

; ---------------------------------------------------------------
; CheckAndPrintSet 프로시저 (모음이 정확히 2개일 때만 출력)
; ---------------------------------------------------------------
CheckAndPrintSet PROC USES eax ebx ecx, c0:BYTE, c1:BYTE, c2:BYTE, c3:BYTE
    LOCAL vowelCount:DWORD
    mov vowelCount, 0

    INVOKE IsVowel, c0
    add vowelCount, eax

    INVOKE IsVowel, c1
    add vowelCount, eax

    INVOKE IsVowel, c2
    add vowelCount, eax

    INVOKE IsVowel, c3
    add vowelCount, eax

    cmp vowelCount, 2
    jne L_skip_print

    ; 모음 2개 조건 만족 시 4글자 집합 출력
    mov al, c0
    mov setBuf[0], al
    mov al, c1
    mov setBuf[1], al
    mov al, c2
    mov setBuf[2], al
    mov al, c3
    mov setBuf[3], al
    mov setBuf[4], 13              ; CR
    mov setBuf[5], 10              ; LF

    INVOKE WriteConsoleA, outHandle, OFFSET setBuf, 6, OFFSET bytesWritten, 0

L_skip_print:
    ret
CheckAndPrintSet ENDP

; ---------------------------------------------------------------
; GenerateMatrix 프로시저 (행렬 생성 및 출력)
; ---------------------------------------------------------------
GenerateMatrix PROC USES eax ecx edx esi
    mov esi, 0
    mov edx, 4                     ; 4 행

L_row:
    push edx
    mov ecx, 4                     ; 4 열

L_col:
    push ecx
    call GetRandomLetter
    mov matrix[esi], al

    mov charBuffer[0], al
    mov charBuffer[1], ' '
    INVOKE WriteConsoleA, outHandle, OFFSET charBuffer, 2, OFFSET bytesWritten, 0

    inc esi
    pop ecx
    loop L_col

    INVOKE WriteConsoleA, outHandle, OFFSET newlineStr, 2, OFFSET bytesWritten, 0
    pop edx
    dec edx
    cmp edx, 0
    jg L_row

    ret
GenerateMatrix ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 콘솔 핸들 가져오기
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; 1. 타이틀 및 행렬 생성/출력
    INVOKE PrintString, ADDR msgMatrix
    INVOKE GenerateMatrix

    ; 2. 탐색 결과 타이틀 출력
    INVOKE PrintString, ADDR msgResult

    ; 3. 10개 세트 검사 (가로 4개, 세로 4개, 대각선 2개)
    INVOKE CheckAndPrintSet, matrix[0],  matrix[1],  matrix[2],  matrix[3]   ; Row 0
    INVOKE CheckAndPrintSet, matrix[4],  matrix[5],  matrix[6],  matrix[7]   ; Row 1
    INVOKE CheckAndPrintSet, matrix[8],  matrix[9],  matrix[10], matrix[11]  ; Row 2
    INVOKE CheckAndPrintSet, matrix[12], matrix[13], matrix[14], matrix[15]  ; Row 3

    INVOKE CheckAndPrintSet, matrix[0],  matrix[4],  matrix[8],  matrix[12]  ; Col 0
    INVOKE CheckAndPrintSet, matrix[1],  matrix[5],  matrix[9],  matrix[13]  ; Col 1
    INVOKE CheckAndPrintSet, matrix[2],  matrix[6],  matrix[10], matrix[14]  ; Col 2
    INVOKE CheckAndPrintSet, matrix[3],  matrix[7],  matrix[11], matrix[15]  ; Col 3

    INVOKE CheckAndPrintSet, matrix[0],  matrix[5],  matrix[10], matrix[15]  ; Diag 1
    INVOKE CheckAndPrintSet, matrix[3],  matrix[6],  matrix[9],  matrix[12]  ; Diag 2

    ; 4. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main