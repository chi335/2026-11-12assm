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

.data
sourceStr   BYTE "Hello, Assembly World!", 0   ; 원본 문자열
targetStr   BYTE 50 DUP(0)                    ; 대상 버퍼 (0으로 초기화)
maxChars    DWORD 5                           ; 복사할 최대 개수 N (5개)
bytesWritten DWORD ?

.code
; ---------------------------------------------------------------
; Str_copyN 프로시저
; 입력:
;   ESI = 원본 문자열 주소
;   EDI = 대상 문자열 주소
;   ECX = 복사할 최대 문자 수 (N)
; ---------------------------------------------------------------
Str_copyN PROC
    push eax
    push ecx
    push esi
    push edi

    cmp ecx, 0                      ; N이 0이면 복사하지 않음
    je L_done

L_loop:
    mov al, [esi]                   ; 원본에서 1바이트 읽기
    mov [edi], al                   ; 대상에 1바이트 쓰기
    
    cmp al, 0                       ; 원본 끝(널 문자) 확인
    je L_end_early                  ; 널 문자를 만나면 루프 종료

    inc esi                         ; 원본 포인터 이동
    inc edi                         ; 대상 포인터 이동
    loop L_loop                     ; ECX 값만큼 반복

    ; N개를 모두 복사한 경우 마지막에 Null 문자 삽입
    mov BYTE PTR [edi], 0
    jmp L_done

L_end_early:
    ; 이미 널 문자가 복사되었으므로 처리 없음

L_done:
    pop edi
    pop esi
    pop ecx
    pop eax
    ret
Str_copyN ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 1. 파라미터 전달 (ESI, EDI, ECX)
    mov esi, OFFSET sourceStr
    mov edi, OFFSET targetStr
    mov ecx, maxChars               ; maxChars = 5 ("Hello"만 복사됨)

    ; 2. Str_copyN 프로시저 호출
    call Str_copyN

    ; 3. 콘솔 화면에 결과 출력 (윈도우 API 직접 사용)
    ; STD_OUTPUT_HANDLE (-11) 핸들 가져오기
    INVOKE GetStdHandle, -11
    
    ; 화면에 복사된 결과(targetStr) 출력
    INVOKE WriteConsoleA, eax, OFFSET targetStr, maxChars, OFFSET bytesWritten, 0

    ; 4. 프로그램 정상 종료
    INVOKE ExitProcess, 0
main ENDP

END main