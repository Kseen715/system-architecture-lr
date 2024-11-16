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

nline MACRO
    LOCAL nline_fmt
    .data
        nline_fmt DB 13, 10, 0
    .code
        invoke crt_printf, offset nline_fmt
        add esp, 4
    ENDM

.data
    main_fmt DB "DBG: 0x%016llX", 13, 10, 0
    main_fmt_8 DB "DBG: 0x%08lX", 13, 10, 0
    main_fmt_f DB "DBG: %f", 13, 10, 0
.code

abs_32i PROC var:DWORD
    mov EAX, var
    cmp EAX, 0
    jge abs_end
    neg EAX
abs_end:
    ret
abs_32i ENDP

bubble_sort_32 proc parr:DWORD, cnt:DWORD
    push ebx
    push esi
    sub cnt, 1                  ; set count to 1 less than member count
lbl0:
    mov esi, parr               ; load array address into ESI
    xor edx, edx                ; zero the "changed" flag
    mov ebx, cnt                ; set the loop counter to member count
lbl1:
    mov eax, [esi]              ; load first pair of array numbers into registers
    mov ecx, [esi+4]
    cmp eax, ecx                ; compare which is higher
    jle lbl2                     
    mov [esi], ecx              ; swap if 1st number is higher
    mov [esi+4], eax
    mov edx, 1                  ; set the changed flag if any swap is performed
lbl2:
    add esi, 4                  ; step up one to compare next adjoining pair
    sub ebx, 1                  ; decrement the counter
    jnz lbl1
    test edx, edx               ; test if the changed flag is set.
    jz lbl3                     ; break out of the loop if no swap occurred
    sub cnt, 1                  ; decrement the upper bound for next pass
    jmp lbl0                    ; loop back for next pass
lbl3:
    pop esi
    pop ebx
    ret
bubble_sort_32 endp

print_array proc array_ptr:dword, array_size:dword, item_size:dword
.data
    print_array_fmt DB "%d ",0   
.code
    push ebx
    push eax
    push ecx
    push edx
    mov ecx, array_ptr
    mov ebx, array_size               
prnt:
    mov eax, item_size
    cmp eax, 1
    je switch1
    cmp eax, 2
    je switch2
    cmp eax, 4
    je switch4
switch1:
    mov eax, 0
    mov al, byte ptr [ecx]                  ; ecx = array[i]
    jmp switch_end
switch2:
    mov eax, 0
    mov ax, word ptr [ecx]                  ; ecx = array[i]
    jmp switch_end
switch4:
    mov eax, 0
    mov eax, dword ptr [ecx]                  ; ecx = array[i]
    jmp switch_end
switch_end:
    push eax
    push ecx
    push eax
    push offset print_array_fmt
    call crt_printf                 ; Вывод результата на экран
    add esp, 2*4
    pop ecx
    pop eax
    add ecx, item_size              ; ecx = array[i+1]
    dec ebx                         ; ebx = n-1
    cmp ebx, 0
    jne prnt                        ; если ebx не равно 0, то переходим
                                    ; к следующему элементу массива
    pop edx
    pop ecx
    pop eax
    pop ebx
    RET 8
print_array endp

print_array_64i PROC ptrr:DWORD, sze:DWORD
.data
    print_array_64i_fmt DB "%lld ",0
    val DQ ?
.code
    pusha
    mov eax, ptrr
    mov esi, sze
loopm:
    mov ebx, eax
    push eax

    mov eax, [ebx]
    mov dword ptr val[0], eax
    add ebx, 4
    mov eax, [ebx]
    mov dword ptr val[4], eax
    invoke crt_printf, offset print_array_64i_fmt, val
    pop eax
    add eax, 8
    dec esi
    jnz loopm
    popa
    ret 8
print_array_64i ENDP

scan_array_64i PROC ptrr:DWORD, sze:DWORD
.data
    scan_array_64i_fmt DB "%lld", 0
    scan_array_64i_val DQ ?
.code
    pusha
    mov eax, ptrr
    mov esi, sze
loopm:
    mov ebx, eax
    push eax
    invoke crt_scanf, offset scan_array_64i_fmt, offset scan_array_64i_val
    mov eax, dword ptr scan_array_64i_val[0]
    mov [ebx], eax
    mov eax, dword ptr scan_array_64i_val[4]
    mov [ebx+4], eax
    pop eax
    add eax, 8
    dec esi
    jnz loopm
    popa
    ret 8
scan_array_64i ENDP


.data
   format_number db "%05X", 0
   format_new_line db 13, 10, 0
.code


; ==============================================================================
; bool check_sum_oct_eq4(uint32_t a)
; Проверка числа на соответствие условию
; ==============================================================================
check_sum_oct_eq4 proc 
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH EDI

    MOV EAX, [ESP+5*4]      ; Взять из стека аргумент 18-битное число (32)
    MOV EDI, 6              ; Количество итераций (18/3 разрядов числа)
    XOR EDX, EDX            ; Сумма цифр
loop_check:
    MOV EBX, EAX            ; EBX = EAX
    AND EBX, 0111b          ; Оставить только младшие 3 бита, остальные обнулить
    ADD EDX, EBX            ; Сложить сумму цифр и младшие биты числа
    JMP continue_check      ; Если EBX == 0F, то продолжить проверку              

increment_counter:
    INC EDX                 ; Увеличить счетчик
    JMP continue_check

continue_check:
    SHR EAX, 3              ; Сдвиг на 3 бит вправо
    dec EDI                 ; для выполнения цикла, содержащего 18 итераций
    cmp EDI, 0
    jne loop_check

    CMP EDX, 3              ; Если сумма цифр равна 4, то возвращаем 1
    je ret1                 
    JNE ret0


