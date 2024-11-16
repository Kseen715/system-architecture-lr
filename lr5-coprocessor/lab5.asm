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


abs PROC var:DWORD
    mov EAX, var
    cmp EAX, 0
    jge abs_end
    neg EAX
abs_end:
    ret
    abs ENDP


bubble_sort proc parr:DWORD,cnt:DWORD

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

bubble_sort endp


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

        add ecx, item_size                      ; ecx = array[i+1]
        dec ebx                         ; ebx = n-1
        cmp ebx, 0
        jne prnt                        ; если ebx не равно 0, то переходим к следующему элементу массива
        
        pop edx
        pop ecx
        pop eax
        pop ebx
        RET 8
print_array endp


print_array_8byte PROC ptrr:DWORD, sze:DWORD
    .data
        print_array_8byte_fmt DB "%lld ",0
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
    ; invoke crt_printf, offset main_fmt, val[0]
    ; invoke crt_printf, offset main_fmt, val[4]
    invoke crt_printf, offset print_array_8byte_fmt, val
    pop eax
    add eax, 8
    dec esi
    jnz loopm

    popa
    ret 8
print_array_8byte ENDP

scan_array_8byte PROC ptrr:DWORD, sze:DWORD
    .data
        scan_array_8byte_fmt DB "%lld", 0
        scan_array_8byte_val DQ ?
    .code
    pusha

    mov eax, ptrr
    mov esi, sze
loopm:

    mov ebx, eax
    push eax

    invoke crt_scanf, offset scan_array_8byte_fmt, offset scan_array_8byte_val
    ; invoke crt_printf, offset main_fmt, scan_array_8byte_val
    ; var 4:4
    mov eax, dword ptr scan_array_8byte_val[0]
    mov [ebx], eax
    mov eax, dword ptr scan_array_8byte_val[4]
    mov [ebx+4], eax


    pop eax
    add eax, 8
    dec esi
    jnz loopm

    popa
    ret 8

scan_array_8byte ENDP



func_pow_double proc
        sub ESP, 24                     ; доп.слоты в стеке
                                        ; x^y = 2^(y*log2(x))
        mov DWORD PTR [ESP+0+0],  0 
        mov DWORD PTR [ESP+0+4],  0 
        mov DWORD PTR [ESP+0+8],  0 
        mov DWORD PTR [ESP+0+12], 0 
        mov DWORD PTR [ESP+0+16], 0 
        mov DWORD PTR [ESP+0+20], 0 

        fld QWORD PTR [ESP+28+0]        ; загрузка x в сопроцессор
        fldz                            ; загрузка 0.0 в сопроцессор
        db 0dbh, 0f0h+1                 ; сравнение ST(0), ST(1)
        ja pow_double_x_less_0          ; если x < 0
        jb pow_double_begin             ; если x > 0

        fld QWORD PTR [ESP+28+8]        ; загрузка y в сопроцессор
        fldz                            ; загрузка 0.0 в сопроцессор
        db 0dbh, 0f0h+1                 ; сравнение ST(0), ST(1)
        jne pow_double_end
        fld1                            ; загрузка 1.0 в сопроцессор
        fstp QWORD PTR [ESP+0+8]        ; результат в 2-й доп.слот
        jmp pow_double_end

    pow_double_x_less_0:                ; x < 0
        mov DWORD PTR [ESP+0+16], 1     ; 3-й доп.слот (4 из 8 байта) = 1
        fld QWORD PTR [ESP+28+0]        ; загрузка x в сопроцессор
        fabs                            ; ST(0) = |x|
        fstp QWORD PTR [ESP+28+0]       ; результат на место арг. x


    pow_double_begin:
        fld QWORD PTR [ESP+28+8]        ; ST(0) = y
        fld QWORD PTR [ESP+28+0]        ; ST(0) = x, ST(1) = y
        fyl2x                           ; ST(0) = y*log2(x)
        fstp QWORD PTR [ESP+0+8]        ; [ESP+8] = y*log2(x)

        fld QWORD PTR [ESP+0+8]         ; ST(0) = y*log2(x)
        fld1                            ; ST(0) = 1.0, ST(1) = y*log2(x)
        fscale                          ; ST(0) = 2^(целое)[y*log2(x)]
        fstp QWORD PTR [ESP+0+0]        ; [ESP+0] = 2^(целое)[y*log2(x)]

        fld1                            ; ST(0) = 1.0, ST(1) = 2^(целое)[y*log2(x)]
        fld QWORD PTR [ESP+0+8]         ; ST(0) = y*log2(x), ST(1) = 1.0, ST(2) = 2^(целое)[y*log2(x)]
        fprem                           ; ST(0) = (дробное)[y*log2(x)], ST(1) = 2^(целое)[y*log2(x)]

        f2xm1                           ; ST(0) = 2^(дробное)[y*log2(x)] - 1, ST(1) = 2^(целое)[y*log2(x)]
        fld1                            ; ST(0) = 1.0, ST(1) = 2^(дробное)[y*log2(x)] - 1, ST(2) = 2^(целое)[y*log2(x)]
        fadd                            ; ST(0) = 2^(дробное)[y*log2(x)], ST(1) = 2^(целое)[y*log2(x)]
        fmul QWORD PTR [ESP+0+0]        ; ST(0) = 2^(y*log2(x))
        fstp QWORD PTR [ESP+0+8]        ; [ESP+8] = 2^(y*log2(x))

        cmp DWORD PTR [ESP+0+16], 1
        jne pow_double_end              ; если x > 0, иначе:

        mov DWORD PTR [ESP+0+20], 2     ; [ESP+20] = 2
        fild DWORD PTR [ESP+0+20]       ; ST(0) = 2, ST(1) = 2^(y*log2(x))
        fld QWORD PTR [ESP+28+8]        ; ST(0) = y, ST(1) = 2, ST(2) = 2^(y*log2(x))
        fprem                           ; ST(0) = (дробное)[y/2]
        fldz                            ; загрузка 0.0 в сопроцессор
        db 0dbh, 0f0h+1                 ; сравнение ST(0), ST(1)
        je pow_double_end               ; если y == 0

        fld QWORD PTR [ESP+0+8]         ; загрузка 2^(y*log2(x)) в сопроцессор
        fchs
        fstp QWORD PTR [ESP+0+8]        ; результат на место 2-й доп.слот

    pow_double_end:
        mov EAX, DWORD PTR [ESP+0+8]
        mov EDX, DWORD PTR [ESP+0+12]  
        mov DWORD PTR [ESP+28+8], EAX
        mov DWORD PTR [ESP+28+12], EDX

        ; Очищаем сопроцессор
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]
        fstp QWORD PTR [ESP+28+0]

        ADD ESP, 24
        ret 8
