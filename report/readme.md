### **문제 (Question)**

1. Which Direction flag setting causes index registers to move backward through memory when executing string primitives?  
(문자열 원시 명령어를 실행할 때 인덱스 레지스터가 메모리를 역방향으로 이동하도록 하는 방향 플래그(Direction flag) 설정은 무엇인가요?)

---

### **정답 (Answer)**

**`1` (또는 Set / `STD` 명령어)**

---

### **풀이 및 설명 (Explanation)**

x86 아키텍처에서 문자열 처리 명령어(`MOVS`, `LODS`, `STOS`, `SCAS`, `CMPS` 등)를 실행할 때, 인덱스 레지스터(`ESI`, `EDI` 또는 `SI`, `DI`)의 주소 이동 방향은 **방향 플래그(Direction Flag, DF)**에 의해 결정됩니다.

1. **$DF = 0$ (Cleared / 0으로 설정)**
   * **명령어:** `CLD` (Clear Direction Flag)
   * **동작:** 문자열 명령어가 실행될 때마다 인덱스 레지스터가 **증가(Increment)**합니다.
   * **방향:** 메모리의 저주소에서 고주소 방향인 **순방향(Forward)**으로 이동합니다.

2. **$DF = 1$ (Set / 1로 설정)**
   * **명령어:** `STD` (Set Direction Flag)
   * **동작:** 문자열 명령어가 실행될 때마다 인덱스 레지스터가 **감소(Decrement)**합니다.
   * **방향:** 메모리의 고주소에서 저주소 방향인 **역방향(Backward)**으로 이동합니다.

따라서 인덱스 레지스터를 메모리 역방향으로 이동시키는 방향 플래그의 설정값은 **`1`**입니다.

---

### **문제 (Question)**

2. When a repeat prefix is used with STOSW, what value is added to or subtracted from the index register?  
(반복 접두사(repeat prefix)가 STOSW와 함께 사용될 때, 인덱스 레지스터에 더해지거나 빼지는 값은 얼마인가요?)

---

### **정답 (Answer)**

**`2`**

---

### **풀이 및 설명 (Explanation)**

x86 어셈블리 언어에서 문자열 명령어는 다루는 데이터의 단위 크기(Byte, Word, Doubleword 등)에 따라 인덱스 레지스터(`EDI` 또는 `DI`)의 주소 값이 자동으로 변경됩니다.

1. **`STOSW` (Store String Word)의 데이터 크기**
   * **Word(워드)** 단위는 **2바이트(16비트)** 크기입니다.
   * 따라서 `STOSW` 명령어가 실행될 때마다 2바이트씩 메모리에 저장되므로, 인덱스 레지스터의 값은 **2**만큼 변경됩니다.

2. **방향 플래그($DF$)에 따른 주소 변화**
   * $DF = 0$ (순방향): 인덱스 레지스터의 값에 **`2`가 더해집니다 (+2)**.
   * $DF = 1$ (역방향): 인덱스 레지스터의 값에서 **`2`가 빼집니다 (-2)**.

3. **참고: 명령어 종류별 이동 값**
   * `STOSB` (Byte / 1바이트): **1** 증가 또는 감소
   * `STOSW` (Word / 2바이트): **2** 증가 또는 감소
  
   ---

   ### **문제 (Question)**

3. In what way is the CMPS instruction ambiguous?  
(CMPS 명령어는 어떤 점에서 애매모호한가요?)

---

### **정답 (Answer)**

**비교할 피연산자의 데이터 크기(Byte, Word, Doubleword)가 명시되지 않는다는 점입니다.**

---

### **풀이 및 설명 (Explanation)**

x86 어셈블리 언어에서 `CMPS` (Compare String) 명령어는 두 메모리 위치의 값을 비교할 때 사용됩니다. 하지만 이 명령어는 단독으로 사용될 때 다음과 같은 모호성을 갖습니다.

