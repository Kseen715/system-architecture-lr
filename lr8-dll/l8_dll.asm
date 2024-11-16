.386
.model flat, stdcall
option casemap: none


.code
  ; Инициализирующая функция
  _DllMainCRTStartup proc hlnstDLL:DWORD, reason:DWORD, unused:DWORD
    mov EAX, 1 
    ret
  _DllMainCRTStartup endp
 
    ; Функция, которая будет экспортироваться
  
  
bubble_sort_32 proc parr:DWORD, cnt:DWORD
                   push edi
                   push esi
                   push eax
                   push edx
                   push ecx
                   push ebx


                   mov  ebx, cnt

                   cmp  ebx, 1          ; check if member count is 1 or less
                   jle  lbl3            ; if so, exit


                   sub  ebx, 1          ; set count to 1 less than member count
    lbl0:          
                   mov  esi, parr       ; load array address into ESI
                   xor  edx, edx        ; zero the "changed" flag
                   mov  edi, ebx        ; set the loop counter to member count
    lbl1:          
                   mov  eax, [esi]      ; load first pair of array numbers into registers
                   mov  ecx, [esi+4]
                   cmp  eax, ecx        ; compare which is higher
                   jle  lbl2
                   mov  [esi], ecx      ; swap if 1st number is higher
                   mov  [esi+4], eax
                   mov  edx, 1          ; Установить флаг, если было перемещение
    lbl2:          
                   add  esi, 4          ; Шаг для сравнения след пары
                   sub  edi, 1          ; Уменьшаем счетчик
                   cmp  edi, 1          ; Проверяем, достигли ли конца массива
                   jge  lbl1            ; Если нет, то переходим к следующей паре
                   test edx, edx        ; Проверяем флаг "изменения"
                   jz   lbl3            ; Выход, если нет перемещений
                   sub  ebx, 1          ; Уменьшаем верхнюю границу
                   jmp  lbl0            ; Следующий проход
    lbl3:          
                   pop  ebx
                   pop  ecx
                   pop  edx
                   pop  eax
                   pop  esi
                   pop  edi
                   ret  8
bubble_sort_32 endp

    ; ==========================================================================
    ; int sort_stdcall(int* neg_res, int* a, int length, int* pos_res,
    ; int* pos_count) -> neg_count;
    ; Сортирует массив по неубыванию
    ; ==========================================================================
sort_stdcall_enum proc neg_res:DWORD, a:DWORD, _length:DWORD, pos_res:DWORD,
    pos_count:        DWORD
                      LOCAL  neg_count:DWORD, pos_start:DWORD, neg_start:DWORD
                      push   ebx
                      push   esi
                      push   ecx
    ; Разделить массив на два массива: отрицательные и положительные числа
                      mov    neg_count, 0
                      mov    eax, pos_res
                      mov    pos_start, eax
                      mov    eax, neg_res
                      mov    neg_start, eax

                      mov    eax, a
                      mov    ecx, _length
                      inc    ecx
    _loop:            
                      dec    ecx
                      cmp    ecx, 0
                      je     _end
                      mov    esi, dword ptr [eax]
                      cmp    esi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [pos_res]
                      mov    dword ptr [ebx], esi
                      add    pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [neg_res]
                      mov    dword ptr [ebx], esi
                      add    neg_res, 4
                      add    eax, 4
                      inc    neg_count
                      jmp    _loop
    _end:             
    ; Сортировка массива положительных чисел
                      mov    ebx, dword ptr [pos_count]
                      push   dword ptr [ebx]
                      push   pos_start
                      call   bubble_sort_32

                      push   neg_count
                      push   neg_start
                      call   bubble_sort_32

                      mov    eax, neg_count
                      pop    ecx
                      pop    esi
                      pop    ebx
                      ret    20
sort_stdcall_enum endp

    ; ==========================================================================
    ; int sort_stdcall(int* neg_res, int* a, int length, int* pos_res,
    ; int* pos_count) -> neg_count;
    ; Сортирует массив по неубыванию
    ; ==========================================================================
sort_cdecl_enum proc c neg_res:DWORD, a:DWORD, _length:DWORD, pos_res:DWORD,
    pos_count:        DWORD
                      LOCAL  neg_count:DWORD, pos_start:DWORD, neg_start:DWORD
                      push   ebx
                      push   edi
                      push   ecx
    ; Разделить массив на два массива: отрицательные и положительные числа
                      mov    neg_count, 0
                      mov    eax, pos_res
                      mov    pos_start, eax
                      mov    eax, neg_res
                      mov    neg_start, eax

                      mov    eax, a
                      mov    ecx, _length
                      inc    ecx
    _loop:            
                      dec    ecx
                      cmp    ecx, 0
                      je     _end
                      mov    edi, dword ptr [eax]
                      cmp    edi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [pos_res]
                      mov    dword ptr [ebx], edi
                      add    pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [neg_res]
                      mov    dword ptr [ebx], edi
                      add    neg_res, 4
                      add    eax, 4
                      inc    neg_count
                      jmp    _loop
    _end:             
    ; Сортировка массива положительных чисел
                      mov    ebx, dword ptr [pos_count]
                      invoke bubble_sort_32, pos_start, dword ptr [ebx]
                      invoke bubble_sort_32, neg_start, neg_count
                      mov    eax, neg_count
                      pop    ecx
                      pop    edi
                      pop    ebx
                      ret
sort_cdecl_enum endp

