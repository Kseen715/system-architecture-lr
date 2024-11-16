.386
.model flat, stdcall
option casemap: none

include include\windows.inc
include include\kernel32.inc
include include\user32.inc
include include\msvcrt.inc


includelib user32.lib
includelib kernel32.lib
includelib msvcrt.lib


.data
    dbg_hex64_fmt   DB "DBG: 0x%016llX", 13, 10, 0
    dbg_hex32_fmt   DB "DBG: 0x%08lX", 13, 10, 0
    dbg_hex16_fmt   DB "DBG: 0x%04X", 13, 10, 0
    dbg_hex8_fmt    DB "DBG: 0x%02X", 13, 10, 0
        
    dbg_int64_fmt   DB "DBG: 0d%lld", 13, 10, 0
    dbg_int32_fmt   DB "DBG: 0d%d", 13, 10, 0
    dbg_int16_fmt   DB "DBG: 0d%hd", 13, 10, 0
    dbg_int8_fmt    DB "DBG: 0d%hhd", 13, 10, 0
          
    dbg_float64_fmt DB "DBG: 0f%lf", 13, 10, 0
    dbg_float32_fmt DB "DBG: 0f%f", 13, 10, 0

    dbg_nline_fmt   DB 13, 10, 0
.code

bubble_sort_32 proc parr:DWORD, cnt:DWORD
                   push edi
                   push esi
                   push eax
                   push edx
                   push ecx
                   push ebx


                   mov  ebx, cnt
                   sub  ebx, 1          ; set count to 1 less than member count
    lbl0:          
                   mov  esi, parr       ; load array address into ESI
                   xor  edx, edx        ; zero the "changed" flag
                   mov  edi, ebx        ; set the loop counter to member count
    ;    invoke crt_printf, offset dbg_hex32_fmt, edi
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
                   cmp  edi, 0          ; Проверяем, достигли ли конца массива
                   jne  lbl1            ; Если нет, то переходим к следующей паре
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

print_array proc array_ptr:dword, array_size:dword, item_size:dword
.data
    print_array_fmt DB "%d ",0
.code
                      push   ebx
                      push   eax
                      push   ecx
                      push   edx

                      mov    ecx, array_ptr
                      mov    ebx, array_size
    prnt:             
                      mov    eax, item_size
                      cmp    eax, 1
                      je     switch1
                      cmp    eax, 2
                      je     switch2
                      cmp    eax, 4
                      je     switch4
    switch1:          
                      mov    eax, 0
                      mov    al, byte ptr [ecx]                                   ; ecx = array[i]
                      jmp    switch_end
    switch2:          
                      mov    eax, 0
                      mov    ax, word ptr [ecx]                                   ; ecx = array[i]
                      jmp    switch_end
    switch4:          
                      mov    eax, 0
                      mov    eax, dword ptr [ecx]                                 ; ecx = array[i]
                      jmp    switch_end
    switch_end:       
                      push   eax
                      push   ecx
                      push   eax
                      push   offset print_array_fmt
                      call   crt_printf                                           ; Вывод результата на экран
                      add    esp, 2*4
                      pop    ecx
                      pop    eax
                      add    ecx, item_size                                       ; ecx = array[i+1]
                      dec    ebx                                                  ; ebx = n-1
                      cmp    ebx, 0
                      jne    prnt                                                 ; если ebx не равно 0, то переходим
    ; к следующему элементу массива
                      pop    edx
                      pop    ecx
                      pop    eax
                      pop    ebx
                      RET    8
print_array endp



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
                      invoke bubble_sort_32, pos_start, dword ptr [ebx]
                      invoke bubble_sort_32, neg_start, neg_count
                      mov    eax, neg_count
                      pop    ecx
                      pop    esi
                      pop    ebx
                      ret
sort_cdecl_enum endp

