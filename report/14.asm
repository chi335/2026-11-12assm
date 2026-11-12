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

; Str_trimSet 프로토타입 선언
Str_trimSet PROTO, pString:PTR BYTE, pFilterSet:PTR BYTE

.data
targetStr   BYTE "ABC#$&", 0                     ; 테스트용 대상 문자열
filterSet   BYTE "%#!;$&*", 0                    ; 필터 문자 집합

outHandle   DWORD ?
bytesWritten DWORD ?
newlineStr  BYTE 13, 10, 0
msgResult   BYTE "Trimmed Result: ", 0

.code

; ---------------------------------------------------------------
; Str_trimSet 프로시저
; 문자열의 끝에서부터 pFilterSet에 포함된 모든 문자를 제거합니다.
;
; 매개변수:
;   pString    : 대상 문자열 포인터
;   pFilterSet : 제거 대상 필터 문자 목록 (포인터)
; ---------------------------------------------------------------
Str_trimSet PROC USES eax ebx edi esi, pString:PTR BYTE, pFilterSet:PTR BYTE

    ; 1. targetStr의 끝(Null 문자 위치) 찾기
    mov esi, pString
L_find_end:
    cmp BYTE PTR [esi], 0
    je L_at_end
    inc esi
    jmp L_find_end

L_at_end:
    ; ESI가 Null 문자를 가리키고 있으므로 한 칸 앞으로 이동
    cmp esi, pString               ; 빈 문자열인 경우 바로 종료
    je L_done
    dec esi                        ; ESI = 문자열의 맨 마지막 글자 위치

    ; 2. 역순으로 1글자씩 필터 집합과 비교하며 제거
L_trim_loop:
    mov al, [esi]                  ; 검사할 문자를 AL에 로드
    
    ; AL 문자가 pFilterSet에 존재합니까?
    mov edi, pFilterSet
L_check_filter:
    mov bl, [edi]
    cmp bl, 0                      ; 필터 목록의 끝(Null)까지 왔는데 일치 문자가 없으면
    je L_done                      ; 필터 대상이 아니므로 트림 종료!

    cmp al, bl                     ; 현재 문자와 필터 문자 비교
    je L_match_found               ; 일치하는 문자를 찾았으면 삭제 루틴으로 점프

    inc edi                        ; 필터의 다음 문자로 이동
    jmp L_check_filter

L_match_found:
    ; 필터 집합에 있는 문자를 찾았으므로 Null 문자(0)로 잘라냄
    mov BYTE PTR [esi], 0
    
    cmp esi, pString               ; 문자열 맨 앞까지 왔다면 완전 종료
    je L_done
    
    dec esi                        ; 앞쪽 문자로 포인터 이동 후 반복 검사
    jmp L_trim_loop

L_done:
    ret                            ; 종료 (USES 구문으로 레지스터 자동 복원)
Str_trimSet ENDP

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

    ; 1. 문제 예시 실행: "ABC#$&" 에서 "%#!;$&*" 필터 세트 문자를 끝에서부터 제거
    INVOKE Str_trimSet, ADDR targetStr, ADDR filterSet

    ; 2. 결과 출력 ("ABC"가 출력되어야 함)
    INVOKE PrintString, ADDR msgResult
    INVOKE PrintString, ADDR targetStr
    INVOKE PrintString, ADDR newlineStr

    ; 3. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main