1. **데이터 크기의 모호성**
   * `CMPS` 명령어 자체만으로는 비교하려는 데이터의 크기가 **1바이트(Byte)**인지, **2바이트(Word)**인지, **4바이트(Doubleword)**인지 알 수 없습니다.

2. **모호성 해결 방법**
   * **크기 전용 명령어(접미사) 사용:** 데이터 크기를 접미사로 명시하여 사용합니다.
     * `CMPSB`: Byte (1바이트) 단위 비교
     * `CMPSW`: Word (2바이트) 단위 비교
     * `CMPSD`: Doubleword (4바이트) 단위 비교
   * **타입 지시자(PTR) 사용:** 피연산자와 함께 크기를 지정합니다.  
     *(예: `CMPS BYTE PTR [ESI], BYTE PTR [EDI]`)*

따라서 `CMPS` 명령어는 피연산자의 데이터 크기 정보가 포함되어 있지 않아 단독 사용 시 크기를 지정할 수 없다는 점에서 모호합니다.

---

### **문제 (Question)**

4. When the Direction flag is clear and SCASB has found a matching character, where does EDI point?  
(방향 플래그(Direction flag)가 0으로 설정(clear)되어 있고 SCASB가 일치하는 문자를 찾았을 때, EDI는 어디를 가리키나요?)

---

### **정답 (Answer)**

**일치하는 문자 바로 다음(1바이트 뒤)의 메모리 주소를 가리킵니다.**  
*(One byte past/after the matching character)*

---

### **풀이 및 설명 (Explanation)**

x86 어셈블리 언어에서 `SCASB` (Scan String Byte) 명령어의 동작 방식과 인덱스 레지스터의 변화 과정은 다음과 같습니다.

1. **`SCASB` 명령어의 실행 순서**
   * **비교:** `AL` 레지스터의 값과 `EDI`가 가리키는 메모리 바이트(`[EDI]`)를 비교합니다.
   * **주소 변경:** 비교가 끝난 직후, 방향 플래그($DF = 0$)에 따라 `EDI` 레지스터의 값이 **1 증가(+1)**합니다.

2. **일치하는 문자를 찾았을 때의 상태**
   * `SCASB`가 일치하는 문자를 찾는 순간에도 메모리를 비교한 직후 `EDI`는 이미 1바이트 증가된 상태가 됩니다.
   * 따라서 검색 완료 시점에 `EDI`는 **일치한 문자 자체가 위치한 주소가 아니라, 그 바로 다음 바이트 주소**를 가리키게 됩니다.

> 💡 **참고 (Tip):**  
> 프로그램에서 일치하는 실제 문자의 주소를 사용하려면 `EDI` 값에서 1을 차감(`DEC EDI`)해야 합니다.

---

### **문제 (Question)**

5. When scanning an array for the first occurrence of a particular character, which repeat prefix would be best?  
(특정 문자가 처음으로 나타나는 위치를 찾기 위해 배열을 스캔할 때, 어떤 반복 접두사(repeat prefix)를 사용하는 것이 가장 좋은가요?)

---

### **정답 (Answer)**

**`REPNE` (또는 `REPNZ`)**

---

### **풀이 및 설명 (Explanation)**

x86 어셈블리에서 배열 내에서 특정 문자를 검색(`SCAS` 계열 명령어 사용)할 때는 검색 목적에 따라 올바른 반복 접두사를 선택해야 합니다.

1. **`REPNE` / `REPNZ` (Repeat while Not Equal / Repeat while Not Zero)**
   * **동작:** 비교하는 두 값이 **일치하지 않는 동안 ($ZF = 0$)** 반복을 계속 수행합니다.
   * **중단:** 두 값이 **처음으로 일치하는 순간 ($ZF = 1$)** 반복을 멈춥니다.

2. **적합한 이유**
   * 특정 문자의 "첫 번째 출현 위치"를 찾는 것은 **일치하는 문자를 만날 때까지 계속 탐색**하는 동작입니다.
   * 따라서 **일치하지 않는 동안 계속 검색을 진행하다가 처음으로 일치하는 문자를 찾으면 즉시 중단**하는 `REPNE` (Repeat while Not Equal) 접두사를 사용하는 것이 가장 적합합니다.

