@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM Git Config Switcher for Windows CMD
REM Easy switching between git configurations

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "CONFIG_FILE=%SCRIPT_DIR%config.json"

REM Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo [Error] config.json not found!
    echo Please copy config.example.json to config.json and edit it with your settings:
    echo   copy config.example.json config.json
    exit /b 1
)

REM Parse JSON using PowerShell (more reliable than batch parsing)
set "PARSE_SCRIPT=%TEMP%\parse_git_config.ps1"
echo $config = Get-Content '%CONFIG_FILE%' -Raw ^| ConvertFrom-Json; > "%PARSE_SCRIPT%"
echo $config.profiles ^| ForEach-Object -Begin {$i=0} -Process { >> "%PARSE_SCRIPT%"
echo   Write-Output "PROFILE_$i_NAME=$($_.name)" >> "%PARSE_SCRIPT%"
echo   Write-Output "PROFILE_$i_EMAIL=$($_.email)" >> "%PARSE_SCRIPT%"
echo   Write-Output "PROFILE_$i_LABEL=$($_.label)" >> "%PARSE_SCRIPT%"
echo   $i++ >> "%PARSE_SCRIPT%"
echo } >> "%PARSE_SCRIPT%"
echo Write-Output "PROFILE_COUNT=$i" >> "%PARSE_SCRIPT%"

REM Execute PowerShell and capture output
for /f "usebackq tokens=1,* delims==" %%a in (`powershell -ExecutionPolicy Bypass -File "%PARSE_SCRIPT%" 2^>nul`) do (
    set "%%a=%%b"
)

del "%PARSE_SCRIPT%" 2>nul

REM Check if parsing succeeded
if not defined PROFILE_COUNT (
    echo [Error] Failed to parse config.json!
    echo Please ensure config.json is valid JSON format.
    exit /b 1
)

:SHOW_CURRENT
echo.
echo ========================================
echo Current Git Configuration:
echo ========================================
for /f "tokens=*" %%i in ('git config user.name') do set CURRENT_NAME=%%i
for /f "tokens=*" %%i in ('git config user.email') do set CURRENT_EMAIL=%%i
echo   Name: %CURRENT_NAME%
echo   Email: %CURRENT_EMAIL%
echo.

:MENU
echo ========================================
echo Which configuration would you like to switch to?
echo ========================================

REM Display all profiles dynamically
set /a MENU_MAX=%PROFILE_COUNT%+1
for /l %%i in (0,1,%PROFILE_COUNT%) do (
    set /a MENU_NUM=%%i+1
    if defined PROFILE_%%i_LABEL (
        echo !MENU_NUM!^) !PROFILE_%%i_LABEL! ^(!PROFILE_%%i_NAME! ^<!PROFILE_%%i_EMAIL!^>^)
    )
)
echo %MENU_MAX%^) Cancel
echo.

set /p choice="Select (1-%MENU_MAX%): "

REM Validate input
echo %choice%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo [Error] Invalid selection.
    exit /b 1
)

REM Handle cancel
if "%choice%"=="%MENU_MAX%" (
    echo.
    echo Cancelled.
    exit /b 0
)

REM Handle profile selection
if %choice% GEQ 1 if %choice% LEQ %PROFILE_COUNT% (
    set /a PROFILE_IDX=%choice%-1
    for /f "tokens=2 delims==" %%a in ('set PROFILE_!PROFILE_IDX!_NAME') do set SELECTED_NAME=%%a
    for /f "tokens=2 delims==" %%a in ('set PROFILE_!PROFILE_IDX!_EMAIL') do set SELECTED_EMAIL=%%a
    for /f "tokens=2 delims==" %%a in ('set PROFILE_!PROFILE_IDX!_LABEL') do set SELECTED_LABEL=%%a

    git config --global user.name "!SELECTED_NAME!"
    git config --global user.email "!SELECTED_EMAIL!"
    echo.
    echo [Success] Switched to !SELECTED_LABEL! account.
    goto SHOW_RESULT
) else (
    echo.
    echo [Error] Invalid selection.
    exit /b 1
)

:SHOW_RESULT
echo.
echo ========================================
echo Updated Git Configuration:
echo ========================================
for /f "tokens=*" %%i in ('git config user.name') do set NEW_NAME=%%i
for /f "tokens=*" %%i in ('git config user.email') do set NEW_EMAIL=%%i
echo   Name: %NEW_NAME%
echo   Email: %NEW_EMAIL%
echo ========================================
echo.
exit /b 0