func_pow_double endp


; ======================================
; void z_output(double *a, int32_t n)
; ======================================
z_output proc
.data
    __z_output__fmt DB "%f ", 0
.code
    mov EBX, DWORD PTR [ESP + 4] ; *a
    mov ESI, DWORD PTR [ESP + 8] ; n

cycle:
    add EBX, 4
    mov EBP, DWORD PTR [EBX]
    push EBP
    sub EBX, 4
    mov EBP, DWORD PTR [EBX]
    push EBP
    push offset __z_output__fmt
    call crt_printf
    add esp, 4*3
    add EBX, 8
    dec ESI
    cmp ESI, 0
    jg cycle
    ret 12
z_output endp

; ======================================
; double z_sum_cubes(double *a, int32_t n)
; ======================================
z_sum_cubes proc
.data
    __z_sum_cubes__pow_fmt_f DB "%f", 10, 13, 0
    __z_sum_cubes__pow_fmt_f2 DB "%016llX", 10, 13, 0
    summ DQ 0.0
.code
    mov EBX, DWORD PTR [ESP + 4] ; *a
    mov ESI, DWORD PTR [ESP + 8] ; n

    sub ESP, 32
    
    mov DWORD PTR [ESP+24], 0   ; [ESP+24] = 0
    mov DWORD PTR [ESP+28], 0
cycle:
    add EBX, 4
    mov EBP, DWORD PTR [EBX]
    mov DWORD PTR [ESP + 4], EBP
    sub EBX, 4
    mov EBP, DWORD PTR [EBX]
    mov DWORD PTR [ESP + 0], EBP    ; [ESP+0] = a[n]
    
    fld QWORD PTR [ESP + 0]     ; [ESP+0]=a[n]
    fstp QWORD PTR [ESP + 32]   ; [ESP+32]=a[n]
    
    mov DWORD PTR [ESP + 8], 3  ; [ESP+8]=3
    fild DWORD PTR [ESP + 8]    ; [ESP+8]=3f
    fstp QWORD PTR [ESP + 8]    ; [ESP+8]=3f

    fld QWORD PTR [ESP + 32]    ; [ESP+0]=a[n]
    fstp QWORD PTR [ESP + 0]    ; [ESP+0]=a[n]
    
    call func_pow_double        ; [ESP+0]=a[n]^3
    
    fld QWORD PTR [ESP + 0]     ; [ESP+0]=a[n]^3
    fld summ
    fadd                        ; [ESP+0]=a[n]^3+sum
    fst summ                   ; summ=a[n]^3+sum
    fst QWORD PTR [ESP + 24]     ; [ESP+0]=a[n]^3


    add EBX, 8
    dec ESI
    cmp ESI, 0
    jg cycle

    fld QWORD PTR [ESP + 24]
    fstp QWORD PTR [ESP + 0]
    push offset __z_sum_cubes__pow_fmt_f
    call crt_printf
    add esp, 4
    ; push offset __z_sum_cubes__pow_fmt_f2
    ; call crt_printf
    ; add esp, 4

    add esp, 32

    ret 12
