
;------------------------------------------------------------
; BinarySearch
; Search an array of signed integers.
;
; Receives:
;   pArray    = pointer to array
;   Count     = array size
;   searchVal = search value
;
; Returns:
;   EAX = array position if found
;   EAX = -1 if not found
;------------------------------------------------------------

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

ExitProcess PROTO :DWORD

.data

array SDWORD 10, 20, 30, 40, 50, 60, 70
arraySize DWORD 7
searchValue SDWORD 40

resultMsg BYTE "Binary Search Result: ",0

.code

BinarySearch PROC USES ebx edx esi edi,
    pArray:PTR SDWORD,
    Count:DWORD,
    searchVal:SDWORD

    LOCAL first:DWORD
    LOCAL last:DWORD
    LOCAL mid:DWORD

    ; first = 0
    mov first, 0

    ; last = Count - 1
    mov eax, Count
    cmp eax, 0
    je search_failed

    dec eax
    mov last, eax

    ; EDI = search value
    mov edi, searchVal

    ; EBX = array address
    mov ebx, pArray

L1:
    ; Check first <= last
    mov eax, first
    cmp eax, last
    jg search_failed

    ; mid = (first + last) / 2
    mov eax, first
    add eax, last
    shr eax, 1

    mov mid, eax

    ; Calculate array address
    mov esi, eax
    shl esi, 2

    ; EDX = array[mid]
    mov edx, [ebx+esi]

    ; Compare array[mid] with searchVal
    cmp edx, edi
    jl search_right

    jg search_left

    ; Value found
    mov eax, mid
    jmp search_done

search_right:
    ; first = mid + 1
    mov eax, mid
    inc eax
    mov first, eax

    jmp L1

search_left:
    ; last = mid - 1
    mov eax, mid
    dec eax
    mov last, eax

    jmp L1

search_failed:
    ; Not found
    mov eax, -1

search_done:
    ret

BinarySearch ENDP


;------------------------------------------------------------
; Main
;------------------------------------------------------------

main PROC

    invoke BinarySearch, ADDR array, arraySize, searchValue

    ; EAX contains result
    ; Example: 3

    invoke ExitProcess, 0

main ENDP

END main