ret0:
    MOV EAX, 0
    JMP end_check

ret1:
    MOV EAX, 1
    JMP end_check

end_check:                  ; вернуть стек в исходное состояние
    POP EDI
    POP EDX
    POP ECX
    POP EBX 
    RET 4 
check_sum_oct_eq4 endp 

; ==============================================================================
; void multiplication (void* a, uint32_t n, void* res) 
; Умножение 35-байтного числа на 2^n, записывая результат в 70-байтное число res
; ==============================================================================
multiplication proc
    PUSH EAX 
    PUSH EBX
    PUSH ECX
    PUSH EDX

    MOV EBX, 70               ; EBX = 70  (размер нового массива)

                    ; (!) Заполним новый массив res нулями
    MOV ECX, 0                ; ECX = 0
loop_mult_zero:
    MOV EAX, [ESP+5*4+8]    ; EAX = &res
    ADD EAX, ECX            ; EAX = &res + ECX
    MOV BYTE PTR [EAX], 0   ; *(&res + ECX) = 0

    INC ECX                 ; ECX += 1
    CMP ECX, EBX
    jl loop_mult_zero  ; Цикл пока ECX < EBX 

                    ; (!) Заполним новый массив res значениями из a, 
                    ; сдвинутый на n / 8 байтов влево, сдвинутый побитово на n % 8 влево
    MOV EAX, [ESP+5*4+4]      ; EAX = n
    CDQ
    MOV EBX, 8 
    IDIV EBX                   ; EAX = n / 8,  EDX = n % 8
    MOV CL, DL

    MOV EDX, 35-1
    ADD EDX, [ESP+5*4+0]      ; EDX - &a+35-1
    MOV EBX, 70-1
    SUB EBX, EAX              ; EBX = 70-1-EAX
    ADD EBX, [ESP+5*4+8]      ; EBX - &res+70-1-(n/8)

    MOV AL, 0                 ; AL = 0
loop_mult:
    MOV AH, BYTE PTR [EDX]  ; AH = a[i]
    SHL AX, CL              ; AH:AL = a[i] <<= CL 
    MOV BYTE PTR [EBX], AH  ; res[i] = AH

    MOV AL, BYTE PTR [EDX]  ; AL = a[i]
    DEC EDX                 ; EDX -= 1  (смещаем указатели на массивы влево, к их началу)
    DEC EBX                 ; EBX -= 1
    CMP EDX, [ESP+5*4+0]
    jge loop_mult            ; Цикл пока EDX != &a+0  (пока указатель на масс. а не дойдет до начала)

    MOV AH, 0                 ; AH = 0
    SHL AX, CL                ; AX = 00:CL <<= CL 
    MOV BYTE PTR [EBX], AH    ; res[i] = AH

    POP EDX
    POP ECX
    POP EBX 
    POP EAX
    RET 12 
multiplication endp 


; ==============================================================================
; void print_hex (void* a, uint32_t n);
; Вывод числа a в 16-чном виде размера n байт
; ==============================================================================
print_hex_memory proc
.data
    __print_hex_memory__start_hex_fmt db "0x:" , 0
    __print_hex_memory__single_hex_fmt db "%02X:" , 0
    __print_hex_memory__single_hex_last_fmt db "%02X" , 0
    __print_hex_memory__new_line_fmt db 13, 10, 0
.code
    PUSH EAX
    PUSH ECX
    PUSH EDX
    PUSH EBX

    invoke crt_printf, offset __print_hex_memory__start_hex_fmt

    XOR EDX, EDX
    MOV ECX, 0
loop_print_hex_memory:
    MOV EAX, DWORD PTR [ESP+5*4]  ; EAX = &a
    MOV DL, [EAX+ECX]             ; EAX = a[EAX]

    PUSH ECX  
    PUSH EDX  ; Выложить байт числа на стек
    PUSH offset __print_hex_memory__single_hex_fmt
    CALL crt_printf
    ADD ESP, 8
    POP ECX

    INC ECX               ; ECX += 1
    MOV EBX, [ESP+5*4+4]
    DEC EBX
    CMP ECX, EBX  ; сравнить ECX и n-1
    JB loop_print_hex_memory    ; Цикл пока ECX < n

    MOV EAX, DWORD PTR [ESP+5*4]  ; EAX = &a
    MOV DL, [EAX+ECX]             ; EAX = a[EAX]

    PUSH ECX  
    PUSH EDX  ; Выложить байт числа на стек
    PUSH offset __print_hex_memory__single_hex_last_fmt
    CALL crt_printf
    ADD ESP, 8
    POP ECX
    
    PUSH offset __print_hex_memory__new_line_fmt 
    CALL crt_printf ; вывод перехода к новой строке
    ADD ESP, 4

    POP EBX
    POP EDX
    POP ECX
    POP EAX
    RET 8
print_hex_memory endp 


start:
.data
    x DB 35 DUP (0FAh)
    res DB 70 DUP (?)
    __main__18bit_number_fmt db "%u:", 9, "0o%06o", 13, 10, 0
.code

    mov EDI, 0
    mov EBX, 0 ; Счетчик 
main_loop:
    push EDI
    call check_sum_oct_eq4

    cmp EAX, 1
    jne skip_print
    
    inc EBX
    push EDI
    push EBX
    push offset __main__18bit_number_fmt
    call crt_printf
    add esp, 8

skip_print:

    inc EDI
    cmp EDI, 111111111111111111b
    JL main_loop


    nline


    push offset res
    push 2
    push offset x
    call multiplication


    push 70
    push offset res
    call print_hex_memory
    

    invoke ExitProcess, 0                   ; Выход из программы
end start