@chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion

:: ========== EDIT THESE LISTS ==========
set "REPLACE_FOLDERS=datapacks mods resourcepacks shaderpacks"
set "MERGE_FOLDERS=config"
:: ======================================

:: ----- Default folder -----
set "DEFAULT=%APPDATA%\.minecraft"

echo =================================================
echo   Установщик сборки Minecraft Neoforge 21.1.243
echo =================================================
echo Папка в которую установится сборка: %DEFAULT%
choice /c YN /n /m "Выбрать эту папку? (Y/N): "
if errorlevel 2 goto CHOOSE_CUSTOM
if errorlevel 1 (
    set "TARGET=%DEFAULT%"
    goto CONFIRM
)

:CHOOSE_CUSTOM
echo.
echo Сейчас откроется диалог для выбора другой папки.
echo Можете выбирать папку - по умолчанию: %DEFAULT%
echo.

:: ----- PowerShell folder picker (inline, no temp files) -----
set "PS_COMMAND=Add-Type -AssemblyName System.Windows.Forms;$b=New-Object System.Windows.Forms.FolderBrowserDialog;$b.Description='Выберите папку Minecraft Neoforge 21.1.243';$b.SelectedPath='%DEFAULT%';if($b.ShowDialog() -eq 'OK'){$b.SelectedPath}"

for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "%PS_COMMAND%"`) do set "TARGET=%%a"

if "%TARGET%"=="" (
    echo Папка не выбрана. Выход.
    timeout /t 10 /nobreak >nul
    exit /b
)

:CONFIRM
echo.
echo Выбранная папка: %TARGET%
choice /c YN /n /m "Установить сборку в папку? (Y/N): "
if errorlevel 2 exit /b

:: Ensure target exists
if not exist "%TARGET%" (
    echo Создается папка для установки...
    mkdir "%TARGET%"
)

:: ----- Source folder is where the script lives -----
set "SOURCE=%~dp0"
if "%SOURCE:~-1%"=="\" set "SOURCE=%SOURCE:~0,-1%"

echo.
echo ============================================
echo           Устнавливаем сборку...
echo ============================================

:: ----- REPLACE folders -----
for %%F in (%REPLACE_FOLDERS%) do (
    if exist "%TARGET%\%%F" (
        echo Удаляем папку: %%F
        rmdir /s /q "%TARGET%\%%F"
    )
    if exist "%SOURCE%\%%F" (
        echo Копируем папку: %%F
        xcopy "%SOURCE%\%%F" "%TARGET%\%%F\" /e /i /y >nul
        if errorlevel 1 echo   ПРЕДУПРЕЖДЕНИЕ: Не возможно скопировать "%%F" полностью.
    ) else (
        echo   ПРЕДУПРЕЖДЕНИЕ: Папка установки "%%F" не найдена, пропуск.
    )
)

:: ----- MERGE folders -----
for %%F in (%MERGE_FOLDERS%) do (
    if exist "%SOURCE%\%%F" (
        echo Совмещаем папки: %%F
        xcopy "%SOURCE%\%%F\*" "%TARGET%\%%F\" /e /i /y >nul
        if errorlevel 1 echo   ПРЕДУПРЕЖДЕНИЕ: Не возможно соместить "%%F" полностью.
    ) else (
        echo   ПРЕДУПРЕЖДЕНИЕ: Папка установки "%%F" не найдена, пропуск.
    )
)

echo.
echo ============================================
echo               Установка завершена!
echo ============================================
echo Выход через 10 секунд... (окошко закроется само, можете продолжать заниматься свои делами)
timeout /t 10 /nobreak >nul