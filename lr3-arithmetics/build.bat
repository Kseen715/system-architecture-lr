@echo off

set asm_name="lab3"

del %asm_name%.exe && d:\masm32\bin\ml /c /coff /I "d:\masm32" %asm_name%.asm && d:\masm32\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:d:\masm32\lib %asm_name%.obj && %asm_name%.exe && del %asm_name%.obj pause
