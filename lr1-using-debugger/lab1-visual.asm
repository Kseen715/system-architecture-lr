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
	strd DB "Division", 0
	a DD 10500000h, 1200h
	b DD 10000
	m DD ?
	mas DW 8 DUP(1)
	ten DT 30000, -30000
	f DQ 1, 1.0, -1.0
	h DF -3, -2, -1, 0, 1, 2, 3, 4, 40000h, 40000

	format DB 8 DUP ("%s", 9, "%p", 9 , "%p", 9, "%d", 13, 10), 0
	header DB "var", 9, "addr", 9,  9, "end", 9, 9, "size", 13, 10,
		"---------------------------------------------------------------------", 
		13, 10, 0
		
	arg1_name DB "strd", 0
	arg2_name DB "a", 0
	arg3_name DB "b", 0
	arg4_name DB "m", 0
	arg5_name DB "mas", 0
	arg6_name DB "ten", 0
	arg7_name DB "f", 0
	arg8_name DB "h", 0
	null_name DB " ", 0

	buffer DB 1000 DUP (?)

 ; --- ������� ���� ---
 .code
 start:
	push offset header
	push offset buffer
	call crt_sprintf
	add esp, 3*4

	push (offset format) - offset h
	push ((offset format) - 1)
	push offset h
	push offset arg8_name

	push (offset h) - offset f
	push ((offset h) - 1)
	push offset f
	push offset arg7_name

	push (offset f) - offset ten
	push (offset f - 1)
	push offset ten
	push offset arg6_name

	push (offset ten) - offset mas
	push ((offset ten) - 1)
	push offset mas
	push offset arg5_name

	push (offset mas) - offset m
	push ((offset mas) - 1)
	push offset m
	push offset arg4_name

	push (offset m) - offset b
	push ((offset m) - 1)
	push offset b
	push offset arg3_name

	push (offset b) - offset a
	push ((offset b) - 1)
	push offset a
	push offset arg2_name

	push (offset a) - offset strd 
	push ((offset a) - 1)
	push offset strd
	push offset arg1_name

	push offset format
	push offset buffer[92]
	call crt_sprintf
	add esp, 31*4


	push NULL
	push NULL
	push offset buffer
	push NULL
	call MessageBoxA
	add esp, 5*4


  	push NULL
  	call ExitProcess ; ����� �� ���������
 end start
