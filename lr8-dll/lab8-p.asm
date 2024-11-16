.386
.model flat, stdcall
option casemap: none 

.code
  _DllMainCRTStartup proc hlnstDLL:DWORD, reason:DWORD, unused:DWORD 
    mov EAX, 1 
    ret
  _DllMainCRTStartup endp
sort_stdcall proc stdcall 
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH EDI
    PUSH ESI
 
    MOV EDX, [ESP+6*4+4]
    SUB EDX, [ESP+6*4+0]
    INC EDX                     ; EDX = (end - start + 1)  (размер массива res)
 
    MOV ESI, [ESP+6*4+12]       ; ESI = &a
    MOV EAX, [ESP+6*4+0]        ; EAX = start
    IMUL EAX, 4                 ; EAX = start*4
 
    MOV ECX, EDX                ; ECX = EDX  (счетчик)
    ADD ESI, EAX                ; ESI = &a + start*4
    MOV EDI, [ESP+6*4+8]        ; EDI = &res
    REP MOVSD                   ; Копирование массива двойных слов
 
 
    MOV EDI, [ESP+6*4+8]        ; EDI = &res
    MOV EBX, 0                  ; EBX = 0  (i)
    loop_sort_arr_outer:
      MOV ECX, EBX              ; ECX = i  (j)
      MOV ESI, ECX              ; ESI = i  (minIndex)
      loop_sort_arr_inner:
        INC ECX                 ; ECX += 1
        MOV EAX, [EDI+ESI*4]
        CMP EAX, [EDI+ECX*4]
        JLE sort_arr_no_swap    ; Если не (res[minIndex] > res[j]), то пропустить обмен
          MOV ESI, ECX          ; minIndex = j
        sort_arr_no_swap:
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до конца массива res
      loop_sort_arr_inner_end:
      MOV EAX, [EDI+EBX*4]      ; EAX = res[i]
      MOV ECX, [EDI+ESI*4]      ; ECX = res[minIndex]
      MOV [EDI+EBX*4], ECX      ; res[i] = res[minIndex]
      MOV [EDI+ESI*4], EAX      ; res[minIndex] = res[i]
      INC EBX                   ; EBX += 1
      CMP EBX, EDX
      JL loop_sort_arr_outer    ; Цикл пока не пройдем по всем элементам массива res
    loop_sort_arr_outer_end:
 
    MOV EAX, [ESP+6*4+8]        ; EAX = &res
 
    POP ESI
    POP EDI
    POP EDX
    POP ECX
    POP EBX
    RET 4*4 
sort_stdcall endp

fastcall_count_chars proc 
    PUSH EBX
    PUSH EDI
    PUSH ESI
    MOV ESI, ECX                      ; адрес строки (1 через регистры)
    MOV EDI, EDX                      ;адрес массива (2 через регистр)
    CountLoop:
        MOVZX ECX, BYTE PTR [ESI]     ;берем элемент строки 
        CMP ECX, 0                    ;проверяем на ноль (конец строки)
        JZ EndLoop                    ;если ноль, то выходим из цикла
        MOV EAX, EDI 
        ADD EAX, ECX  
        MOVZX EBX, BYTE PTR [EAX]      ;элемент строки + указатель на результирующий массив 
        INC EBX                        ;счетчик буквы + 1
        MOV BYTE PTR [EAX], BL         ;выгружаем байт
        INC ESI                         
    JMP CountLoop
    EndLoop:
    POP ESI
    POP EDI
    POP EBX
    RET              ; +1 переменная из стека
fastcall_count_chars endp

