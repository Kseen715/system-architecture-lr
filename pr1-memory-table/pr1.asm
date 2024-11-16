 .386 ; ��� ����������
 .model flat, stdcall ; ������ ������ � ����� ������ �����������
 option casemap: none ; ���������������� � ��������

 ; --- ����������� ������ � �����, ���������, �����������, 
 ; ����������� ������� � �.�.
 include windows.inc
 include kernel32.inc
 include user32.inc
 include msvcrt.inc

 ; --- ������������ ���������� ---
 includelib user32.lib
 includelib kernel32.lib
 includelib msvcrt.lib

 ; --- ������� ������ ---
 .data
	num1 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    num1_s db 0 ; для красивого вывода по 16
    num2 db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    num2_s db 0 ; для красивого вывода по 16
    res db 16 DUP(0)

	loop_row DB 16
	format DB "%p", 9, 16 DUP ("%02x "), 13, 10, 0
 ; --- ������� ���� ---
 .code
 start:
    mov EAX, dword ptr num1[0]
    add EAX, dword ptr num2[0]
    mov dword ptr res[0], EAX

    mov EAX, dword ptr num1[4]
    adc EAX, dword ptr num2[4]
    mov dword ptr res[4], EAX    

    mov EAX, dword ptr num1[8]
    adc EAX, dword ptr num2[8]
    mov dword ptr res[8], EAX

    mov EAX, dword ptr num1[12]
    adc EAX, dword ptr num2[12]
    mov dword ptr res[12], EAX
	
	mov ESI, offset num1
	mov EDI, 3
	mov EBX, offset num1 ; EBX - addres for left column
	mov EBP, 15 ; offset
loop2:
	mov ECX, 16
loop1: 
	mov EAX, 0 ; EAX - data of byte
	mov AL, [ESI+EBP]


	push EAX
	dec EBP

	; add ESI, 1
	dec ECX
	jnz loop1 

	add EBP, 32

	push EBX
	push offset format
	call crt_printf

	; mov EAX, offset strd
	add EBX, 16

	; inc EDI
	dec EDI
	jnz loop2

  	push NULL
  	call ExitProcess ; ����� �� ���������
 end start
