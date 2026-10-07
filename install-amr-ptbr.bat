@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Alice: Madness Returns - Instalador PT-BR

echo =========================================
echo Instalando PT-BR - Alice Madness Returns
echo =========================================
echo.

:: Translation files are next to this script.
set "SOURCE=%~dp0BRA"
set "TRANSLATION=%SOURCE%\CookedPC"
set "LOCALIZATION=%SOURCE%\Localization"

if not exist "%TRANSLATION%" (
    echo ERRO: Pasta BRA\CookedPC nao encontrada.
    pause
    exit /b 1
)

if not exist "%LOCALIZATION%\AliceGame.int" (
    echo ERRO: Arquivos de traducao nao encontrados em BRA\Localization.
    pause
    exit /b 1
)

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
set "ENG=%GAME_DIR%\Localization"
set "INT=%ENG%\INT"
set "BACKUP=%ENG%\INT_BKP"

if not exist "%ORIGINAL%" (
    echo ERRO: A pasta selecionada nao parece ser AliceGame.
    pause
    exit /b 1
)

if not exist "%INT%" (
    echo ERRO: A pasta Localization\INT nao foi encontrada.
    pause
    exit /b 1
)

if exist "%BACKUP%" (
    echo ERRO: O backup INT_BKP ja existe.
    echo Desinstale a traducao antes de instalar novamente.
    pause
    exit /b 1
)

echo Jogo encontrado em:
echo "%GAME_DIR%"
echo.
echo Um backup dos arquivos originais sera criado em:
echo "%BACKUP%"
echo.

choice /c SN /n /m "Continuar? [S/N] "
if errorlevel 2 exit /b 0

:: Backup the original English localization.
echo Criando backup da localizacao original...
mkdir "%BACKUP%"
copy /y "%INT%\*.int" "%BACKUP%\" >nul

if errorlevel 1 (
    echo ERRO: Nao foi possivel criar o backup.
    rmdir /s /q "%BACKUP%" 2>nul
    pause
    exit /b 1
)

:: Copy translated localization.
echo Aplicando arquivos de traducao...
copy /y "%LOCALIZATION%\*.int" "%INT%\" >nul

if errorlevel 1 (
    echo ERRO: Falha ao copiar os arquivos de traducao.
    echo Restaurando o backup...
    copy /y "%BACKUP%\*.int" "%INT%\" >nul
    rmdir /s /q "%BACKUP%" 2>nul
    pause
    exit /b 1
)

:: Copy translated UPK files, preserving the folder structure.
for /R "%TRANSLATION%" %%F in (*.upk) do (
    set "FILE=%%F"
    set "REL=!FILE:%TRANSLATION%\=!"
    set "TARGET=%ORIGINAL%\!REL!"

    for %%D in ("!TARGET!") do if not exist "%%~dpD" mkdir "%%~dpD"

    :: Keep the original file only once.
    if exist "!TARGET!" if not exist "!TARGET!.bak" (
        copy /y "!TARGET!" "!TARGET!.bak" >nul
    )

    copy /y "%%F" "!TARGET!" >nul
    echo Instalado: !REL!
)

echo.
echo ==================================
echo Patch PT-BR instalado com sucesso!
echo ==================================
echo.
echo Para remover a traducao, execute:
echo uninstall-amr-ptbr.bat
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
