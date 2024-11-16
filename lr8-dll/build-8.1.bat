@echo off

@REM set var MASM32 path:
set MASM32=d:\projects\masm32
set FILE=lab8.1
set BUILD_FOLDER=build

@REM if build folder does not exist, create it
if not exist %BUILD_FOLDER% mkdir %BUILD_FOLDER%

@REM cd to build folder
cd %BUILD_FOLDER%

@REM remove old exe file
if exist %FILE%.exe del %FILE%.exe

@REM compile
%MASM32%\bin\ml /c /coff /I "%MASM32%\include" ../%FILE%.asm

@REM link
%MASM32%\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:%MASM32%\lib %FILE%.obj

@REM remove obj file
del %FILE%.obj

@REM run
%FILE%.exe

@REM cd back
cd ..

echo.
pause
