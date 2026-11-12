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

.data
vowels      BYTE "AEIOU", 0                       ; 5개 모음
consonants  BYTE "BCDFGHJKLMNPQRSTVWXYZ", 0       ; 21개 자음

seed        DWORD 123456789                      ; 난수 생성용 시드(Seed) 값
outHandle   DWORD ?
bytesWritten DWORD ?

charBuffer  BYTE 2 DUP(0)                        ; 문자 + 공백 출력용
newlineStr  BYTE 13, 10, 0                       ; 줄바꿈 문지
sepMatrix   BYTE 13, 10, 0                       ; 행렬 간 간격 줄바꿈

.code

; ---------------------------------------------------------------
; LCG 기반 난수 생성 프로시저
; 0 이상 nRange 미만의 난수를 EAX에 반환합니다.
; ---------------------------------------------------------------
RandomRange PROC USES ebx edx, nRange:DWORD
    ; seed = seed * 1103515245 + 12345
    mov eax, seed
    imul eax, eax, 1103515245
    add eax, 12345
    mov seed, eax

    ; EAX = (seed >> 16) & 0x7FFF (0 ~ 32767 양수 난수)
    shr eax, 16
    and eax, 07FFFh

    ; EAX % nRange 계산
    mov ebx, nRange
    mov edx, 0
    div ebx                        ; EDX = 나머지 (0 ~ nRange-1)
    mov eax, edx                   ; 나머지를 EAX에 반환
    ret
RandomRange ENDP

; ---------------------------------------------------------------
; GetRandomLetter 프로시저
; 50% 확률로 모음, 50% 확률로 자음을 선택하여 AL에 반환합니다.
; ---------------------------------------------------------------
GetRandomLetter PROC USES ebx
    ; 0 또는 1을 선택 (50% 확률)
    INVOKE RandomRange, 2
    cmp eax, 0
    je L_vowel

L_consonant:
    ; 50% 확률: 자음 선택 (21개 중 하나)
    INVOKE RandomRange, 21
    mov al, consonants[eax]
    ret

L_vowel:
    ; 50% 확률: 모음 선택 (5개 중 하나)
    INVOKE RandomRange, 5
    mov al, vowels[eax]
    ret
GetRandomLetter ENDP

; ---------------------------------------------------------------
; GenerateMatrix 프로시저
; 4x4 문자 행렬을 생성하고 콘솔에 출력합니다.
; ---------------------------------------------------------------
GenerateMatrix PROC USES ecx edx
    mov edx, 4                     ; 4개 행(Row) 루프

L_row_loop:
    push edx                       ; 행 카운터 보존
    mov ecx, 4                     ; 4개 열(Column) 루프

L_col_loop:
    push ecx                       ; 열 카운터 보존

    ; 1. 랜덤 문자 가져오기
    call GetRandomLetter           ; AL = 랜덤 대문자

    ; 2. 문자와 공백을 버퍼에 세팅하여 출력
    mov charBuffer[0], al
    mov charBuffer[1], ' '
    INVOKE WriteConsoleA, outHandle, OFFSET charBuffer, 2, OFFSET bytesWritten, 0

    pop ecx                        ; 열 카운터 복원
    loop L_col_loop

    ; 3. 한 행이 끝나면 줄바꿈
    INVOKE WriteConsoleA, outHandle, OFFSET newlineStr, 2, OFFSET bytesWritten, 0

    pop edx                        ; 행 카운터 복원
    dec edx
    cmp edx, 0
    jg L_row_loop

    ret
GenerateMatrix ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 콘솔 출력 핸들 취득
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; 행렬 5회 생성 및 출력
    mov ecx, 5

L_main_loop:
    push ecx
    
    INVOKE GenerateMatrix
    ; 행렬과 행렬 사이 빈 줄 추가
    INVOKE WriteConsoleA, outHandle, OFFSET sepMatrix, 2, OFFSET bytesWritten, 0

    pop ecx
    loop L_main_loop

    ; 프로그램 정상 종료
    INVOKE ExitProcess, 0
main ENDP

END main