z_sum_cubes endp


start:
.data
    x DQ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0
    y DQ 2.0, 32.0, 2.0, 2.6, 5.0, 0.0, 2.6, -1.0, -2.0, 2234.6
    q DQ ?
    sum DQ 0.0
    pow_fmt_f1 DB "%f ^ %f =  ", 0
    pow_fmt_f DB "%f", 10, 13, 0
    row_out DB "n = %d; S = %f", 10, 13, 0
.code

    mov EDI, 0
loop_1:
    mov EAX, 0

    push dword ptr y[EDI + 4]    
    push dword ptr y[EDI]
    push dword ptr x[EDI + 4]
    push dword ptr x[EDI]
    push offset pow_fmt_f1
    call crt_printf
    add esp, 5*4
    
    push dword ptr y[EDI + 4]    
    push dword ptr y[EDI]
    push dword ptr x[EDI + 4]
    push dword ptr x[EDI]

    fld y[EDI]                  ; загрузка double в сопроцессор
    sub ESP, 8                  ; выделение памяти в стеке под double
    fstp QWORD PTR [ESP]        ; вытолкнуть double в стек

    fld x[EDI]                  ; загрузка double в сопроцессор
    sub ESP, 8                  ; выделение памяти в стеке под double
    fstp QWORD PTR [ESP]        ; вытолкнуть double в стек
    call func_pow_double

    push offset pow_fmt_f
    call crt_printf
    add esp, 4
    
    add EDI, 8
    cmp EDI, 80
    jne loop_1

    nline


    mov EBP, 0 ; !n
