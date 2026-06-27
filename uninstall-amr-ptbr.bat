@echo off
setlocal EnableDelayedExpansion

echo ===========================================
echo Desinstalando PT-BR - Alice Madness Returns
echo ===========================================
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
if not defined STEAM_PATH (
    echo ERRO: Steam nao encontrado. Instale o Steam e tente novamente.
    pause
    exit /b 1
)
call :normalize_path STEAM_PATH
echo [OK] Steam encontrado em: %STEAM_PATH%

:: STEP 2
set "GAME_DIR="
if exist "%STEAM_PATH%\steamapps\common\Alice Madness Returns\AliceGame\" (
    set "GAME_DIR=%STEAM_PATH%\steamapps\common\Alice Madness Returns\AliceGame"
)
if not defined GAME_DIR (
    echo ERRO: Jogo nao encontrado. Verifique se o jogo esta instalado.
    pause
    exit /b 1
)
echo [OK] Jogo encontrado em: %GAME_DIR%

:: STEP 3
set "ORIGINAL=%GAME_DIR%\CookedPC"
set "INT=%GAME_DIR%\Localization"

if not exist "%ORIGINAL%\" (
    echo ERRO: Pasta CookedPC nao encontrada. O jogo esta instalado corretamente?
    pause
    exit /b 1
)

:: STEP 4
if not exist "%INT%\INT_BKP\" (
    echo AVISO: Nenhum backup encontrado. A traducao foi instalada neste computador?
    pause
    exit /b 1
)
echo Restaurando arquivos originais (.int)...
copy /Y "%INT%\INT_BKP\*.int" "%INT%\INT\" >nul
rmdir /S /Q "%INT%\INT_BKP"
echo [OK] Arquivos .int restaurados.

:: STEP 5
echo Restaurando arquivos originais (.upk)...
set "COUNT=0"

for /R "%ORIGINAL%" %%F in (*.upk.bak) do (
    if exist "%%~dpnF" del /F /Q "%%~dpnF"
)

for /R "%ORIGINAL%" %%F in (*.upk.bak) do (
    ren "%%F" "%%~nF"
    set /a COUNT+=1
    echo   [!COUNT!] %%~nF
)

echo.
echo =================================
echo Patch PT-BR removido com sucesso!
echo Arquivos restaurados: %COUNT%
echo =================================
pause
exit /b 0

:normalize_path
set "%~1=!%~1:/=\!"
:normalize_loop
set "_before=!%~1!"
set "%~1=!%~1:\\=\!"
if not "!%~1!"=="!_before!" goto :normalize_loop
exit /b 0
