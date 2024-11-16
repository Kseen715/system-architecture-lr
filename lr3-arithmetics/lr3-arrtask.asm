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
    
   x dw ?
   y dw ?
   z dw ?

   fmt db "%hd", 0
   fmt db "%hd", 0
   fmt db "%hd", 0

   push offset x
   push offset fmt
   call crt_scanf
   add esp, 2*4

   push offset y
   push offset fmt
   call crt_scanf
   add esp, 2*4

   push offset z
   push offset fmt
   call crt_scanf
   add esp, 2*4 
   
   divisor dd 2401
   
   format db 10, "(", "%d", "+", "10", ")", "*", "(", "%d", "-", "5", ")", "*", "(", "%d", "-", "%d", "/", "3", ")", "-", "7", "^", "4", "=", "%d", 10, 0

.code
start:

    ; Помещаем данные в регистр и складываем с числом 10
    MOVSX EBX, x      ; EBX = x
    ADD EBX, 10       ; EBX = x + 10
    
    ; Помещаем данные в регистр и вычитаем число 5
    MOVSX EDI, y      ; EDI = y
    SUB EDI, 5        ; EDI = y - 5
    
    ; Помещаем данные в регистр и (z - z / 3)
    MOVSX EAX, z      ; EAX = z
    MOV EBP, EAX      ; EBP = z
    MOV ESI, 3        ; ESI = 3
    CDQ               ; Расширение перед делением до двойного слова
    IDIV ESI          ; EAX - результат, EDX - остаток, EAX = z / 3
    SUB EBP, EAX      ; EBP = z - z / 3 

    ; Вычисляем произведение (x+10) и (y-5) 
    IMUL EBX, EDI     ; EBX = (x + 10) * (y - 5)

    ; Вычисляем поизведение (x+10), (y-5) и (z-z/3) 
    IMUL EBX, EBP     ; EBX = (x + 10) * (y - 5) * (z - z / 3)

    MOV EAX, EBX      ; EAX = EBX

    ; Отнимаем число 7^4 от полученного произведения и получаем результат
    SUB EAX, divisor  ; EAX = (x + 10) * (y - 5) * (z - z / 3) - 7^4

    MOVSX EBX, x
    MOVSX EDI, y
    MOVSX EBX, z

    push EAX ;=
    push EBX ;z
    push EBX ;z
    push EDI ;y
    push EBX ;x

    push offset format
    call crt_printf
    add esp, 6*4

    push 0
    call ExitProcess   ; Выход из программы

end start