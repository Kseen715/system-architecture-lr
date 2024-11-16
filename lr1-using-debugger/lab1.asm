.386 ; Тип процессора 
 .model flat, stdcall ; Модель памяти и стиль вызова подпрограмм 
 option casemap: none ; Чувствительность к регистру 
 
 ; --- Подключение файлов с кодом, макросами, константами,  
 ; прототипами функций и т.д. 
 include windows.inc 
 include kernel32.inc 
 include user32.inc 
 include msvcrt.inc 
 
 ; --- Подключаемые библиотеки --- 
 includelib user32.lib 
 includelib kernel32.lib 
 includelib msvcrt.lib 
 
 ; --- Сегмент данных --- 
 .data  
    strd DB "Division", 0 
    a DD 10500000h, 1200h 
    b DD 10000 
    m DD ? 
    mas DW 8 DUP(1) 
    ten DT 30000, -30000 
    f DQ 1, 1.0, -1.0 
    h DF -3, -2, -1, 0, 1, 2, 3, 4, 40000h, 40000 
 
 ; --- Сегмент кода --- 
 .code 
 start: 
    MOV EDX, a[4]   ; EDX = a[4] = 0x1200 
    MOV EAX, a[0]   ; EAX = a[0] = 0x10500000 
    DIV b           ; EAX = EAX / b 
    MOV m, EDX      ; m = 0x120010500000 mod b 
 
    ADD EAX, m      ; EAX = EAX + m 
    IMUL EAX, 3     ; EAX = EAX * 3 
 
    push NULL 
    call ExitProcess ; Выход из программы 
 end start