@echo off
setlocal enabledelayedexpansion

:: ========== EDIT THESE LISTS ==========
set "REPLACE_FOLDERS=datapacks mods resourcepacks shaderpacks"
set "MERGE_FOLDERS=config"
:: ======================================

:: ----- Default folder -----
set "DEFAULT=%APPDATA%\.minecraft"

echo =================================================
echo   Minecraft Neoforge 21.1.243 modpack installer
echo =================================================
echo Default Minecraft folder: %DEFAULT%
choice /c YN /n /m "Use this folder? (Y/N): "
if errorlevel 2 goto CHOOSE_CUSTOM
if errorlevel 1 (
    set "TARGET=%DEFAULT%"
    goto CONFIRM
)

:CHOOSE_CUSTOM
echo.
echo A folder selection dialog will now open.
echo You can browse anywhere - starting in: %DEFAULT%
echo.

:: ----- PowerShell folder picker (inline, no temp files) -----
set "PS_COMMAND=Add-Type -AssemblyName System.Windows.Forms;$b=New-Object System.Windows.Forms.FolderBrowserDialog;$b.Description='Select your Minecraft instance folder';$b.SelectedPath='%DEFAULT%';if($b.ShowDialog() -eq 'OK'){$b.SelectedPath}"

for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "%PS_COMMAND%"`) do set "TARGET=%%a"

if "%TARGET%"=="" (
    echo No folder selected. Exiting.
    timeout /t 10 /nobreak >nul
    exit /b
)

:CONFIRM
echo.
echo Target folder: %TARGET%
choice /c YN /n /m "Proceed with installation? (Y/N): "
if errorlevel 2 exit /b

:: Ensure target exists
if not exist "%TARGET%" (
    echo Creating target folder...
    mkdir "%TARGET%"
)

:: ----- Source folder is where the script lives -----
set "SOURCE=%~dp0"
if "%SOURCE:~-1%"=="\" set "SOURCE=%SOURCE:~0,-1%"

echo.
echo ============================================
echo           Starting operations...
echo ============================================

:: ----- REPLACE folders -----
for %%F in (%REPLACE_FOLDERS%) do (
    if exist "%TARGET%\%%F" (
        echo Removing folder: %%F
        rmdir /s /q "%TARGET%\%%F"
    )
    if exist "%SOURCE%\%%F" (
        echo Copying folder: %%F
        xcopy "%SOURCE%\%%F" "%TARGET%\%%F\" /e /i /y >nul
        if errorlevel 1 echo   WARNING: Could not copy "%%F" completely.
    ) else (
        echo   WARNING: Source folder "%%F" not found, skipping.
    )
)

:: ----- MERGE folders -----
for %%F in (%MERGE_FOLDERS%) do (
    if exist "%SOURCE%\%%F" (
        echo Merging folder: %%F
        xcopy "%SOURCE%\%%F\*" "%TARGET%\%%F\" /e /i /y >nul
        if errorlevel 1 echo   WARNING: Could not merge "%%F" completely.
    ) else (
        echo   WARNING: Source folder "%%F" not found, skipping.
    )
)

echo.
echo ============================================
echo               All done!
echo ============================================
echo Exiting in 10 seconds...
timeout /t 10 /nobreak >nul