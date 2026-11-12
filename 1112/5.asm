
;-----------------------------------------------------
; BubbleSort
; Sort an array of 32-bit signed integers
; in ascending order.
; Visual Studio MASM x86
;-----------------------------------------------------

.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

ExitProcess PROTO :DWORD

.data

array DWORD 9, 5, 3, 8, 1, 7
arraySize DWORD 6

.code

;-----------------------------------------------------
; BubbleSort
; pArray = pointer to array
; Count  = array size
;-----------------------------------------------------

BubbleSort PROC USES eax ecx esi edi,
    pArray:PTR DWORD,
    Count:DWORD

    mov ecx, Count

    cmp ecx, 1
    jbe sort_done

    dec ecx

L1:
    push ecx

    mov esi, pArray

L2:
    mov eax, [esi]

    ; Compare signed integers
    cmp eax, [esi+4]

    ; Skip exchange if already ordered
    jle L3

    ; Exchange values
    xchg eax, [esi+4]
    mov [esi], eax

L3:
    add esi, 4

    loop L2

    pop ecx

    loop L1

sort_done:
    ret

BubbleSort ENDP


;-----------------------------------------------------
; Main
;-----------------------------------------------------

main PROC

    invoke BubbleSort, ADDR array, arraySize

    invoke ExitProcess, 0

main ENDP

END main
