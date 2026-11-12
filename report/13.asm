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

; Str_trimLeading 프로토타입 선언
Str_trimLeading PROTO, pString:PTR BYTE, trimChar:BYTE

.data
targetStr   BYTE "###ABC", 0                     ; 테스트용 문자열
targetStr2  BYTE "   Assembly Language", 0        ; 공백 제거 테스트용 문자열

outHandle   DWORD ?
bytesWritten DWORD ?
newlineStr  BYTE 13, 10, 0
msg1        BYTE "Result 1: ", 0
msg2        BYTE "Result 2: ", 0

.code

; ---------------------------------------------------------------
; Str_trimLeading 프로시저
; 문자열 시작 부분에 연속되어 있는 trimChar 문자를 모두 제거합니다.
;
; 매개변수:
;   pString  : 대상 문자열 포인터
;   trimChar : 제거할 선두 문자 (예: '#', ' ')
; ---------------------------------------------------------------
Str_trimLeading PROC USES eax ebx edi esi, pString:PTR BYTE, trimChar:BYTE

    mov esi, pString               ; ESI = 탐색 시작 위치
    mov al, trimChar               ; AL = 제거할 대상 문자

    ; 1. trimChar가 아닌 첫 번째 문자의 위치 탐색
L_find_non_trim:
    mov bl, [esi]                  ; 현재 위치의 1바이트 읽기
    cmp bl, 0                      ; 문자열의 끝(Null)인지 확인
    je L_do_copy                   ; 끝까지 trimChar만 있는 경우 복사 단계로 이동

    cmp bl, al                     ; 제거할 문자(trimChar)와 비교
    jne L_do_copy                  ; 다른 문자를 찾았으면 복사 단계로 이동

    inc esi                        ; trimChar와 같으면 다음 문자로 이동
    jmp L_find_non_trim

    ; 2. ESI 위치의 남은 문자열을 EDI(문자열 시작 주소) 위치로 당겨옴
L_do_copy:
    mov edi, pString               ; EDI = 문자열 시작 주소

L_copy_loop:
    mov bl, [esi]                  ; ESI 위치에서 1바이트 읽기
    mov [edi], bl                  ; EDI 위치에 덮어쓰기
    
    cmp bl, 0                      ; Null 문자까지 복사되었는지 확인
    je L_done                      ; Null 문자 복사 완료 시 종료

    inc esi
    inc edi
    jmp L_copy_loop

L_done:
    ret                            ; 종료 (USES 구문으로 레지스터 자동 복원)
Str_trimLeading ENDP

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
    ; 콘솔 핸들 취득
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; -----------------------------------------------------------
    ; [테스트 1] "###ABC" 에서 '#' 제거 -> "ABC"
    ; -----------------------------------------------------------
    INVOKE Str_trimLeading, ADDR targetStr, '#'

    INVOKE PrintString, ADDR msg1
    INVOKE PrintString, ADDR targetStr
    INVOKE PrintString, ADDR newlineStr

    ; -----------------------------------------------------------
    ; [테스트 2] "   Assembly Language" 에서 공백 ' ' 제거 -> "Assembly Language"
    ; -----------------------------------------------------------
    INVOKE Str_trimLeading, ADDR targetStr2, ' '

    INVOKE PrintString, ADDR msg2
    INVOKE PrintString, ADDR targetStr2
    INVOKE PrintString, ADDR newlineStr

    ; 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main