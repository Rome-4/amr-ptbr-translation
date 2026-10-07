@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Alice: Madness Returns - Desinstalador PT-BR

echo ===========================================
echo Desinstalando PT-BR - Alice Madness Returns
echo ===========================================
echo.

:: Find the game in Steam.
call :find_game
if not defined GAME_DIR (
    echo.
    echo Nao foi possivel localizar Alice Madness Returns automaticamente.
    echo Selecione a pasta AliceGame na proxima janela.
    for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $d=New-Object System.Windows.Forms.FolderBrowserDialog; $d.Description='Selecione a pasta AliceGame'; if($d.ShowDialog() -eq 'OK'){ $d.SelectedPath }"`) do set "GAME_DIR=%%P"
)

if not defined GAME_DIR (
    echo ERRO: Nenhuma pasta selecionada.
    pause
    exit /b 1
)

set "ORIGINAL=%GAME_DIR%\CookedPC"
set "INT=%GAME_DIR%\Localization"
set "BACKUP=%INT%\INT_BKP"

if not exist "%ORIGINAL%" (
    echo ERRO: A pasta selecionada nao parece ser AliceGame.
    pause
    exit /b 1
)

if not exist "%BACKUP%" (
    echo Nenhum backup INT_BKP encontrado.
    echo Nada foi removido.
    pause
    exit /b 1
)

echo Jogo encontrado em:
echo "%GAME_DIR%"
echo.

choice /c SN /n /m "Restaurar os arquivos originais? [S/N] "
if errorlevel 2 exit /b 0

:: Restore original localization.
echo Restaurando arquivos originais...
copy /y "%BACKUP%\*.int" "%INT%\INT" >nul

if errorlevel 1 (
    echo ERRO: Falha ao restaurar a localizacao.
    echo O backup foi mantido.
    pause
    exit /b 1
)

:: Remove translated UPKs and restore the original .bak files.
for /R "%ORIGINAL%" %%F in (*.upk.bak) do (
    set "BACKUP_FILE=%%F"
    set "ORIGINAL_FILE=%%~dpnF"

    if exist "!ORIGINAL_FILE!" del /f /q "!ORIGINAL_FILE!" >nul
    ren "!BACKUP_FILE!" "%%~nF" >nul

    echo Restaurado: !ORIGINAL_FILE!
)

:: Remove the INT backup so the translation can be installed again.
rmdir /s /q "%BACKUP%" >nul 2>&1

echo.
echo =================================
echo Patch PT-BR removido com sucesso!
echo =================================
echo.
pause
exit /b 0


:find_game
set "STEAM="
set "GAME_DIR="

:: Main Steam installation from the registry.
for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul ^| find /i "SteamPath"') do set "STEAM=%%B"
if not defined STEAM for /f "tokens=2,*" %%A in ('reg query "HKLM\Software\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul ^| find /i "InstallPath"') do set "STEAM=%%B"

if not defined STEAM exit /b 0
set "STEAM=%STEAM:/=\%"

:: First try the default Steam library.
if exist "%STEAM%\steamapps\common\Alice Madness Returns\AliceGame\CookedPC" (
    set "GAME_DIR=%STEAM%\steamapps\common\Alice Madness Returns\AliceGame"
    exit /b 0
)

:: Then check additional Steam libraries listed in libraryfolders.vdf.
set "VDF=%STEAM%\steamapps\libraryfolders.vdf"
if exist "%VDF%" (
    for /f "tokens=2,*" %%A in ('findstr /i /c:"\"path\"" "%VDF%" 2^>nul') do (
        set "LIB=%%B"
        set "LIB=!LIB:"=!"
        set "LIB=!LIB:/=\!"
        if exist "!LIB!\steamapps\common\Alice Madness Returns\AliceGame\CookedPC" (
            set "GAME_DIR=!LIB!\steamapps\common\Alice Madness Returns\AliceGame"
            exit /b 0
        )
    )
)
exit /b 0
