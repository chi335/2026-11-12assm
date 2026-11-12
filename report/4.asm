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

; Str_find 프로시저 프로토타입 선언
Str_find PROTO, ptrSource:PTR BYTE, ptrTarget:PTR BYTE

.data
target      BYTE "123ABC342432", 0
source      BYTE "ABC", 0
pos         DWORD ?
msgNotFound BYTE "Not Found!", 0
bytesWritten DWORD ?

.code
; ---------------------------------------------------------------
; Str_find 프로시저
; target 문자열 내부에서 source 문자열의 첫 번째 위치를 탐색합니다.
;
; 매개변수:
;   ptrSource : 찾고자 하는 부분 문자열의 주소
;   ptrTarget : 전체 대상 문자열의 주소
; 반환 값:
;   찾았을 때 : Zero Flag = 1 (ZF=1), EAX = 찾은 문자열의 시작 주소
;   못 찾았을 때: Zero Flag = 0 (ZF=0), EAX = 0
; ---------------------------------------------------------------
Str_find PROC USES ebx ecx edx edi esi, ptrSource:PTR BYTE, ptrTarget:PTR BYTE

    mov edi, ptrTarget             ; EDI = target 탐색 시작 위치

L_outer:
    cmp BYTE PTR [edi], 0          ; target의 끝(Null)에 도달했는지 확인
    je L_not_found                 ; 끝까지 찾지 못함

    ; 문자열 비교를 위한 준비
    mov esi, ptrSource             ; ESI = source 문자열 시작 주소
    mov edx, edi                   ; EDX = 현재 비교할 target의 위치

L_inner:
    mov al, [esi]                  ; source의 1바이트 읽기
    cmp al, 0                      ; source의 끝(Null)까지 모두 일치했는가?
    je L_found                     ; 모두 맞으면 찾음(Match)

    mov bl, [edx]                  ; target의 1바이트 읽기
    cmp bl, 0                      ; source가 끝나기 전에 target이 먼저 끝났는가?
    je L_not_found

    cmp al, bl                     ; 두 문자가 같은지 비교
    jne L_mismatch                 ; 다르면 다음 위치로 이동

    inc esi                        ; source 다음 문자로
    inc edx                        ; target 다음 문자로
    jmp L_inner

L_mismatch:
    inc edi                        ; target의 시작 위치를 한 칸 뒤로 이동
    jmp L_outer

L_found:
    mov eax, edi                   ; EAX = 매칭된 위치의 주소 저장
    cmp eax, eax                   ; ZF = 1 (Zero Flag 설정)
    ret

L_not_found:
    mov eax, 0                     ; EAX 정의되지 않음 (0 설정)
    mov ecx, 1
    cmp ecx, 0                     ; 1 != 0 이므로 ZF = 0 (Zero Flag 해제)
    ret
Str_find ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 1. 문제 요구사항 코드 실행
    INVOKE Str_find, ADDR source, ADDR target
    jnz notFound                   ; Zero Flag가 0(Clear)이면 notFound로 이동

    mov pos, eax                   ; 찾은 주소를 pos에 저장

    ; 2. 결과 출력 (pos가 가리키는 위치인 "ABC342432"부터 출력)
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, pos, 9, OFFSET bytesWritten, 0
    jmp L_exit

notFound:
    ; 못 찾았을 때 메시지 출력
    INVOKE GetStdHandle, -11
    INVOKE WriteConsoleA, eax, OFFSET msgNotFound, 10, OFFSET bytesWritten, 0

L_exit:
    INVOKE ExitProcess, 0
main ENDP

END main