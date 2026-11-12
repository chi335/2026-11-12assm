# 💻 Assembly Language: Chapter 9. Strings and Arrays

---

## 📌 Table of Contents
1. [개요 및 핵심 개념](#1-개요-및-핵심-개념)
2. [문자열 원시 명령어 (String Primitive Instructions)](#2-문자열-원시-명령어-string-primitive-instructions)
3. [주요 문자열 프로시저 (Selected String Procedures)](#3-주요-문자열-프로시저-selected-string-procedures)
4. [2차원 배열 (Two-Dimensional Arrays)](#4-2차원-배열-two-dimensional-arrays)
5. [정수 배열 검색 및 정렬 (Searching & Sorting)](#5-정수-배열-검색-및-정렬-searching--sorting)
6. [요약 및 핵심 팁](#6-요약-및-핵심-팁)

---

## 1. 개요 및 핵심 개념

* **숫자 vs 문자열 데이터의 차이**:
  * **숫자 `10`**: CPU에서 2진수 값($0000000Ah$)으로 저장되어 직접 산술 연산이 가능함.
  * **문자열 `"10"`**: 문자 `'1'`($31h$)과 문자 `'0'`($30h$)의 ASCII 코드 결합으로 메모리에 저장되므로 연산을 위해 ASCII $\rightarrow$ Integer 변환 과정이 필요함.
* **주요 레지스터 역할**:
  * `ESI` (Source Index): 소스 메모리의 주소를 가리키는 포인터.
  * `EDI` (Destination Index): 목적지 메모리의 주소를 가리키는 포인터.
  * `EAX` / `AX` / `AL` (Accumulator): 데이터 로드, 비교, 저장 시 사용하는 누산기.

---

## 2. 문자열 원시 명령어 (String Primitive Instructions)

32비트 모드에서 문자열 원시 명령어는 `ESI`와 `EDI` 레지스터를 묵시적(Implicit)으로 사용하며, 실행 후 자동으로 인덱스를 증가 또는 감소시킵니다.

### 2.1 주요 원시 명령어 목록
| Instruction | Operands Data Size | Description |
| :--- | :--- | :--- |
| **`MOVSB`, `MOVSW`, `MOVSD`** | Byte / Word / Doubleword | `ESI`가 가리키는 메모리 데이터를 `EDI`가 가리키는 메모리로 복사 |
| **`CMPSB`, `CMPSW`, `CMPSD`** | Byte / Word / Doubleword | `ESI`와 `EDI`가 가리키는 두 메모리 위치의 데이터 값을 비교 |
| **`SCASB`, `SCASW`, `SCASD`** | Byte / Word / Doubleword | 누산기(`AL/AX/EAX`) 값과 `EDI`가 가리키는 메모리 값 비교 |
| **`STOSB`, `STOSW`, `STOSD`** | Byte / Word / Doubleword | 누산기(`AL/AX/EAX`) 값을 `EDI`가 가리키는 메모리에 저장 |
| **`LODSB`, `LODSW`, `LODSD`** | Byte / Word / Doubleword | `ESI`가 가리키는 메모리 값을 읽어 누산기(`AL/AX/EAX`)에 로드 |

### 2.2 Direction Flag (DF) 제어
문자열 명령어 실행 후 `ESI`와 `EDI` 주소의 증감 방향을 결정합니다.

| Instruction | Direction Flag (DF) | ESI / EDI 변환 방향 | Address Sequence |
| :---: | :---: | :---: | :---: |
| **`CLD`** (Clear Direction Flag) | 0 | 자동 증가 (`+1`, `+2`, `+4`) | Low $\rightarrow$ High (정방향) |
| **`STD`** (Set Direction Flag) | 1 | 자동 감소 (`-1`, `-2`, `-4`) | High $\rightarrow$ Low (역방향) |

### 2.3 `REP` 접두사 (Repeat Prefix)
`ECX` 레지스터의 값만큼 문자열 원시 명령어를 반복 실행합니다.

```assembly
cld                         ; 정방향 설정 (DF = 0)
mov ecx, LENGTHOF source    ; 반복 횟수 설정
mov esi, OFFSET source      ; 소스 주소
mov edi, OFFSET target      ; 타겟 주소
rep movsd                   ; ECX가 0이 될 때까지 4바이트씩 복사
```

---

## 3. 주요 문자열 프로시저 (Selected String Procedures)

Irvine32 라이브러리에서 제공하는 널 종료 문자열(Null-terminated Strings) 조작 함수입니다.

### 3.1 대표 프로시저
* **`Str_compare`**: 두 문자열을 ASCII 값 기준으로 비교.
* **`Str_length`**: 널 문자(`00h`) 전까지의 문자열 길이를 계산하여 `EAX`에 반환.
* **`Str_copy`**: 소스 문자열을 타겟 메모리 위치로 복사.
* **`Str_trim`**: 문자열 끝의 특정 반복 문자를 제거.
* **`Str_ucase`**: 소문자를 대문자로 변환.

### 3.2 `Str_compare` 실행 시 플래그 변화
| 조건 관계 | Carry Flag (CF) | Zero Flag (ZF) | 조건 분기 명령어 |
| :--- | :---: | :---: | :---: |
| `string1 < string2` | 1 | 0 | `JB` (Jump if Below) |
| `string1 == string2` | 0 | 1 | `JE` (Jump if Equal) |
| `string1 > string2` | 0 | 0 | `JA` (Jump if Above) |

---

## 4. 2차원 배열 (Two-Dimensional Arrays)

### 4.1 메모리 정렬 방식
* **Row-major order (행 우선 순서)**: C/C++, 어셈블리 언어의 기본 배치 방식. 행(Row) 단위로 메모리에 연속 저장.
* **Column-major order (열 우선 순서)**: Fortran 등 일부 언어의 배치 방식. 열(Column) 단위로 연속 저장.

### 4.2 Base-Index 주소 지정 (`[base + index]`)
베이스 레지스터와 인덱스 레지스터의 합으로 2차원 배열의 특정 오프셋을 참조합니다.

$$\text{Offset} = \text{BaseAddress} + (\text{RowIndex} \times \text{RowSize}) + \text{ColumnIndex}$$

```assembly
.data
tableB BYTE 10h, 20h, 30h, 40h, 50h
       BYTE 60h, 70h, 80h, 90h, 0A0h
       BYTE 0B0h, 0C0h, 0D0h, 0E0h, 0F0h
RowSize = 5

.code
mov ebx, OFFSET tableB      ; Base: 배열의 시작 오프셋
mov eax, 1                  ; Row Index = 1
mov esi, 2                  ; Column Index = 2

mov edx, RowSize
mul edx                     ; EAX = 1 * 5 = 5 (Row Offset)

add ebx, eax                ; EBX = Row 1의 시작 주소
mov al, [ebx + esi]         ; AL = tableB[1][2] = 80h
```

---

## 5. 정수 배열 검색 및 정렬 (Searching & Sorting)

### 5.1 버블 정렬 (Bubble Sort)
인접한 두 오프셋의 데이터 값을 비교하여 조건에 따라 값을 교환(`xchg`)하는 $O(N^2)$ 알고리즘입니다.

```assembly
;-----------------------------------------------------------
BubbleSort PROC USES eax ecx esi pArray:PTR DWORD, Count:DWORD
;-----------------------------------------------------------
    mov ecx, Count
    dec ecx                 ; Outer loop = Count - 1

L1: push ecx                ; 바깥 루프 카운터 보존
    mov esi, pArray         ; 배열 주소 로드

L2: mov eax, [esi]          ; 현재 값
    cmp [esi + 4], eax      ; 다음 값과 비교
    jae L3                  ; 다음 값이 크거나 같으면 오름차순 유지

    xchg eax, [esi + 4]     ; 값 Swap
    mov [esi], eax

L3: add esi, 4              ; DWORD (4바이트) 이동
    loop L2                 ; Inner loop

    pop ecx                 ; 바깥 루프 카운터 복원
    loop L1                 ; Outer loop

    ret
BubbleSort ENDP
```

### 5.2 이진 탐색 (Binary Search)
정렬되어 있는 배열에서 중간 인덱스(Mid)의 값과 Target을 비교하여 탐색 범위를 절반씩 축소하는 $O(\log N)$ 알고리즘입니다.

```assembly
;-----------------------------------------------------------
BinarySearch PROC USES ebx edx esi edi pArray:PTR DWORD, Count:DWORD, Target:DWORD
;-----------------------------------------------------------
    mov esi, pArray         ; 배열 시작 주소
    mov eax, 0              ; Low index = 0
    mov edx, Count
    dec edx                 ; High index = Count - 1

L1: cmp eax, edx            ; Low와 High 비교
    jg L_NotFound           ; Low > High 이면 찾는 값 없음

    ; Mid 계산: (Low + High) / 2
    mov ebx, eax
    add ebx, edx
    shr ebx, 1              ; EBX = Mid Index

    mov edi, [esi + ebx*4]  ; EDI = Array[Mid]
    cmp edi, Target
    je L_Found              ; 일치하면 탐색 성공
    jg L_Greater            ; Array[Mid] > Target 이면 High 조정

    ; Array[Mid] < Target: Low = Mid + 1
    mov eax, ebx
    inc eax
    jmp L1

L_Greater:
    ; Array[Mid] > Target: High = Mid - 1
    mov edx, ebx
    dec edx
    jmp L1

L_Found:
    mov eax, ebx            ; 반환값: 찾는 요소의 인덱스
    ret
L_NotFound:
    mov eax, -1             ; 반환값: -1 (실패)
    ret
BinarySearch ENDP
```

---

## 6. 요약 및 핵심 팁

1. **원시 명령어의 성능적 이점**:
   어셈블리 루프(`LOOP`) 대신 `CLD` + `REP MOVS` 조합을 사용하면 CPU 하드웨어 단에서 최적화된 블록 복사를 수행하므로 대용량 메모리 조작 시 성능이 대폭 향상됩니다.
2. **타입별 메모리 오프셋 계산**:
   배열 요소가 `DWORD`(4바이트)나 `WORD`(2바이트)인 경우 인덱스에 요소의 `TYPE` 크기를 반드시 곱해 주어야 주소 정렬 에러가 발생하지 않습니다.
3. **제어문 구조**:
   고급 언어의 조건문(`if-else`, `switch`)과 반복문(`for`, `while`)은 어셈블리 레벨에서 `CMP` / `TEST` 명령어와 `JMP` / `JE` / `JNE` / `JA` / `JB` 등 분기 명령어의 조합으로 구현됩니다.

---

