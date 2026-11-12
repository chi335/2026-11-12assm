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

; ---------------------------------------------------------------
; 1. 미초기화 데이터 세그먼트 (.data?)
; ---------------------------------------------------------------
.data?
sieve BYTE 65000 DUP(?)            ; 65,000개 바이트 배열 (0: 소수, 1: 합성수)

.data
outHandle    DWORD ?
bytesWritten DWORD ?
spaceStr     BYTE " ", 0           ; 공백 문자
newlineStr   BYTE 13, 10, 0        ; 줄바꿈 (CRLF)

.code

; ---------------------------------------------------------------
; 숫자를 십진수 문자열로 콘솔에 출력하는 보조 프로시저
; ---------------------------------------------------------------
PrintNumber PROC USES eax ebx ecx edx edi, nVal:DWORD
    LOCAL buf[12]:BYTE

    mov eax, nVal
    lea edi, [buf + 11]
    mov BYTE PTR [edi], 0          ; 문자열 끝 처리

    mov ebx, 10
    mov ecx, 0                     ; 자릿수 카운트

L_convert:
    mov edx, 0
    div ebx                        ; EAX / 10 (EAX=목, EDX=나머지)
    add dl, '0'                    ; 숫자를 ASCII 문자로 변환
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne L_convert

    ; 콘솔에 숫자 출력
    INVOKE WriteConsoleA, outHandle, edi, ecx, OFFSET bytesWritten, 0
    ret
PrintNumber ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 콘솔 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; -----------------------------------------------------------
    ; 2. STOSB 명령어를 사용하여 배열을 0으로 초기화
    ; -----------------------------------------------------------
    cld                            ; 방향 플래그 순방향(증가) 설정
    mov edi, OFFSET sieve          ; EDI = 배열 시작 주소
    mov ecx, 65000                 ; ECX = 채울 바이트 수 (65,000)
    mov al, 0                      ; AL = 채울 값 (0)
    rep stosb                      ; ECX가 0이 될 때까지 [EDI]에 AL(0)을 저장하고 EDI++

    ; -----------------------------------------------------------
    ; 3. 에라토스테네스의 체 알고리즘 실행
    ; -----------------------------------------------------------
    mov esi, 2                     ; i = 2부터 시작

L_sieve_outer:
    cmp esi, 255                   ; sqrt(65000) ≒ 254.9 이므로 255 전까지 탐색
    jae L_sieve_done

    cmp sieve[esi], 0              ; sieve[i]가 0(소수)인지 확인
    jne L_next_i

    ; i의 배수들을 1(합성수)로 마킹 (j = i * 2 부터 시작)
    mov edi, esi
    add edi, esi                   ; j = i + i (i의 2배수부터 시작)

L_sieve_inner:
    cmp edi, 65000                 ; 범위(65000) 초과 확인
    jae L_next_i

    mov sieve[edi], 1              ; 합성수로 표시 (1)
    add edi, esi                   ; j += i (다음 배수로 이동)
    jmp L_sieve_inner

L_next_i:
    inc esi                        ; 다음 숫자 i로 이동
    jmp L_sieve_outer

L_sieve_done:

    ; -----------------------------------------------------------
    ; 4. 소수(0으로 남은 값) 출력
    ; -----------------------------------------------------------
    mov esi, 2                     ; 2부터 64,999까지 탐색
    mov ebx, 0                     ; 한 줄 출력 개수 카운터

L_print_loop:
    cmp esi, 65000
    jae L_exit

    cmp sieve[esi], 0              ; 0이면 소수!
    jne L_skip_print

    ; 소수 출력
    INVOKE PrintNumber, esi
    INVOKE WriteConsoleA, outHandle, OFFSET spaceStr, 1, OFFSET bytesWritten, 0

    inc ebx
    cmp ebx, 15                    ; 15개 출력할 때마다 줄바꿈
    jne L_skip_print
    INVOKE WriteConsoleA, outHandle, OFFSET newlineStr, 2, OFFSET bytesWritten, 0
    mov ebx, 0

L_skip_print:
    inc esi
    jmp L_print_loop

L_exit:
    ; 프로그램 정상 종료
    INVOKE ExitProcess, 0
main ENDP

END main