# Настройки:
$input_asm_file = 'l8_dll'  # Имя .asm файла
$masm_path = 'd:\masm32'    # Путь к MASM32

# Компиляция и линковка
(Invoke-Expression(${masm_path} + '\bin\ml /c /coff /I "C:\Users\User\Desktop\archvs\masm32\include"' + $input_asm_file + '.asm') || Write-Error "Error at compile") && (Invoke-Expression(${masm_path} + '\bin\link /SUBSYSTEM:WINDOWS /DLL /DEF:' + ${input_asm_file} + '.def ' + ${input_asm_file} + '.obj') || Write-Error "Error at linking")

# Удаление лишних файлов
if (Test-Path (${input_asm_file} + '.obj')) {
    Remove-Item (${input_asm_file} + '.obj')
}


# delete old dll and lib files into D:\YandexDisk\main\work\VSProjects\asm8
if (Test-Path ('D:\YandexDisk\main\work\VSProjects\asm8\' + ${input_asm_file} + '.dll')) {
    Remove-Item ('D:\YandexDisk\main\work\VSProjects\asm8\' + ${input_asm_file} + '.dll')
}

if (Test-Path (${input_asm_file} + '.dll')) {
    Move-Item (${input_asm_file} + '.dll') 'D:\YandexDisk\main\work\VSProjects\asm8'
}