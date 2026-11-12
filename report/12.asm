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
ReadConsoleA PROTO, 
    hConsoleInput:DWORD, 
    lpBuffer:PTR BYTE, 
    nNumberOfCharsToRead:DWORD, 
    lpNumberOfCharsRead:PTR DWORD, 
    pInputControl:PTR DWORD

.data
; 테스트용 3x3 2차원 배열들 (3행 3열)
byteArr     BYTE  10, 20, 30,   40, 50, 60,   70, 80, 90
wordArr     WORD  100, 200, 300, 400, 500, 600, 700, 800, 900
dwordArr    DWORD 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000

ROW_ELEMENTS DWORD 3                ; 각 행당 요소 개수 (3개)

inHandle    DWORD ?
outHandle   DWORD ?
bytesWritten DWORD ?
bytesRead   DWORD ?

inputBuf    BYTE 10 DUP(0)
msgPrompt   BYTE "Enter row index (0-2): ", 0
msgByte     BYTE "BYTE Array Row Sum : ", 0
msgWord     BYTE "WORD Array Row Sum : ", 0
msgDword    BYTE "DWORD Array Row Sum: ", 0
newlineStr  BYTE 13, 10, 0

.code

; ---------------------------------------------------------------
; 1. calc_row_sum 프로시저 (명시적 스택 파라미터 사용)
; 
; 파라미터 (스택 전달):
;   [EBP + 20] = row index (행 인덱스)
;   [EBP + 16] = array type (1, 2, 4 바이트)
;   [EBP + 12] = row size (한 행의 요소 개수)
;   [EBP + 8]  = array offset (배열 시작 주소)
; 반환 값:
;   EAX = 해당 행 원소들의 합계
; ---------------------------------------------------------------
calc_row_sum PROC
    push ebp                       ; 1. 스택 프레임 생성
    mov ebp, esp

    push ebx                       ; 레지스터 보존
    push ecx
    push edx
    push esi

    ; 2. 스택으로부터 파라미터 읽기
    mov esi, [ebp + 8]             ; ESI = array offset
    mov ecx, [ebp + 12]            ; ECX = row size (요소 개수)
    mov ebx, [ebp + 16]            ; EBX = array type (1, 2, 4)
    mov edx, [ebp + 20]            ; EDX = row index

    ; 3. 행의 시작 오프셋 계산: (row_index * row_size * array_type)
    mov eax, edx                   ; EAX = row index
    imul eax, ecx                  ; EAX = row index * row_size
    imul eax, ebx                  ; EAX = row index * row_size * array_type
    add esi, eax                   ; ESI = 계산된 행의 시작 메모리 주소

    mov eax, 0                     ; 합계를 누적할 EAX 0으로 초기화

    ; 4. 배열 타입(BYTE, WORD, DWORD)별 덧셈 루프
L_sum_loop:
    cmp ebx, 1                     ; TYPE == BYTE (1바이트)
    je L_byte
    cmp ebx, 2                     ; TYPE == WORD (2바이트)
    je L_word

    ; DWORD 처리 (4바이트)
    add eax, [esi]
    add esi, 4
    jmp L_next

L_byte:
    movzx edx, BYTE PTR [esi]      ; 1바이트 읽어 32비트 확장
    add eax, edx
    add esi, 1
    jmp L_next

L_word:
    movzx edx, WORD PTR [esi]      ; 2바이트 읽어 32비트 확장
    add eax, edx
    add esi, 2

L_next:
    loop L_sum_loop                ; ECX(row size)만큼 반복

    ; 5. 레지스터 복원 및 스택 정리 후 반환
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret 16                         ; 전달받은 4개의 DWORD 파라미터(16바이트) 정리
calc_row_sum ENDP

; ---------------------------------------------------------------
; 숫자를 십진수로 콘솔에 출력하는 보조 프로시저
; ---------------------------------------------------------------
PrintNumber PROC USES eax ebx ecx edx edi, nVal:DWORD
    LOCAL buf[12]:BYTE

    mov eax, nVal
    lea edi, [buf + 11]
    mov BYTE PTR [edi], 0

    mov ebx, 10
    mov ecx, 0

L_convert:
    mov edx, 0
    div ebx                        ; EAX / 10
    add dl, '0'                    ; ASCII 문자로 변환
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne L_convert

    INVOKE WriteConsoleA, outHandle, edi, ecx, OFFSET bytesWritten, 0
    ret
PrintNumber ENDP

; ---------------------------------------------------------------
; 널 종료 문자열 출력 보조 프로시저
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
    INVOKE WriteConsoleA, outHandle, pStr, ecx, OFFSET bytesWritten, 0
    ret
PrintString ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 표준 입력/출력 핸들 취득
    INVOKE GetStdHandle, -10
    mov inHandle, eax
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; 1. 사용자에게 행 인덱스 입력을 요청
    INVOKE PrintString, ADDR msgPrompt
    INVOKE ReadConsoleA, inHandle, ADDR inputBuf, 10, ADDR bytesRead, 0

    ; 2. 입력된 ASCII 문자를 정수 인덱스(0, 1, 2)로 변환
    movzx eax, inputBuf[0]
    sub eax, '0'                   ; '0'~'2' -> 0~2 정수 변환
    push eax                       ; [EBP+20] 에 들어갈 row index 보관용 (EAX)

    INVOKE PrintString, ADDR newlineStr

    ; -----------------------------------------------------------
    ; [테스트 1] BYTE 배열 테스트
    ; -----------------------------------------------------------
    pop eax                        ; 행 인덱스 가져오기
    push eax                       ; 파라미터 4: row index
    push 1                         ; 파라미터 3: array type (TYPE BYTE = 1)
    push ROW_ELEMENTS              ; 파라미터 2: row size (3개)
    push OFFSET byteArr            ; 파라미터 1: array offset
    call calc_row_sum              ; 결과가 EAX에 반환됨

    push eax                       ; 합계 결과 보존
    INVOKE PrintString, ADDR msgByte
    pop eax
    INVOKE PrintNumber, eax
    INVOKE PrintString, ADDR newlineStr

    ; -----------------------------------------------------------
    ; [테스트 2] WORD 배열 테스트
    ; -----------------------------------------------------------
    movzx eax, inputBuf[0]
    sub eax, '0'

    push eax                       ; 파라미터 4: row index
    push 2                         ; 파라미터 3: array type (TYPE WORD = 2)
    push ROW_ELEMENTS              ; 파라미터 2: row size (3개)
    push OFFSET wordArr            ; 파라미터 1: array offset
    call calc_row_sum              ; 결과가 EAX에 반환됨

    push eax                       ; 합계 결과 보존
    INVOKE PrintString, ADDR msgWord
    pop eax
    INVOKE PrintNumber, eax
    INVOKE PrintString, ADDR newlineStr

    ; -----------------------------------------------------------
    ; [테스트 3] DWORD 배열 테스트
    ; -----------------------------------------------------------
    movzx eax, inputBuf[0]
    sub eax, '0'

    push eax                       ; 파라미터 4: row index
    push 4                         ; 파라미터 3: array type (TYPE DWORD = 4)
    push ROW_ELEMENTS              ; 파라미터 2: row size (3개)
    push OFFSET dwordArr           ; 파라미터 1: array offset
    call calc_row_sum              ; 결과가 EAX에 반환됨

    push eax                       ; 합계 결과 보존
    INVOKE PrintString, ADDR msgDword
    pop eax
    INVOKE PrintNumber, eax
    INVOKE PrintString, ADDR newlineStr

    ; 3. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main