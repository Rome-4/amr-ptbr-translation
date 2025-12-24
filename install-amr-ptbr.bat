@echo off
setlocal EnableDelayedExpansion

:: === BASE FOLDERS ===
pushd "%~dp0.."
set "BASE_DIR=%CD%"
popd

set ORIGINAL=%BASE_DIR%\CookedPC
set TRANSLATION=%BASE_DIR%\amr-ptbr-translation\BRA\CookedPC
set BRA=%BASE_DIR%\amr-ptbr-translation\BRA\Localization
set ENG=%BASE_DIR%\Localization

echo =========================================
echo Instalando PT-BR - Alice Madness Returns
echo =========================================

:: Verifying directories
if not exist "%ORIGINAL%" (
    echo ERRO: Verifique se a traducao foi instalada na pasta "AliceGame".
    pause
    exit /b
)

if not exist "%TRANSLATION%" (
    echo ERRO: Verifique se o traducao foi instalada na pasta "AliceGame".
    pause
    exit /b
)

:: Create Backup for English .int files
if not exist "%ENG%\INT_BKP" (
    echo Creating backup of the original files...
    mkdir "%ENG%\INT_BKP"
    copy "%ENG%\INT\*.int" "%ENG%\INT_BKP"
)

:: Copying the translated .int files
echo Applying translation files...
xcopy /y "%BRA%\*.int" "%ENG%\INT"

:: Iterate all *_LOC_INT.upk files
for /R "%TRANSLATION%" %%F in (*_LOC_INT.upk) do (

    :: Modded CookedPC relative location
    set "FILE=%%F"
    set "REL=!FILE:%TRANSLATION%\=!"
    
    set "TARGET=%ORIGINAL%\!REL!"

    REM Cria pasta de destino
    for %%D in ("!TARGET!") do (
        if not exist "%%~dpD" (
            mkdir "%%~dpD"
        )
    )

    :: Backup for the original files (once)
    if exist "!TARGET!" (
        if not exist "!TARGET!.bak" (
            copy "!TARGET!" "!TARGET!.bak" >nul
        )
    )

    :: Copying the translated .upk files
    copy /Y "%%F" "!TARGET!" >nul

    echo Instalado: !REL!
)

echo ==================================
echo Patch PT-BR instalado com sucesso!
echo ==================================
pause