3. **참고: 다른 접두사와의 차이**
   * `REPNE` / `REPNZ`: **처음으로 일치하는(같은) 값**을 찾을 때 사용
   * `REPE` / `REPZ`: **처음으로 일치하지 않는(다른) 값**을 찾을 때 사용
  
---

### **문제 (Question)**

6. What Direction flag setting is used in the Str_trim procedure from Section 9.3?  
(9.3절의 Str_trim 프로시저에서 사용되는 방향 플래그(Direction flag) 설정은 무엇인가요?)

---

### **정답 (Answer)**

**`1` (또는 Set / `STD` 명령어)**

---

### **풀이 및 설명 (Explanation)**

Kip Irvine의 x86 교재 9.3절에 나오는 `Str_trim` 프로시저의 동작 원리와 방향 플래그 설정은 다음과 같습니다.

1. **`Str_trim` 프로시저의 역할**
   * 문자열의 **맨 뒤(끝)에 존재하는 특정 문자(예: 공백 등)를 제거(trim)**하는 함수입니다.

2. **역방향 탐색의 필요성**
   * 문자열 끝에서부터 앞으로 역방향으로 탐색하면서 잘라낼 필요가 없는 첫 번째(가장 뒤에 있는) 유효한 문자를 찾아야 합니다.
   * 따라서 메모리 주소를 고주소에서 저주소 방향(역방향)으로 이동시켜야 합니다.

3. **방향 플래그 설정**
   * 인덱스 레지스터(`EDI`)가 역방향으로 이동하도록 하기 위해 `STD` (Set Direction Flag) 명령어를 사용하여 **방향 플래그($DF$)를 `1`로 설정**합니다.

따라서 `Str_trim` 프로시저에서 사용하는 방향 플래그 설정값은 **`1`**입니다.

---

### **문제 (Question)**

7. Why does the Str_trim procedure from Section 9.3 use the JNE instruction?  
(9.3절의 Str_trim 프로시저는 왜 JNE 명령어를 사용하나요?)

---

### **정답 (Answer)**

**`REPE SCASB` 탐색이 끝난 원인이 "제거 대상이 아닌 문자를 찾아서($ZF = 0$)" 멈춘 것인지 확인하기 위해 사용됩니다.**

---

### **풀이 및 설명 (Explanation)**

`Str_trim` 프로시저는 문자열의 끝에서부터 역방향으로 잘라낼 문자(예: 공백)를 `REPE SCASB` 명령어로 검색합니다. 이때 `REPE SCASB` 반복문이 종료되는 이유는 두 가지가 있습니다.

1. **제거 대상이 아닌 문자를 찾은 경우 ($ZF = 0$)**
   * 잘라내야 할 문자(예: 공백)가 아닌 **유효한 문자를 발견**하면 `ZF` 플래그가 0이 되면서 탐색을 즉시 멈춥니다.
   * 이때 `JNE` (Jump if Not Equal / $ZF = 0$) 명령어가 이를 감지하여 **유효 문자를 보존하는 분기문(`L1`)으로 이동**합니다.

2. **문자열 전체가 제거 대상 문자인 경우 ($ZF = 1$, $ECX = 0$)**
   * 문자열의 모든 문자가 잘라낼 문자와 일치하여 끝까지 탐색을 완료한 경우입니다.
   * 이 경우 `ZF`가 1로 유지되므로 `JNE` 조건이 성립하지 않아 분기하지 않고, `EDI`를 추가로 차감(`DEC EDI`)하여 **문자열 전체를 빈 문자열(길이 0)로 만드는 로직을 수행**하게 됩니다.

따라서 `JNE` 명령어는 **제거 대상이 아닌 첫 번째 유효 문자를 발견하여 탐색이 중단된 상황을 구별하고, 널 문자(`\0`)를 올바른 위치에 삽입하기 위한 조건문 역할**을 합니다. `STOSD` (Doubleword / 4바이트): **4** 증가 또는 감소