sort_stdcall proc
                      LOCAL  _neg_count:DWORD, _pos_start:DWORD
                      LOCAL  _neg_start:DWORD
                      LOCAL  _neg_res:DWORD, _a:DWORD, _length:DWORD
                      LOCAL  _pos_res:DWORD, _pos_count:DWORD
                      push   ebx
                      push   edi
                      push   ecx

                      mov    eax, dword ptr [esp + 4 + 12*4]
                      mov    _neg_res, eax
                      mov    eax, dword ptr [esp + 8 + 12*4]
                      mov    _a, eax
                      mov    eax, dword ptr [esp + 12 + 12*4]
                      mov    _length, eax
                      mov    eax, dword ptr [esp + 16 + 12*4]
                      mov    _pos_res, eax
                      mov    eax, dword ptr [esp + 20 + 12*4]
                      mov    _pos_count, eax

    ; Разделить массив на два массива: отрицательные и положительные числа
                      mov    _neg_count, 0
                      mov    eax, _pos_res
                      mov    _pos_start, eax
                      mov    eax, _neg_res
                      mov    _neg_start, eax

                      mov    eax, _a
                      mov    ecx, _length
                      inc    ecx
    _loop:            
                      dec    ecx
                      cmp    ecx, 0
                      je     _end
                      mov    edi, dword ptr [eax]
                      cmp    edi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [_pos_res]
                      mov    dword ptr [ebx], edi
                      add    _pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [_pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [_pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [_neg_res]
                      mov    dword ptr [ebx], edi
                      add    _neg_res, 4
                      add    eax, 4
                      inc    _neg_count
                      jmp    _loop
    _end:             
    ; Сортировка массива положительных чисел
                      mov    ebx, dword ptr [_pos_count]
                      invoke bubble_sort_32, _pos_start, dword ptr [ebx]
                      invoke bubble_sort_32, _neg_start, _neg_count
                      mov    eax, _neg_count
                      pop    ecx
                      pop    edi
                      pop    ebx
                      ret    20
sort_stdcall endp

sort_cdecl proc c
                      LOCAL  _neg_count:DWORD, _pos_start:DWORD
                      LOCAL  _neg_start:DWORD
                      LOCAL  _neg_res:DWORD, _a:DWORD, _length:DWORD
                      LOCAL  _pos_res:DWORD, _pos_count:DWORD
                      push   ebx
                      push   edi
                      push   ecx

                      mov    eax, dword ptr [esp + 4 + 12*4]
                      mov    _neg_res, eax
                      mov    eax, dword ptr [esp + 8 + 12*4]
                      mov    _a, eax
                      mov    eax, dword ptr [esp + 12 + 12*4]
                      mov    _length, eax
                      mov    eax, dword ptr [esp + 16 + 12*4]
                      mov    _pos_res, eax
                      mov    eax, dword ptr [esp + 20 + 12*4]
                      mov    _pos_count, eax

    ; Разделить массив на два массива: отрицательные и положительные числа
                      mov    _neg_count, 0
                      mov    eax, _pos_res
                      mov    _pos_start, eax
                      mov    eax, _neg_res
                      mov    _neg_start, eax

                      mov    eax, _a
                      mov    ecx, _length
                      inc    ecx
    _loop:            
                      dec    ecx
                      cmp    ecx, 0
                      je     _end
                      mov    edi, dword ptr [eax]
                      cmp    edi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [_pos_res]
                      mov    dword ptr [ebx], edi
                      add    _pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [_pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [_pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [_neg_res]
                      mov    dword ptr [ebx], edi
                      add    _neg_res, 4
                      add    eax, 4
                      inc    _neg_count
                      jmp    _loop
    _end:             
    ; Сортировка массива положительных чисел
                      mov    ebx, dword ptr [_pos_count]
                      invoke bubble_sort_32, _pos_start, dword ptr [ebx]
                      invoke bubble_sort_32, _neg_start, _neg_count
                      mov    eax, _neg_count
                      pop    ecx
                      pop    edi
                      pop    ebx
                      ret
sort_cdecl endp

sort_fastcall proc
                      LOCAL  _neg_count:DWORD, _pos_start:DWORD
                      LOCAL  _neg_start:DWORD
                      LOCAL  _neg_res:DWORD, _a:DWORD, _length:DWORD
                      LOCAL  _pos_res:DWORD, _pos_count:DWORD
                      push   ebx
                      push   edi
                      push   ecx

                      mov    _neg_res, eax
                      mov    _a, edx
                      mov    eax, dword ptr [esp + 4 + 12*4]
                      mov    _length, eax
                      mov    eax, dword ptr [esp + 8 + 12*4]
                      mov    _pos_res, eax
                      mov    eax, dword ptr [esp + 12 + 12*4]
                      mov    _pos_count, eax

    ; Разделить массив на два массива: отрицательные и положительные числа
                       mov    _neg_count, 0
                      mov    eax, _pos_res
                      mov    _pos_start, eax
                      mov    eax, _neg_res
                      mov    _neg_start, eax

                      mov    eax, _a
                      mov    ecx, _length
                      inc    ecx
    _loop:            
                      dec    ecx
                      cmp    ecx, 0
                      je     _end
                      mov    edi, dword ptr [eax]
                      cmp    edi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [_pos_res]
                      mov    dword ptr [ebx], edi
                      add    _pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [_pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [_pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [_neg_res]
                      mov    dword ptr [ebx], edi
                      add    _neg_res, 4
                      add    eax, 4
                      inc    _neg_count
                      jmp    _loop
    _end:             
    ; Сортировка массива положительных чисел
                      mov    ebx, dword ptr [_pos_count]
                      invoke bubble_sort_32, _pos_start, dword ptr [ebx]
                      invoke bubble_sort_32, _neg_start, _neg_count
                      mov    eax, _neg_count
                      pop    ecx
                      pop    edi
                      pop    ebx
                      ret    12
sort_fastcall endp

end
 