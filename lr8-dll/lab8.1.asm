.386
.model flat, stdcall
option casemap: none
include windows.inc
include kernel32.inc
include user32.inc
include msvcrt.inc

includelib user32.lib
includelib kernel32.lib
includelib msvcrt.lib
 
.data
    array dd 1,4,5,7,2,3,8
    result dd 0,0,0,0,0,0,0

    format db "%d ",0               
    format1 db 10,10,0 

.code

print_array proc                    ; функция вывода массива на экран
    push ebx
    push eax
    push ecx
    push edx

    mov ecx, [ESP+4+4*4]            ; в ecx записывается исходный массив
    mov ebx, [ESP+8+4*4]            ; в ebx = n ( размер массива )      
    
    
prin:
    mov eax, [ecx]                  ; ecx = array[i]

    push eax
    push ecx

    push eax
    push offset format
    call crt_printf                 ; Вывод результата на экран
    add esp, 2*4
    
    pop ecx
    pop eax


    add ecx, 4                      ; ecx = array[i+1]
    dec ebx                         ; ebx = n-1
    cmp ebx, 0
    jne prin                        ; если ebx не равно 0, то переходим к следующему элементу массива
    
    pop edx
    pop ecx
    pop eax
    pop ebx
    RET 8
print_array endp

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
      MOV ECX, 1                ; ECX = 1  (j)
      loop_sort_arr_inner:
        MOV EAX, [EDI+ECX*4-4]  ; EAX = res[j - 1]
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[j - 1] > res[j]), то пропустить обмен
          MOV ESI, [EDI+ECX*4]    ; ESI = res[j]
          MOV [EDI+ECX*4], EAX    ; res[j] = res[j - 1]
          MOV [EDI+ECX*4-4], ESI  ; res[j - 1] = ESI
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        MOV ESI, EDX            ; ESI = size
        SUB ESI, EBX            ; ESI = size - i
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наибольшего элемента, 
                                ; который смещен пузырьком в конец массива res
      loop_sort_arr_inner_end:
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

sort_cdecl proc c
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
      MOV ECX, 1                ; ECX = 1  (j)
      loop_sort_arr_inner:
        MOV EAX, [EDI+ECX*4-4]  ; EAX = res[j - 1]
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[j - 1] > res[j]), то пропустить обмен
          MOV ESI, [EDI+ECX*4]    ; ESI = res[j]
          MOV [EDI+ECX*4], EAX    ; res[j] = res[j - 1]
          MOV [EDI+ECX*4-4], ESI  ; res[j - 1] = ESI
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        MOV ESI, EDX            ; ESI = size
        SUB ESI, EBX            ; ESI = size - i
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наибольшего элемента, 
                                ; который смещен пузырьком в конец массива res
      loop_sort_arr_inner_end:
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
    PUSH EDI
    PUSH ESI
    ; ECX = start,  EDX = end
 
    SUB EDX, ECX                ; EDX = end - start
    INC EDX                     ; EDX = (end - start + 1)  (размер массива res)
 
    MOV ESI, [ESP+4*4+4]       ; ESI = &a
    IMUL ECX, 4                 ; ECX = start*4
 
    ADD ESI, ECX                ; ESI = &a + start*4
    MOV ECX, EDX                ; ECX = EDX  (счетчик)
    MOV EDI, [ESP+4*4+0]        ; EDI = &res
    REP MOVSD                   ; Копирование массива двойных слов
 
 
    MOV EDI, [ESP+4*4+0]        ; EDI = &res
    MOV EBX, 0                  ; EBX = 0  (i)
    loop_sort_arr_outer:
      MOV ECX, 1                ; ECX = 1  (j)
      loop_sort_arr_inner:
        MOV EAX, [EDI+ECX*4-4]  ; EAX = res[j - 1]
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[j - 1] > res[j]), то пропустить обмен
          MOV ESI, [EDI+ECX*4]    ; ESI = res[j]
          MOV [EDI+ECX*4], EAX    ; res[j] = res[j - 1]
          MOV [EDI+ECX*4-4], ESI  ; res[j - 1] = ESI
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        MOV ESI, EDX            ; ESI = size
        SUB ESI, EBX            ; ESI = size - i
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наибольшего элемента, 
                                ; который смещен пузырьком в конец массива res
      loop_sort_arr_inner_end:
      INC EBX                   ; EBX += 1
      CMP EBX, EDX
      JL loop_sort_arr_outer    ; Цикл пока не пройдем по всем элементам массива res
    loop_sort_arr_outer_end:
 
    MOV EAX, [ESP+6*4+8]        ; EAX = &res
 
    POP ESI
    POP EDI
    POP EBX
    RET 2*4
  sort_fastcall endp 


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
      MOV ECX, 1                ; ECX = 1  (j)
      loop_sort_arr_inner:
        MOV EAX, [EDI+ECX*4-4]  ; EAX = res[j - 1]
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[j - 1] > res[j]), то пропустить обмен
          MOV ESI, [EDI+ECX*4]    ; ESI = res[j]
          MOV [EDI+ECX*4], EAX    ; res[j] = res[j - 1]
          MOV [EDI+ECX*4-4], ESI  ; res[j - 1] = ESI
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        MOV ESI, EDX            ; ESI = size
        SUB ESI, EBX            ; ESI = size - i
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наибольшего элемента, 
                                ; который смещен пузырьком в конец массива res
      loop_sort_arr_inner_end:
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
      MOV ECX, 1                ; ECX = 1  (j)
      loop_sort_arr_inner:
        MOV EAX, [EDI+ECX*4-4]  ; EAX = res[j - 1]
        CMP EAX, [EDI+ECX*4]  
        JLE sort_arr_no_swap    ; Если не (res[j - 1] > res[j]), то пропустить обмен
          MOV ESI, [EDI+ECX*4]    ; ESI = res[j]
          MOV [EDI+ECX*4], EAX    ; res[j] = res[j - 1]
          MOV [EDI+ECX*4-4], ESI  ; res[j - 1] = ESI
        sort_arr_no_swap:
        INC ECX                 ; ECX += 1
        MOV ESI, EDX            ; ESI = size
        SUB ESI, EBX            ; ESI = size - i
        CMP ECX, EDX
        JL loop_sort_arr_inner  ; Цикл пока не дойдем до наибольшего элемента, 
                                ; который смещен пузырьком в конец массива res
      loop_sort_arr_inner_end:
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



start:

    push offset array
    push offset result
    push offset 5
    push offset 2
    call sort_stdcall

    ;push offset array
    ;push offset result
    ;push offset 4
    ;push offset 0
    ;call sort_cdecl
    ;add esp, 2*4

    ;push offset array
    ;push offset result
    ;mov edx, 5
    ;mov ecx, 0
    ;call sort_fastcall
    ;add esp, 2*4

    ;push offset array
    ;push offset result
    ;push offset 5
    ;push offset 2
    ;call sort_stdcall_args

    ;push offset array
    ;push offset result
    ;push offset 4
    ;push offset 0
    ;call sort_cdecl_args
    ;add esp, 2*4

    push 7
    push eax
    call print_array


    CALL crt__getch           ; Задержка ввода с клавиатуры
    PUSH 0
    CALL ExitProcess          ; Выход из программы
end start