따라서 `STOSW` 사용 시 인덱스 레지스터에 더해지거나 빼지는 값은 **`2`**입니다.


---

### **문제 (Question)**

8. What happens in the Str_ucase procedure from Section 9.3 if the target string contains a digit?  
(9.3절의 Str_ucase 프로시저에서 대상 문자열에 숫자가 포함되어 있으면 어떻게 되나요?)

---

### **정답 (Answer)**

**숫자는 아무런 변경 없이 그대로 유지됩니다 (무시되고 건너뜁니다).**

---

### **풀이 및 설명 (Explanation)**

`Str_ucase` 프로시저는 문자열의 각 문자를 대문자로 변환하기 전에 해당 문자가 알파벳 소문자 범위 내에 있는지 먼저 검사합니다.

1. **`Str_ucase` 내부의 조건 검사 과정**
   * 각 문자의 ASCII 코드가 소문자 범위인 `'a'` (ASCII 97 또는 `0x61`) 이상, `'z'` (ASCII 122 또는 `0x7A`) 이하인 경우에만 대문자 변환 연산(`AND` 연산)을 수행합니다.

2. **숫자가 입력되었을 때의 동작**
   * 숫자 문자 `'0'` ~ `'9'`의 ASCII 코드는 **`48` ~ `57` (`0x30` ~ `0x39`)**입니다.
   * 이 값들은 `'a'` (97)보다 작기 때문에, `cmp al, 'a'` 실행 후 `jb L2` (Below 조건 분기) 명령어에 의해 변환 과정을 거치지 않고 바로 다음 문자로 이동(`INC ESI`)합니다.

따라서 숫자는 소문자 범위에 해당하지 않으므로 변환되지 않고 **원래 상태 그대로 남아있게 됩니다.**

---

### **문제 (Question)**

9. If the Str_length procedure from Section 9.3 used SCASB, which repeat prefix would be most appropriate?  
(9.3절의 Str_length 프로시저에서 SCASB를 사용한다면, 어떤 반복 접두사(repeat prefix)가 가장 적절한가요?)

---

### **정답 (Answer)**

**`REPNE` (또는 `REPNZ`)**

---

### **풀이 및 설명 (Explanation)**

`Str_length` 프로시저는 문자열의 길이(문자의 개수)를 구하기 위해 문자열의 끝을 나타내는 **널 문자(`0` 또는 `\0`)**의 위치를 탐색합니다.

1. **`SCASB`를 이용한 널 문자 탐색 방식**
   * `AL` 레지스터에 널 문자의 값인 `0`을 넣고 `EDI`가 가리키는 문자들과 비교합니다.

2. **`REPNE` (Repeat while Not Equal)의 사용 이유**
   * 문자열의 일반 문자들은 `0`이 아니므로, 널 문자를 만나기 전까지는 두 값이 **일치하지 않는 상태($ZF = 0$)**가 유지됩니다.
   * 따라서 **널 문자가 아닌 동안 계속 이동하며 탐색을 진행하다가 널 문자를 만나면 즉시 멈추어야 하므로** `REPNE` (또는 `REPNZ`) 접두사를 사용하는 것이 가장 적합합니다.
  
---

### **문제 (Question)**

10. If the Str_length procedure from Section 9.3 used SCASB, how would it calculate and return the string length?  
(9.3절의 Str_length 프로시저에서 SCASB를 사용한다면, 문자열 길이를 어떻게 계산하고 반환하나요?)

---

### **정답 (Answer)**

**`ECX`에 카운터의 최댓값(`0FFFFFFFFh`)을 설정하고 `REPNE SCASB`로 널 문자를 찾은 뒤, `ECX`에 대해 비트 반전(`NOT ECX`) 및 1 감소(`DEC ECX`)를 수행하여 `EAX` 레지스터로 길이를 반환합니다. (또는 탐색 후 종료 `EDI` 주소에서 시작 `EDI` 주소를 뺀 후 1을 차감합니다.)**