sort_cdecl proc 
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH EDI
    PUSH ESI
 
    MOV EDX, [ESP+6*4+4]
    SUB EDX, [ESP+6*4+0]
    INC EDX                     ; EDX = (end - start + 1)  (размер массива res)
 
    MOV ESI, [ESP+6*4+12]       ; ESI = &a
    MOV EAX, [ESP+6*4+0]        ; EAX = start
    IMUL EAX, 4                 ; EAX = start*4
 
    MOV ECX, EDX                ; ECX = EDX  (счетчик)
    ADD ESI, EAX                ; ESI = &a + start*4
    MOV EDI, [ESP+6*4+8]        ; EDI = &res
    REP MOVSD                   ; Копирование массива двойных слов
 
 
    MOV EDI, [ESP+6*4+8]        ; EDI = &res
    MOV EBX, 0                  ; EBX = 0  (i)
    loop_sort_arr_outer:
      MOV ECX, EBX              ; ECX = i  (j)
      MOV ESI, ECX              ; ESI = i  (minIndex)
      loop_sort_arr_inner:
        INC ECX                 ; ECX += 1
        MOV EAX, [EDI+ESI*4]
        CMP EAX, [EDI+ECX*4]
        JLE sort_arr_no_swap    ; Если не (res[minIndex] > res[j]), то пропустить обмен
          MOV ESI, ECX          ; minIndex = j
        sort_arr_no_swap:
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до конца массива res
      loop_sort_arr_inner_end:
      MOV EAX, [EDI+EBX*4]      ; EAX = res[i]
      MOV ECX, [EDI+ESI*4]      ; ECX = res[minIndex]
      MOV [EDI+EBX*4], ECX      ; res[i] = res[minIndex]
      MOV [EDI+ESI*4], EAX      ; res[minIndex] = res[i]
      INC EBX                   ; EBX += 1
      CMP EBX, EDX
      JL loop_sort_arr_outer    ; Цикл пока не пройдем по всем элементам массива res
    loop_sort_arr_outer_end:
 
    MOV EAX, [ESP+6*4+8]        ; EAX = &res
 
    POP ESI
    POP EDI
    POP EDX
    POP ECX
    POP EBX
    RET
sort_cdecl endp 

sort_fastcall proc
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH EDI
    PUSH ESI
 
    MOV EDX, [ESP+6*4+4]
    SUB EDX, [ESP+6*4+0]
    INC EDX                     ; EDX = (end - start + 1)  (размер массива res)
 
    MOV ESI, [ESP+6*4+12]       ; ESI = &a
    MOV EAX, [ESP+6*4+0]        ; EAX = start
    IMUL EAX, 4                 ; EAX = start*4
 
    MOV ECX, EDX                ; ECX = EDX  (счетчик)
    ADD ESI, EAX                ; ESI = &a + start*4
    MOV EDI, [ESP+6*4+8]        ; EDI = &res
    REP MOVSD                   ; Копирование массива двойных слов
 
 
    MOV EDI, [ESP+6*4+8]        ; EDI = &res
    MOV EBX, 0                  ; EBX = 0  (i)
    loop_sort_arr_outer:
      MOV ECX, EBX              ; ECX = i  (j)
      MOV ESI, ECX              ; ESI = i  (minIndex)
      loop_sort_arr_inner:
        INC ECX                 ; ECX += 1
        MOV EAX, [EDI+ESI*4]
        CMP EAX, [EDI+ECX*4]
        JLE sort_arr_no_swap    ; Если не (res[minIndex] > res[j]), то пропустить обмен
          MOV ESI, ECX          ; minIndex = j
        sort_arr_no_swap:
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до конца массива res
      loop_sort_arr_inner_end:
      MOV EAX, [EDI+EBX*4]      ; EAX = res[i]
      MOV ECX, [EDI+ESI*4]      ; ECX = res[minIndex]
      MOV [EDI+EBX*4], ECX      ; res[i] = res[minIndex]
      MOV [EDI+ESI*4], EAX      ; res[minIndex] = res[i]
      INC EBX                   ; EBX += 1
      CMP EBX, EDX
      JL loop_sort_arr_outer    ; Цикл пока не пройдем по всем элементам массива res
    loop_sort_arr_outer_end:
 
    MOV EAX, [ESP+6*4+8]        ; EAX = &res
 
    POP ESI
    POP EDI
    POP EDX
    POP ECX
    POP EBX
    RET
sort_fastcall endp 


count_same_chars proc
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI

    MOV ESI, [ESP+6*4+0]       ; ESI = начало массива
    MOV EDX, [ESP+6*4+4]       ; EDX = конец массива
    XOR EAX, EAX               ; EAX = 0 (счетчик одинаковых символов)

    loop_count_chars:
      MOV ECX, [ESI]           ; Загружаем символ из массива
      CMP ECX, [ESI+4]         ; Сравниваем его со следующим символом
      JNE no_increment         ; Если символы не равны, переходим к метке no_increment
        INC EAX                ; Увеличиваем счетчик на 1
      no_increment:
      ADD ESI, 4               ; Переходим к следующему символу в массиве
      CMP ESI, EDX             ; Сравниваем текущую позицию с концом массива
      JL loop_count_chars      ; Если текущая позиция меньше конца массива, переходим к метке loop_count_chars

    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    RET
