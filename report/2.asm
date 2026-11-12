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

; Str_concat 프로시저 프로토타입 선언 (INVOKE 사용을 위함)
Str_concat PROTO, ptrTarget:PTR BYTE, ptrSource:PTR BYTE

.data
targetStr BYTE "ABCDE", 10 DUP(0)      ; 대상 문자열 (뒤에 여유 공간 있음)
sourceStr BYTE "FGH", 0                ; 원본 문자열
bytesWritten DWORD ?

.code
; ---------------------------------------------------------------
; Str_concat 프로시저
; targetStr 문자열의 끝(Null 문자 위치)에 sourceStr을 이어 붙입니다.
;
; 매개변수:
;   ptrTarget: 대상 문자열의 주소 (포인터)
;   ptrSource: 원본 문자열의 주소 (포인터)
; ---------------------------------------------------------------
Str_concat PROC USES eax edi esi, ptrTarget:PTR BYTE, ptrSource:PTR BYTE

    mov edi, ptrTarget             ; EDI = targetStr 시작 주소

    ; 1. targetStr의 끝(Null 문자 '\0') 위치 찾기
L_find_end:
    cmp BYTE PTR [edi], 0          ; 현재 위치가 Null 문자인지 확인
    je L_found_end                 ; Null 문자면 이어서 쓰기 단계로 이동
    inc edi                        ; 다음 문자로 이동
    jmp L_find_end

L_found_end:
    mov esi, ptrSource             ; ESI = sourceStr 시작 주소

    ; 2. sourceStr의 내용을 targetStr의 Null 위치부터 복사
L_copy:
    mov al, [esi]                  ; source에서 1바이트 읽기
    mov [edi], al                  ; target 끝 위치에 1바이트 쓰기
    
    cmp al, 0                      ; 복사한 문자가 Null 인지 확인
    je L_done                      ; Null 문자까지 복사했으면 완료

    inc esi                        ; source 포인터 증가
    inc edi                        ; target 포인터 증가
    jmp L_copy

L_done:
    ret                            ; 종료 (USES 구문으로 EAX, EDI, ESI 자동 복원)
Str_concat ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 1. 문제 요구사항대로 INVOKE를 사용해 프로시저 호출
    INVOKE Str_concat, ADDR targetStr, ADDR sourceStr

    ; 2. 결과 확인 (ABCDE + FGH = 총 8글자 출력)
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, OFFSET targetStr, 8, OFFSET bytesWritten, 0

    ; 3. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main