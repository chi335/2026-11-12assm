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

; Str_remove 프로시저 프로토타입 선언
Str_remove PROTO, pStart:PTR BYTE, nChars:DWORD

.data
target BYTE "abcxxxxdefghijklmop", 0     ; "xxxx" 삭제 후 "abcdefghijklmop"가 됨 (15글자)
bytesWritten DWORD ?

.code
; ---------------------------------------------------------------
; Str_remove 프로시저
; 지정된 위치부터 N개의 문자를 삭제(앞으로 당김)합니다.
;
; 매개변수:
;   pStart : 삭제를 시작할 문자열 내의 주소 (포인터)
;   nChars : 삭제할 문자의 개수 (N)
; ---------------------------------------------------------------
Str_remove PROC USES eax ecx edi esi, pStart:PTR BYTE, nChars:DWORD

    mov edi, pStart                ; EDI = 삭제를 시작할 목적지 주소
    mov esi, pStart                ; ESI = 건너뛴 후 당겨올 원본 주소 (초기값: pStart)
    mov ecx, nChars                ; ECX = 건너뛸 글자 수 (N)

    cmp ecx, 0                      ; 삭제할 개수가 0이면 아무것도 하지 않음
    je L_done

    ; 1. ESI 포인터를 N만큼 뒤로 이동 (삭제할 부분을 건너뜀)
L_skip:
    cmp BYTE PTR [esi], 0          ; 이동 중에 Null 문자를 만났는지 확인
    je L_truncate                  ; 문자열 길이보다 더 많이 삭제하려 하면 pStart 위치에서 종료
    inc esi
    loop L_skip
    jmp L_copy

L_truncate:
    mov BYTE PTR [edi], 0          ; 삭제 시작 위치에 Null 문자를 삽입하여 종료
    jmp L_done

    ; 2. ESI 위치의 문자들을 EDI 위치로 당겨와서 덮어씀 (Null 문자 포함)
L_copy:
    mov al, [esi]                  ; 원본 문자를 가져옴
    mov [edi], al                  ; 목적지에 덮어씀
    
    cmp al, 0                      ; Null 문자(문자열 끝)까지 복사했는지 확인
    je L_done                      ; Null 문자를 복사했으면 삭제 완료

    inc esi                        ; 원본 포인터 이동
    inc edi                        ; 목적지 포인터 이동
    jmp L_copy

L_done:
    ret                            ; 종료 (USES 구문으로 EAX, ECX, EDI, ESI 자동 복원)
Str_remove ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 1. 문제 요구사항대로 INVOKE 호출
    ; target+3 위치 (첫번째 'x' 위치)부터 4개 문자를 삭제
    INVOKE Str_remove, ADDR [target+3], 4

    ; 2. 콘솔에 결과 출력 ("abcdefghijklmop" -> 총 15글자)
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, OFFSET target, 15, OFFSET bytesWritten, 0

    ; 3. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main