sort_stdcall proc
                      LOCAL  _neg_count:DWORD, _pos_start:DWORD
                      LOCAL  _neg_start:DWORD
                      LOCAL  _neg_res:DWORD, _a:DWORD, _length:DWORD
                      LOCAL  _pos_res:DWORD, _pos_count:DWORD
                      push   ebx
                      push   esi
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
                      mov    esi, dword ptr [eax]
                      cmp    esi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [_pos_res]
                      mov    dword ptr [ebx], esi
                      add    _pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [_pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [_pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [_neg_res]
                      mov    dword ptr [ebx], esi
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
                      pop    esi
                      pop    ebx
                      ret    20
sort_stdcall endp

sort_cdecl proc c
                      LOCAL  _neg_count:DWORD, _pos_start:DWORD
                      LOCAL  _neg_start:DWORD
                      LOCAL  _neg_res:DWORD, _a:DWORD, _length:DWORD
                      LOCAL  _pos_res:DWORD, _pos_count:DWORD
                      push   ebx
                      push   esi
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
                      mov    esi, dword ptr [eax]
                      cmp    esi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [_pos_res]
                      mov    dword ptr [ebx], esi
                      add    _pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [_pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [_pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [_neg_res]
                      mov    dword ptr [ebx], esi
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
                      pop    esi
                      pop    ebx
                      ret
sort_cdecl endp

sort_fastcall proc
                      LOCAL  _neg_count:DWORD, _pos_start:DWORD
                      LOCAL  _neg_start:DWORD
                      LOCAL  _neg_res:DWORD, _a:DWORD, _length:DWORD
                      LOCAL  _pos_res:DWORD, _pos_count:DWORD
                      push   ebx
                      push   esi
                      push   ecx

                      mov    _neg_res, eax
                      mov    _a, edx
                      mov    eax, dword ptr [esp + 12 + 10*4]
                      mov    _length, eax
                      mov    eax, dword ptr [esp + 16 + 10*4]
                      mov    _pos_res, eax
                      mov    eax, dword ptr [esp + 20 + 10*4]
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
                      mov    esi, dword ptr [eax]
                      cmp    esi, 0
                      jge    _pos
                      jl     _neg
                      jmp    _end
    _pos:             
                      mov    ebx, dword ptr [_pos_res]
                      mov    dword ptr [ebx], esi
                      add    _pos_res, 4
                      add    eax, 4
                      mov    ebx, dword ptr [_pos_count]
                      inc    dword ptr [ebx]
                      mov    dword ptr [_pos_count], ebx
                      jmp    _loop
    _neg:             
                      mov    ebx, dword ptr [_neg_res]
                      mov    dword ptr [ebx], esi
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
                      pop    esi
                      pop    ebx
                      ret    20
sort_fastcall endp


    start:            
.data
    a         DD -5, 4, -2, 3, 1, 0, 2, -1, 5, -3, 4
    a_len     DD ($ - a) / 4

    pos_count DD 0
    neg_count DD 0

    pos_res   DD 1024 DUP(0)
    neg_res   DD 1024 DUP(0)


.code
         invoke print_array, offset a, a_len, 4
         invoke crt_printf, offset dbg_nline_fmt

    ;  invoke crt_printf, offset dbg_hex32_fmt, offset neg_res
    ;  invoke crt_printf, offset dbg_hex32_fmt, offset a
    ;  invoke crt_printf, offset dbg_hex32_fmt, a_len
    ;  invoke crt_printf, offset dbg_hex32_fmt, offset pos_res
    ;  invoke crt_printf, offset dbg_nline_fmt

         mov    ESI, ESP

    ;  invoke crt_printf, offset dbg_hex32_fmt, ESP
    ;  invoke crt_printf, offset dbg_hex32_fmt, ESI

         push   offset pos_count
         push   offset pos_res
         push   a_len
         push   offset a
         push   offset neg_res
         call   sort_stdcall_enum
        ;  add    esp, 20
        
    ;  push   offset pos_count
    ;  push   offset pos_res
    ;  push   a_len
    ;  mov    edx, offset a
    ;  mov    eax, offset neg_res
    ;  call   sort_fastcall


         mov    neg_count, eax
         invoke print_array, offset pos_res, pos_count, 4
         invoke crt_printf, offset dbg_nline_fmt
         invoke print_array, offset neg_res, neg_count, 4
         invoke crt_printf, offset dbg_nline_fmt


         invoke ExitProcess, 0                               ; Выход из программы
end start