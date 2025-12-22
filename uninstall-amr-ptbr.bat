@echo off
setlocal EnableDelayedExpansion

pushd "%~dp0.."
set "BASE_DIR=%CD%"
popd

set ORIGINAL=%BASE_DIR%\CookedPC
set INT=%BASE_DIR%\Localization

echo ===========================================
echo Desinstalando PT-BR - Alice Madness Returns
echo ===========================================

if not exist "%ORIGINAL%" (
    echo ERRO: Verifique se a traducao foi instalada na pasta "AliceGame".
    pause
    exit /b
)

if not exist "%INT%\INT_BKP" (
    echo Nenhum arquivo modificado encontrado...
    pause
    exit /b
) else (
    echo Restaurando Backup dos arquivos originais...
    copy "%INT%\INT_BKP\*.int" "%INT%\INT"
    rmdir /S /Q "%INT%\INT_BKP"
)

:: 1: remove translated .upk
for /R "%ORIGINAL%" %%F in (*.upk.bak) do (
    if exist "%%~dpnF" (
        del /F /Q "%%~dpnF"
        echo Removido: %%~dpnF
    )
)

:: 2: restore backups
for /R "%ORIGINAL%" %%F in (*.upk.bak) do (
    ren "%%F" "%%~nF"
    echo Restaurado: %%~dpnF
)

echo =================================
echo Patch PT-BR removido com sucesso!
echo =================================
pause

