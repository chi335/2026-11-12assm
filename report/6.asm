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

; Get_frequencies 프로토타입 선언
Get_frequencies PROTO, pString:PTR BYTE, pTable:PTR DWORD

.data
target      BYTE "AAEBDCFBBC", 0            ; 입력 문자열
freqTable   DWORD 256 DUP(0)                ; 256개의 DWORD 배열 (0으로 초기화)

; 검증 출력을 위한 안내 문자열 및 핸들 변수
msgA        BYTE "Count of 'A': ", 0
msgB        BYTE "Count of 'B': ", 0
countChar   BYTE 2 DUP(0), 10               ; 숫자 저장용 버퍼 및 줄바꿈
outHandle   DWORD ?                         ; 콘솔 출력 핸들 저장 변수
bytesWritten DWORD ?

.code
; ---------------------------------------------------------------
; Get_frequencies 프로시저
; 문자열을 읽어 각 문자의 ASCII 코드를 인덱스로 삼아 freqTable의 빈도수를 증가시킵니다.
;
; 매개변수:
;   pString : 입력 문자열의 주소 (포인터)
;   pTable  : 256개의 DWORD로 구성된 빈도수 배열의 주소 (포인터)
; ---------------------------------------------------------------
Get_frequencies PROC USES eax edi esi, pString:PTR BYTE, pTable:PTR DWORD

    mov esi, pString               ; ESI = target 문자열의 시작 주소
    mov edi, pTable                ; EDI = freqTable 배열의 시작 주소

L_loop:
    movzx eax, BYTE PTR [esi]      ; 원본 문자열에서 1바이트 읽어 오고 EAX에 Zero-extension
    
    cmp al, 0                      ; 문자열의 끝(Null 문자)인지 확인
    je L_done                      ; 널 문자를 만났으면 종료

    ; EAX(ASCII 코드 값) * 4 위치의 DWORD 값을 1 증가
    inc DWORD PTR [edi + eax * 4]

    inc esi                        ; 다음 문자로 이동
    jmp L_loop

L_done:
    ret                            ; 종료 (EAX, EDI, ESI 자동으로 이전 값 복원)
Get_frequencies ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 1. 문제 요구사항 코드 실행
    INVOKE Get_frequencies, ADDR target, ADDR freqTable

    ; 콘솔 출력 핸들 미리 가져와서 변수에 저장
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; 2. 결과 검증 ( 'A'의 개수 출력 )
    mov eax, freqTable['A' * 4]     ; freqTable['A'] 값 가져오기 (2)
    add al, '0'                     ; 정수를 ASCII 문자로 변환 ('2')
    mov countChar[0], al
    
    INVOKE WriteConsoleA, outHandle, OFFSET msgA, 14, OFFSET bytesWritten, 0
    INVOKE WriteConsoleA, outHandle, OFFSET countChar, 2, OFFSET bytesWritten, 0

    ; 3. 결과 검증 ( 'B'의 개수 출력 )
    mov eax, freqTable['B' * 4]     ; freqTable['B'] 값 가져오기 (3)
    add al, '0'                     ; 정수를 ASCII 문자로 변환 ('3')
    mov countChar[0], al

    INVOKE WriteConsoleA, outHandle, OFFSET msgB, 14, OFFSET bytesWritten, 0
    INVOKE WriteConsoleA, outHandle, OFFSET countChar, 2, OFFSET bytesWritten, 0

    ; 4. 프로그램 정상 종료
    INVOKE ExitProcess, 0
main ENDP

END main