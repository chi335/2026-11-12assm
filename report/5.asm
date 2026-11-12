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

; Str_nextWord 프로토타입 선언
Str_nextWord PROTO, pString:PTR BYTE, delimiter:BYTE

.data
target      BYTE "Johnson,Calvin", 0
nextWordPtr DWORD ?
msgNotFound BYTE "Delimiter not found!", 0
bytesWritten DWORD ?

.code
; ---------------------------------------------------------------
; Str_nextWord 프로시저
; 문자열에서 구분자(delimiter)를 찾아 Null 바이트(0)로 변경하고,
; 구분자 바로 다음 문자의 주소를 EAX에 반환합니다.
;
; 매개변수:
;   pString   : 검색할 문자열의 주소 (포인터)
;   delimiter : 찾아 바꿀 구분자 문자 (예: ',')
; 반환 값:
;   구분자 발견 시 : ZF = 1 (Zero Flag), EAX = 구분자 다음 문자의 주소
;   구분자 미발견 : ZF = 0 (Zero Flag), EAX = 정의되지 않음 (0)
; ---------------------------------------------------------------
Str_nextWord PROC USES ecx esi, pString:PTR BYTE, delimiter:BYTE

    mov esi, pString               ; ESI = target 문자열의 시작 주소
    mov cl, delimiter              ; CL = 찾고자 하는 구분자 문자

L_loop:
    mov al, [esi]                  ; ESI 위치에서 1바이트 읽기
    
    cmp al, 0                      ; 문자열의 끝(Null)인지 확인
    je L_not_found                 ; 끝까지 구분자를 찾지 못한 경우

    cmp al, cl                     ; 현재 문자가 구분자(,)와 일치하는가?
    je L_found                     ; 찾았으면 L_found로 이동

    inc esi                        ; 다음 문자로 포인터 이동
    jmp L_loop

L_found:
    mov BYTE PTR [esi], 0          ; 1. 구분자를 Null 문자(0)로 교체
    inc esi                        ; 2. ESI를 구분자 '다음' 문자의 위치로 이동
    mov eax, esi                   ; 3. EAX에 구분자 다음 위치의 주소 저장
    cmp eax, eax                   ; 4. ZF = 1 (Zero Flag 설정)
    ret

L_not_found:
    mov eax, 0                     ; EAX 정의되지 않음
    mov ecx, 1
    cmp ecx, 0                     ; 1 != 0 이므로 ZF = 0 (Zero Flag 해제)
    ret
Str_nextWord ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 1. 문제 요구사항 코드 실행
    INVOKE Str_nextWord, ADDR target, ','
    jnz notFound                   ; Zero Flag가 0(Clear)이면 notFound로 이동

    mov nextWordPtr, eax           ; EAX에 반환된 "Calvin"의 시작 주소를 보관

    ; 2. 첫 번째 단어 출력 ("Johnson" -> 7글자)
    ; (쉼표가 0으로 바뀌어서 target은 "Johnson" 문자열이 됨)
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, OFFSET target, 7, OFFSET bytesWritten, 0

    ; 3. 두 번째 단어 출력 ("Calvin" -> 6글자)
    ; (Str_nextWord 호출 결과로 EAX가 가리키고 있던 주소 사용)
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, nextWordPtr, 6, OFFSET bytesWritten, 0
    jmp L_exit

notFound:
    ; 구분자를 찾지 못했을 때 출력
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, OFFSET msgNotFound, 20, OFFSET bytesWritten, 0

L_exit:
    INVOKE ExitProcess, 0
main ENDP

END main