loop_2:
    inc EBP
    sub ESP, 32 ; Локальные переменные
    mov DWORD PTR [ESP + 0 + 0], 0 ; [ESP+0]
    mov DWORD PTR [ESP + 0 + 4], 0
    mov DWORD PTR [ESP + 0 + 8], 0 ; [ESP+8]
    mov DWORD PTR [ESP + 0 + 12], 0
    mov DWORD PTR [ESP + 0 + 16], 0 ; [ESP+16]
    mov DWORD PTR [ESP + 0 + 20], 0
    mov DWORD PTR [ESP + 0 + 24], 0 ; [ESP+24]
    mov DWORD PTR [ESP + 0 + 28], 0
    mov DWORD PTR [ESP + 0 + 0], 1 ; [ESP+0] = 1
    fld QWORD PTR [ESP + 0 + 0] ; ST(0) = 1f
    mov DWORD PTR [ESP + 0 + 0], 3 ; [ESP+0] = 3
    fld QWORD PTR [ESP + 0 + 0] ; ST(0) = 3f, ST(1) = 1f
    fdiv
    fstp QWORD PTR [ESP + 0 + 8] ; [ESP+8] = 1/3f
    mov DWORD PTR [ESP + 0 + 0], 5 ; [ESP+0] = 5
    fld QWORD PTR [ESP + 0 + 0] ; ST(0) = 5f
    mov DWORD PTR [ESP + 0 + 0], 1 ; [ESP+0] = 1
    fld QWORD PTR [ESP + 0 + 0] ; ST(0) = 1f, ST(1) = 5f
    fdiv
    fstp QWORD PTR [ESP + 0 + 0] ; [ESP+0] = 5f
    call func_pow_double ; [ESP+0] = pow(5, 1/3)
    mov EBX, DWORD PTR [ESP + 0 + 0] ; EBX = pow(5, 1/3)[0]
    mov EDI, DWORD PTR [ESP + 0 + 0 + 4] ; EDI = pow(5, 1/3)[4]
    mov DWORD PTR [ESP + 0 + 0], 0
    mov DWORD PTR [ESP + 0 + 4], 0
    mov DWORD PTR [ESP + 0 + 8], 0
    mov DWORD PTR [ESP + 0 + 12], 0
    mov DWORD PTR [ESP + 0 + 0], 1 ; [ESP+0] = 1
    fld QWORD PTR [ESP + 0 + 0] ; [ESP+0] = 1f
    mov DWORD PTR [ESP + 0 + 8], 3 ; [ESP+0] = 3
    fld QWORD PTR [ESP + 0 + 8] ; [ESP+0] = 3f, [ESP+8] = 1f
    fdiv
    fst QWORD PTR [ESP + 0 + 8] ; [ESP+8] = 1/3f
    mov DWORD PTR [ESP + 0 + 0], 7 ; [ESP+0] = 7
    fild QWORD PTR [ESP + 0 + 0] ; [ESP+0] = 7f
    mov DWORD PTR [ESP + 0 + 0], 1 ; [ESP+0] = 1
    fild QWORD PTR [ESP + 0 + 0] ; [ESP+0] = 1f, [ESP+8] = 7f
    fmul
    fst QWORD PTR [ESP + 0 + 0] ; [ESP+0] = 7f
    call func_pow_double ; [ESP+0] = pow(7, 1/3)
    mov DWORD PTR [ESP + 0 + 8], EBX ; [ESP+8] = pow(5, 1/3)[0]
    mov DWORD PTR [ESP + 0 + 8 + 4], EDI ; [ESP+12] = pow(5, 1/3)[4]
    ; [ESP+8] = pow(5, 1/3)
    fld QWORD PTR [ESP + 0 + 0] ; [ESP+0] = pow(7, 1/3)
    fld QWORD PTR [ESP + 0 + 8] ; [ESP+8] = pow(5, 1/3)
    fadd
    fst QWORD PTR [ESP + 0 + 0] ; [ESP+0] = pow(5,1/3)+pow(7,1/3)
    ; ![ESP+0] = q = const
    mov DWORD PTR [ESP + 0 + 8], EBP ; n
    fild DWORD PTR [ESP + 0 + 8] ; [ESP+8] = nf
    mov DWORD PTR [ESP + 0 + 16], 1 ; [ESP+16] = 1
    fild DWORD PTR [ESP + 0 + 16] ; [ESP+16] = 1f
    fmul
    fst QWORD PTR [ESP + 0 + 8] ; [ESP+8] = 1f
    call func_pow_double ; ![ESP+0] = pow(q, n)
    mov EAX, DWORD PTR [ESP + 0 + 0]
    mov ESI, DWORD PTR [ESP + 0 + 0 + 4]
    mov DWORD PTR [ESP + 0 + 8], 3 ; 3
    fild DWORD PTR [ESP + 0 + 8] ; [ESP+8] = 3f
    fst QWORD PTR [ESP + 0 + 8]
    mov DWORD PTR [ESP + 0 + 0], EBP ; n
    fild DWORD PTR [ESP + 0 + 0] ; [ESP+8] = nf
    fst QWORD PTR [ESP + 0 + 0]
    call func_pow_double ; [ESP+0] = pow(n, 3)
    mov EBX, DWORD PTR [ESP + 0 + 0] ; EBX = pow(n, 3)[0]
    mov EDI, DWORD PTR [ESP + 0 + 0 + 4] ; EDI = pow(n, 3)[4]
    mov DWORD PTR [ESP + 0 + 8], 2 ; 2
    fild DWORD PTR [ESP + 0 + 8] ; [ESP+8] = 2f
    fst QWORD PTR [ESP + 0 + 8]
    mov DWORD PTR [ESP + 0 + 0], EBP ; n
    fild DWORD PTR [ESP + 0 + 0] ; [ESP+8] = nf
    fst QWORD PTR [ESP + 0 + 0]
    call func_pow_double ; [ESP+0] = pow(n, 2)
    fld QWORD PTR [ESP + 0 + 0]
    fcos
    fst QWORD PTR [ESP + 0 + 0] ; [ESP+0] = cos(pow(n, 2))
    mov DWORD PTR [ESP + 0 + 8], EBX ; [ESP+8] = pow(n, 3)[0]
    mov DWORD PTR [ESP + 0 + 8 + 4], EDI ; [ESP+12] = pow(n, 3)[4]
    ; [ESP+8] = pow(n, 3)
    fld QWORD PTR [ESP + 0 + 0]
    fld QWORD PTR [ESP + 0 + 8]
    fmul
    fst QWORD PTR [ESP + 0 + 8] ; ![ESP+8] = pow(n,3)*cos(pow(n,2))
    mov DWORD PTR [ESP + 0 + 0], EAX
    mov DWORD PTR [ESP + 0 + 0 + 4], ESI
    fld QWORD PTR [ESP + 0 + 8]
    fld QWORD PTR [ESP + 0 + 0]
    fdiv
    fst QWORD PTR [ESP + 0 + 0]

    fld QWORD PTR [ESP + 0 + 0]
    fld sum
    fadd
    fst sum
    fstp QWORD PTR [ESP + 0]
    

    push EBP
    push offset row_out
    call crt_printf
    add esp, 4
    fstp QWORD PTR [ESP+28+0]
    cmp EBP, 50
    jne loop_2
    add ESP, 32 ; Чистим стек от переменных


    nline

    push 10
    push offset x
    call z_output

    nline
    nline

    push 10
    push offset x
    call z_sum_cubes
    

    invoke ExitProcess, 0                   ; Выход из программы
end start