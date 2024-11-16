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

 ; --- Сегмент кода --- 
 .code
 start:
	MOV AX, 120h 
	CMP DI, AX 
	SUB [EBP*8], AX 
	ADC CX, [ESI+101000101b] 
	OR BYTE PTR [EBP+EDI+8], 9
	MOV ECX,EAX
	MOV EBX,18

	OR  AX, DX 
	MOV SI, 14789h 
	ADD AL, [ESI+8] 
	CMP BYTE PTR [EBP+4], 'j' 
	MOV AX, [EBX+EDI+17h]
	MOV EBX, 64h
	MOV EAX, 78h

  	push NULL
  	call ExitProcess ; Выход из программы 
 end start