---

### **풀이 및 설명 (Explanation)**

`SCASB`를 활용하여 문자열 길이를 계산하는 과정은 다음과 같이 이루어집니다.

1. **사전 설정 (Initialization)**
   * `EDI`: 문자열의 시작 주소를 저장합니다.
   * `AL`: 탐색할 문자 값으로 널 문자(`0`)를 저장합니다.
   * `ECX`: 가능한 최대 검색 횟수인 `0FFFFFFFFh` (또는 `-1`)로 설정합니다.
   * `CLD`: 방향 플래그를 0으로 설정하여 순방향 탐색을 지정합니다.

2. **널 문자 탐색 (`REPNE SCASB`)**
   * `REPNE SCASB`가 실행되면 바이트를 하나씩 검사할 때마다 `ECX` 값은 1씩 감소하고 `EDI`는 1씩 증가합니다.
   * 널 문자(`0`)를 만날 때까지 총 $N+1$번(문자열 길이 $N$ + 널 문자 1바이트) 비교가 일어납니다.

3. **길이 계산 및 반환 방법 (두 가지 방식)**
   * **방법 1 (`ECX` 활용):**  
     탐색 종료 후 `ECX` 값은 `0FFFFFFFFh - (N + 1)`이 됩니다.  
     이때 `NOT ECX`를 수행하면 `N + 1`이 되고, 여기서 `DEC ECX`를 수행하면 최종 문자열 길이 $N$이 계산되어 `EAX`로 반환할 수 있습니다.
   * **방법 2 (`EDI` 활용):**  
     `SCASB`가 끝난 시점의 `EDI`는 널 문자 바로 다음 주소를 가리키므로, `(최종 EDI 주소 - 시작 EDI 주소 - 1)`을 계산하여 `EAX`에 저장합니다.

 ---


### **문제 (Question)**

11. What is the maximum number of comparisons needed by the binary search algorithm when an array contains 1,024 elements?  
(배열에 1,024개의 요소가 포함되어 있을 때, 이진 탐색(binary search) 알고리즘에 필요한 최대 비교 횟수는 얼마인가요?)

---

### **정답 (Answer)**

**`11`회**

---

### **풀이 및 설명 (Explanation)**

이진 탐색(Binary Search) 알고리즘의 최악의 경우(Worst-case) 최대 비교 횟수는 배열의 크기 $N$에 대해 다음과 같이 계산됩니다.

$$\text{최대 비교 횟수} = \lfloor \log_2 N \rfloor + 1$$

1. **수식 계산**
   * $N = 1024$일 때, $1024 = 2^{10}$ 입니다.
   * $\log_2(1024) = 10$
   * 따라서 최대 비교 횟수는 $10 + 1 = \mathbf{11}$회입니다.

2. **단계별 탐색과정 (예시)**
   * 1회 비교 후: 범위가 512개로 축소
   * 2회 비교 후: 범위가 256개로 축소
   * 3회 비교 후: 범위가 128개로 축소
   * 4회 비교 후: 범위가 64개로 축소
   * 5회 비교 후: 범위가 32개로 축소
   * 6회 비교 후: 범위가 16개로 축소
   * 7회 비교 후: 범위가 8개로 축소
   * 8회 비교 후: 범위가 4개로 축소
   * 9회 비교 후: 범위가 2개로 축소
   * 10회 비교 후: 범위가 1개로 축소
   * **11회 비교:** 마지막 남아있는 1개 요소가 찾고자 하는 값인지 확인 완료

따라서 1,024개의 데이터를 이진 탐색할 때 필요한 최대 비교 횟수는 **11회**입니다.


---

### **문제 (Question)**

12. In the FillArray procedure from the Binary Search example in Section 9.5, why must the Direction flag be cleared by the CLD instruction?  
(9.5절의 이진 탐색 예제에 나오는 FillArray 프로시저에서 왜 CLD 명령어를 통해 방향 플래그(Direction flag)를 0으로 설정(clear)해야 하나요?)

