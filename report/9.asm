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

; BinarySearch 프로토타입 선언
BinarySearch PROTO, pArray:PTR DWORD, count:DWORD, searchVal:DWORD

.data
; 정렬된 DWORD 배열 (이진 탐색은 반드시 오름차순 정렬 상태여야 함)
array       DWORD 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
ARRAY_SIZE  DWORD 10

targetVal   DWORD 70              ; 찾고자 하는 값 (인덱스 6에 위치)
foundIdx    DWORD ?

outHandle   DWORD ?
bytesWritten DWORD ?
msgFound    BYTE "Found at index: ", 0
msgNotFound BYTE "Value not found!", 13, 10, 0
countChar   BYTE 2 DUP(0), 13, 10

.code

; ---------------------------------------------------------------
; BinarySearch 프로시저 (레지스터 전용 구현)
;
; 레지스터 역할:
;   EBX = first  (탐색 시작 인덱스)
;   EDX = last   (탐색 끝 인덱스)
;   ECX = mid    (중간 인덱스)
;   EDI = searchVal (찾을 값)
;   ESI = pArray (배열 주소)
;
; 반환 값:
;   EAX = 찾은 경우 원소의 인덱스(0부터 시작), 못 찾은 경우 -1
; ---------------------------------------------------------------
BinarySearch PROC USES ebx ecx edx esi edi, 
    pArray:PTR DWORD, count:DWORD, searchVal:DWORD

    mov esi, pArray                ; ESI = 배열 포인터
    mov edi, searchVal             ; EDI = 찾고자 하는 값

    ; 1. 레지스터 초기화
    mov ebx, 0                     ; EBX (first) = 0
    mov edx, count
    dec edx                        ; EDX (last) = count - 1

L_while:
    cmp ebx, edx                   ; first > last 인지 비교
    jg L_not_found                 ; first가 last보다 커지면 탐색 실패

    ; 2. mid 계산: ECX (mid) = (EBX (first) + EDX (last)) / 2
    mov ecx, ebx
    add ecx, edx                   ; ECX = first + last
    shr ecx, 1                     ; ECX = (first + last) / 2 (우측 시프트로 2 나누기)

    ; 3. array[mid] 값 가져오기
    mov eax, [esi + ecx * 4]       ; EAX = array[mid] (DWORD이므로 인덱스 * 4)

    ; 4. searchVal과 array[mid] 비교
    cmp eax, edi
    je L_found                     ; array[mid] == searchVal (발견!)
    jl L_search_right              ; array[mid] < searchVal (오른쪽 부분 탐색)

L_search_left:
    ; array[mid] > searchVal 인 경우: last = mid - 1
    mov edx, ecx
    dec edx                        ; EDX (last) = mid - 1
    jmp L_while

L_search_right:
    ; array[mid] < searchVal 인 경우: first = mid + 1
    mov ebx, ecx
    inc ebx                        ; EBX (first) = mid + 1
    jmp L_while

L_found:
    mov eax, ecx                   ; EAX에 찾은 인덱스(mid) 담아서 반환
    ret

L_not_found:
    mov eax, -1                    ; EAX에 -1 (실패) 담아서 반환
    ret
BinarySearch ENDP

; ---------------------------------------------------------------
; 메인 함수
; ---------------------------------------------------------------
main PROC
    ; 콘솔 핸들 구하기
    INVOKE GetStdHandle, -11
    mov outHandle, eax

    ; 1. 이진 탐색 호출 (70 탐색)
    INVOKE BinarySearch, ADDR array, ARRAY_SIZE, targetVal
    mov foundIdx, eax

    ; 2. 탐색 결과 출력
    cmp eax, -1
    je L_not_found_print

    ; 성공 시 인덱스 출력
    add al, '0'                    ; 정수 인덱스를 ASCII 문자로 변환 (예: 6 -> '6')
    mov countChar[0], al
    
    INVOKE WriteConsoleA, outHandle, OFFSET msgFound, 16, OFFSET bytesWritten, 0
    INVOKE WriteConsoleA, outHandle, OFFSET countChar, 3, OFFSET bytesWritten, 0
    jmp L_exit

L_not_found_print:
    ; 실패 시 메시지 출력
    INVOKE WriteConsoleA, outHandle, OFFSET msgNotFound, 18, OFFSET bytesWritten, 0

L_exit:
    ; 3. 프로그램 종료
    INVOKE ExitProcess, 0
main ENDP

END main