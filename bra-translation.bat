@echo off
title Translation Installer - Alice Madness Returns
echo.
echo Preparing installation for Brazilian Portuguese...
echo.

:: 1. Create Backup for English files
if not exist "INT_BKP" (
    echo Creating backup of the original files...
    mkdir "INT_BKP"
    copy "INT\*.int" "INT_BKP"
)

:: 2. Copying the translated files
echo Applying translation files...
xcopy /y "BRA\*.int" "INT"

echo.
echo Successfully applied!
echo Now you can run the game via Steam, normally.
pause