---

### **정답 (Answer)**

**`STOSD` 등 문자열 명령어가 메모리의 저주소에서 고주소 방향(순방향)으로 이동하며 인덱스 레지스터(`EDI`)의 주소 값을 증가시키도록 보장하기 위해서입니다.**

---

### **풀이 및 설명 (Explanation)**

`FillArray` 프로시저는 배열을 연속된 데이터로 채우기 위해 `STOSD` (또는 유사한 문자열 원시 명령어)를 사용합니다.

1. **방향 플래그($DF$)의 중요성**
   * 문자열 명령어 실행 시 인덱스 레지스터(`EDI`)가 오름차순(순방향)으로 증가할지, 내림차순(역방향)으로 감소할지는 방향 플래그($DF$)의 상태에 따라 달라집니다.

2. **`CLD`를 실행하지 않았을 때의 문제점**
   * 이전 다른 프로시저나 코드에서 `STD` 명령어로 방향 플래그를 `1`로 설정해 둔 상태라면, `STOSD` 실행 시 `EDI` 주소 값이 **증가하지 않고 감소(역방향)**하게 됩니다.
   * 이 경우 배열의 뒤쪽 메모리 공간이나 엉뚱한 메모리 영역을 덮어쓰게 되어 프로그램에 오류가 발생합니다.

3. **`CLD` (Clear Direction Flag)의 역할**
   * `CLD` 명령어를 호출하여 $DF = 0$으로 확실히 설정함으로써, `STOSD` 연산 시 `EDI`가 항상 **2바이트 또는 4바이트씩 고주소 방향으로 올바르게 증가하며 배열을 정방향으로 채우도록 보장**합니다.
  
---

### **문제 (Question)**

13. In the BinarySearch procedure from Section 9.5, why could the statement at label L2 be removed without affecting the outcome?  
(9.5절의 BinarySearch 프로시저에서 L2 라벨 위치에 있는 문장을 제거해도 결과에 영향을 주지 않는 이유는 무엇인가요?)

---

### **정답 (Answer)**

**상단의 조건 분기를 `jge` 대신 `jg`로 변경하면 `<`(작음)과 `>`(큼) 조건이 미리 처리되어 남은 경우가 자동으로 `=`(같음)이 되므로, L2 위치의 `jne` 검사 문장을 제거할 수 있습니다.**

---

### **풀이 및 설명 (Explanation)**

교재 9.5절의 `BinarySearch` 프로시저 코드 동작 방식은 다음과 같습니다.

1. **원래 코드 구조**
    cmp  ebx, [esi + edi*4]   ; target과 array[mid] 비교
    jge  L2                   ; target >= array[mid] 이면 L2로 이동
    
    ; target < array[mid] 인 경우
    dec  edi                  ; last = mid - 1
    mov  last, edi
    jmp  L4

L2: jne  L3                   ; target > array[mid] 이면 L3로 이동
    ; target == array[mid] 인 경우 (탐색 성공)
    mov  eax, edi             ; 인덱스 반환
    jmp  L5

L3: inc  edi                  ; first = mid + 1
    mov  first, edi
    jmp  L4

2. **문장 제거가 가능한 이유**
   * 두 값의 비교 결과는 **`미만(<)`, `초과(>)`, `일치(=)`**의 3가지 경우만 존재합니다.
   * 첫 번째 조건 분기를 `jge L2` 대신 **`jg L3`**로 변경하게 되면:
     1. **`target < array[mid]`** : 밑으로 바로 내려가 `last = mid - 1` 수행
     2. **`target > array[mid]`** : `jg L3` 명령어로 `L3`로 직접 이동하여 `first = mid + 1` 수행
     3. **`target == array[mid]`** : 위 두 조건에 해당하지 않으므로 자연스럽게 탐색 성공(일치) 코드로 진행
   * 따라서 `L2` 라벨 아래의 `jne L3` 조건 검사 문장은 없어도 프로그램 실행 결과에 아무런 영향을 주지 않습니다.
  
---

