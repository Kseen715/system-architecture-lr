@echo off
setlocal

REM Настройки:
set input_asm_file=l8_dll
set masm_path=d:\projects\masm32
set include_path=%masm_path%\include
set build_path=build
set output_path=output

if not exist %build_path% mkdir %build_path%

cd %build_path%

if not exist %output_path% mkdir %output_path%

REM Компиляция
echo Compiling %input_asm_file%.asm
%masm_path%\bin\ml /c /coff /I "%include_path%" ../%input_asm_file%.asm
if errorlevel 1 (
    echo Error at compile
    exit /b 1
)

REM Линковка
echo Linking %input_asm_file%.dll
%masm_path%\bin\link /SUBSYSTEM:WINDOWS /DLL /DEF:../%input_asm_file%.def %input_asm_file%.obj
if errorlevel 1 (
    echo Error at linking
    exit /b 1
)

REM Удаление лишних файлов
if exist %input_asm_file%.obj (
    echo Deleting %input_asm_file%.obj
    del %input_asm_file%.obj
)

REM delete old dll and lib files into %output_path%
if exist %output_path%\%input_asm_file%.dll (
    echo Deleting %output_path%\%input_asm_file%.dll
    del %output_path%\%input_asm_file%.dll
)

if exist %output_path%\%input_asm_file%.lib (
    echo Deleting %output_path%\%input_asm_file%.lib
    del %output_path%\%input_asm_file%.lib
)

if exist %output_path%\%input_asm_file%.exp (
    echo Deleting %output_path%\%input_asm_file%.exp
    del %output_path%\%input_asm_file%.exp
)

if exist %input_asm_file%.dll (
    echo Moving %input_asm_file%.dll to %output_path%
    move %input_asm_file%.dll %output_path%
)

if exist %input_asm_file%.lib (
    echo Moving %input_asm_file%.lib to %output_path%
    move %input_asm_file%.lib %output_path%
)

if exist %input_asm_file%.exp (
    echo Moving %input_asm_file%.exp to %output_path%
    move %input_asm_file%.exp %output_path%
)

if exist ..\%input_asm_file%.def (
    echo Copying ../%input_asm_file%.def to %output_path%
    copy ..\%input_asm_file%.def %output_path%
)



endlocal