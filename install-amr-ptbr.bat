@echo off
setlocal EnableDelayedExpansion

echo =========================================
echo Instalando PT-BR - Alice Madness Returns
echo =========================================
echo.

:: STEP 1
set "STEAM_PATH="
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "HKCU\SOFTWARE\Valve\Steam" /v "SteamPath" 2^>nul') do (
    if /i "%%A"=="SteamPath" set "STEAM_PATH=%%C"
)
if not defined STEAM_PATH (
    for /f "skip=2 tokens=1,2,*" %%A in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v "SteamPath" 2^>nul') do (
        if /i "%%A"=="SteamPath" set "STEAM_PATH=%%C"
    )
)
if not defined STEAM_PATH (
    for /f "skip=2 tokens=1,2,*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v "SteamPath" 2^>nul') do (
        if /i "%%A"=="SteamPath" set "STEAM_PATH=%%C"
    )
)
call :normalize_path STEAM_PATH
echo [1] STEAM_PATH = "%STEAM_PATH%"

:: STEP 2
set "GAME_DIR="
if exist "%STEAM_PATH%\steamapps\common\Alice Madness Returns\AliceGame\" (
    set "GAME_DIR=%STEAM_PATH%\steamapps\common\Alice Madness Returns\AliceGame"
)
echo [2] GAME_DIR = "%GAME_DIR%"

:: STEP 3
set "ORIGINAL=%GAME_DIR%\CookedPC"
set "TRANSLATION=%~dp0BRA\CookedPC"
set "BRA=%~dp0BRA\Localization"
set "ENG=%GAME_DIR%\Localization"
if "%TRANSLATION:~-1%"=="\" set "TRANSLATION=%TRANSLATION:~0,-1%"
echo [3] ORIGINAL     = "%ORIGINAL%"
echo [3] TRANSLATION  = "%TRANSLATION%"
echo [3] BRA          = "%BRA%"
echo [3] ENG          = "%ENG%"

:: STEP 3 - validations
if not exist "%TRANSLATION%\" (
    echo [ERRO] TRANSLATION nao existe!
    pause
    exit /b 1
)
echo [3] TRANSLATION existe!
pause

if not exist "%BRA%\" (
    echo [ERRO] BRA nao existe!
    pause
    exit /b 1
)
echo [3] BRA existe!

:: STEP 4
if not exist "%ENG%\INT_BKP\" (
    echo [4] Criando backup...
    mkdir "%ENG%\INT_BKP"
    for %%F in (AliceGame.int GFxUI.int Subtitles.int) do (
        if exist "%ENG%\INT\%%F" copy "%ENG%\INT\%%F" "%ENG%\INT_BKP\" >nul
    )
    echo [4] Backup criado.
) else (
    echo [4] Backup ja existe.
)

:: STEP 5
echo [5] Copiando .int...
xcopy /y "%BRA%\*.int" "%ENG%\INT\" >nul
echo [5] .int copiados.

:: STEP 6
echo [6] Calculando tamanho do prefixo...
set "TRANS_LEN=0"
set "TEMP_STR=%TRANSLATION%\"
:count_loop
if not "!TEMP_STR!"=="" (
    set "TEMP_STR=!TEMP_STR:~1!"
    set /a TRANS_LEN+=1
    goto :count_loop
)
echo [6] TRANS_LEN = %TRANS_LEN%

echo [6] Copiando .upk...
set "COUNT=0"
for /R "%TRANSLATION%" %%F in (*.upk) do (
    set "FILE=%%F"
    set "REL=!FILE:~%TRANS_LEN%!"
    set "TARGET=%ORIGINAL%\!REL!"
    for %%D in ("!TARGET!") do (
        if not exist "%%~dpD\" mkdir "%%~dpD"
    )
    if exist "!TARGET!" (
        if not exist "!TARGET!.bak" copy "!TARGET!" "!TARGET!.bak" >nul
    )
    copy /Y "%%F" "!TARGET!" >nul
    set /a COUNT+=1
    echo   [!COUNT!] !REL!
)
echo [6] Concluido. Total: %COUNT%

echo.
echo ==================================
echo Patch PT-BR instalado com sucesso!
echo ==================================
pause
exit /b 0

:normalize_path
set "%~1=!%~1:/=\!"
:normalize_loop
set "_before=!%~1!"
set "%~1=!%~1:\\=\!"
if not "!%~1!"=="!_before!" goto :normalize_loop
exit /b 0