count_same_chars endp

; ==================================================
  ; int* sort(int start, int end, int* res, const int* a) 
  ; Запись в массив res отсортированнного по не убыванию массива a на отрезке [start..end]

sort_stdcall_args proc stdcall start_:DWORD, end_:DWORD, res_:DWORD, a_:DWORD
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH EDI
    PUSH ESI
 
    MOV EDX, end_
    SUB EDX, start_
    INC EDX                     ; EDX = (end - start + 1)  (размер массива res)
 
    MOV ESI, a_                 ; ESI = &a
    MOV EAX, start_             ; EAX = start
    IMUL EAX, 4                 ; EAX = start*4
 
    MOV ECX, EDX                ; ECX = EDX  (счетчик)
    ADD ESI, EAX                ; ESI = &a + start*4
    MOV EDI, res_               ; EDI = &res
    REP MOVSD                   ; Копирование массива двойных слов
 
    MOV EDI, res_               ; EDI = &res
    MOV EBX, 0                  ; EBX = 0  (i)
    loop_sort_arr_outer:
      MOV EAX, [EDI+EBX*4]      ; EAX = res[i]
      MOV ECX, EBX              ; ECX = i  (j)
      loop_sort_arr_inner:
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[i] > res[j]), то пропустить обмен
          MOV EAX, [EDI+ECX*4]  ; EAX = res[j]
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наименьшего элемента, 
                                ; который смещен выбором в начало массива res
      loop_sort_arr_inner_end:
      XCHG EAX, [EDI+EBX*4]     ; Обмен res[i] и наименьшего элемента
      INC EBX                   ; EBX += 1
      CMP EBX, EDX
      JL loop_sort_arr_outer    ; Цикл пока не пройдем по всем элементам массива res
    loop_sort_arr_outer_end:
 
    MOV EAX, res_               ; EAX = &res
 
    POP ESI
    POP EDI
    POP EDX
    POP ECX
    POP EBX
    RET 4*4 
sort_stdcall_args endp 
 ; ==================================================
  ; int* sort(int start, int end, int* res, const int* a) 
  ; Запись в массив res отсортированнного по не убыванию массива a на отрезке [start..end]

sort_cdecl_args proc c start_:DWORD, end_:DWORD, res_:DWORD, a_:DWORD
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH EDI
    PUSH ESI
 
    MOV EDX, end_
    SUB EDX, start_
    INC EDX                     ; EDX = (end - start + 1)  (размер массива res)
 
    MOV ESI, a_                 ; ESI = &a
    MOV EAX, start_             ; EAX = start
    IMUL EAX, 4                 ; EAX = start*4
 
    MOV ECX, EDX                ; ECX = EDX  (счетчик)
    ADD ESI, EAX                ; ESI = &a + start*4
    MOV EDI, res_               ; EDI = &res
    REP MOVSD                   ; Копирование массива двойных слов
 
    MOV EDI, res_               ; EDI = &res
    MOV EBX, 0                  ; EBX = 0  (i)
    loop_sort_arr_outer:
      MOV EAX, [EDI+EBX*4]      ; EAX = res[i]
      MOV ECX, EBX              ; ECX = i  (j)
      loop_sort_arr_inner:
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[i] > res[j]), то пропустить обмен
          MOV EAX, [EDI+ECX*4]  ; EAX = res[j]
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наименьшего элемента, 
                                ; который смещен выбором в начало массива res
      loop_sort_arr_inner_end:
      XCHG EAX, [EDI+EBX*4]     ; Обмен res[i] и наименьшего элемента
      INC EBX                   ; EBX += 1
      CMP EBX, EDX
      JL loop_sort_arr_outer    ; Цикл пока не пройдем по всем элементам массива res
    loop_sort_arr_outer_end:
 
    MOV EAX, res_               ; EAX = &res
 
    POP ESI
    POP EDI
    POP EDX
    POP ECX
    POP EBX
    RET
sort_cdecl_args endp 
end 