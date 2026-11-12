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

; BubbleSort 프로토타입 선언
BubbleSort PROTO, pArray:PTR DWORD, count:DWORD

.data
; 정렬할 예시 배열 (10개 원소)
array       DWORD 50, 20, 40, 10, 30, 70, 60, 90, 80, 100
ARRAY_SIZE  DWORD 10

outHandle   DWORD ?
bytesWritten DWORD ?
spaceStr    BYTE " ", 0
newlineStr  BYTE 13, 10, 0

.code

; ---------------------------------------------------------------
; 숫자를 십진수로 콘솔에 출력하는 보조 프로시저
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
; BubbleSort 프로시저 (교환 플래그 추가 버전)
;
; 매개변수:
;   pArray : 정렬할 DWORD 배열의 시작 주소
;   count  : 배열의 원소 개수
; ---------------------------------------------------------------
BubbleSort PROC USES eax ebx ecx edx esi edi, pArray:PTR DWORD, count:DWORD
    LOCAL exchangeFlag:DWORD       ; 교환 발생 여부를 기록할 플래그 변수

    mov ecx, count
    dec ecx                        ; ECX = count - 1 (바깥 루프 회전 수)
    cmp ecx, 0
    jle L_done                     ; 원소 개수가 1개 이하이면 정렬 불필요

L_outer:
    push ecx                       ; 현재 회전의 비교 횟수 저장
    mov exchangeFlag, 0            ; 이번 회전 시작 시 플래그 0으로 초기화
    mov esi, pArray                ; ESI = 배열의 시작 주소

L_inner:
    mov eax, [esi]                 ; 현재 원소 값
    mov ebx, [esi + 4]             ; 다음 원소 값
    
    cmp eax, ebx                   ; 두 원소 비교
    jle L_no_swap                  ; 앞 원소가 작거나 같으면 교환 안 함 (오름차순)

    ; --- [ 원소 교환 (Swap) ] ---
    mov [esi], ebx
    mov [esi + 4], eax
    mov exchangeFlag, 1            ; ★ 교환 발생! 플래그를 1로 설정

L_no_swap:
    add esi, 4                     ; 다음 DWORD 원소로 이동 (4바이트)
    loop L_inner                   ; 안쪽 루프 반복

    ; --- [ 조기 종료 검사 ] ---
    pop ecx                        ; 바깥 루프 카운트 복원
    cmp exchangeFlag, 0            ; 이번 회전 동안 교환이 한 번도 없었는가?
    je L_done                      ; 교환이 없었다면 이미 완벽히 정렬됨 -> 조기 종료!

    loop L_outer                   ; ECX를 1 줄이고 0보다 크면 바깥 루프 계속

L_done:
    ret
BubbleSort ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 콘솔 핸들 가져오기
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; 1. 정렬 수행
    INVOKE BubbleSort, ADDR array, ARRAY_SIZE

    ; 2. 정렬된 결과 출력
    mov esi, OFFSET array
    mov ecx, ARRAY_SIZE

L_print:
    push ecx                       ; 루프 카운터 보존
    mov eax, [esi]
    INVOKE PrintNumber, eax
    INVOKE WriteConsoleA, outHandle, OFFSET spaceStr, 1, OFFSET bytesWritten, 0
    
    add esi, 4
    pop ecx                        ; 루프 카운터 복원
    loop L_print

    INVOKE WriteConsoleA, outHandle, OFFSET newlineStr, 2, OFFSET bytesWritten, 0

    ; 3. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main