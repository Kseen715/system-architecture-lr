@REM set var MASM32 path:
set MASM32=d:\projects\masm32
set FILE=lab1

del %FILE%.exe
%MASM32%\bin\ml /c /coff /I "%MASM32%\include" %FILE%.asm
%MASM32%\bin\ml /c /coff /I "%MASM32%\include" %FILE%.asm
%MASM32%\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:%MASM32%\lib %FILE%.obj
del %FILE%.obj
%FILE%.exe
pause
