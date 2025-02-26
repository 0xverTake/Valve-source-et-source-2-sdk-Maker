@echo off
echo Source Table Generator - Installation
echo ====================================
echo.

:: Vérifier si Cheat Engine est installé
set "CEINSTALLED=0"
if exist "%PROGRAMFILES%\Cheat Engine 7.4\cheatengine-x86_64.exe" (
    set "CEPATH=%PROGRAMFILES%\Cheat Engine 7.4"
    set "CEINSTALLED=1"
)
if exist "%PROGRAMFILES(X86)%\Cheat Engine 7.4\cheatengine-x86_64.exe" (
    set "CEPATH=%PROGRAMFILES(X86)%\Cheat Engine 7.4"
    set "CEINSTALLED=1"
)
if exist "%PROGRAMFILES%\Cheat Engine 7.3\cheatengine-x86_64.exe" (
    set "CEPATH=%PROGRAMFILES%\Cheat Engine 7.3"
    set "CEINSTALLED=1"
)
if exist "%PROGRAMFILES(X86)%\Cheat Engine 7.3\cheatengine-x86_64.exe" (
    set "CEPATH=%PROGRAMFILES(X86)%\Cheat Engine 7.3"
    set "CEINSTALLED=1"
)
if exist "%PROGRAMFILES%\Cheat Engine 7.2\cheatengine-x86_64.exe" (
    set "CEPATH=%PROGRAMFILES%\Cheat Engine 7.2"
    set "CEINSTALLED=1"
)
if exist "%PROGRAMFILES(X86)%\Cheat Engine 7.2\cheatengine-x86_64.exe" (
    set "CEPATH=%PROGRAMFILES(X86)%\Cheat Engine 7.2"
    set "CEINSTALLED=1"
)

if "%CEINSTALLED%"=="0" (
    echo Cheat Engine n'a pas été trouvé sur votre système.
    echo Veuillez installer Cheat Engine 7.2 ou supérieur.
    echo.
    echo Vous pouvez télécharger Cheat Engine à l'adresse suivante:
    echo https://www.cheatengine.org/downloads.php
    echo.
    echo Une fois Cheat Engine installé, relancez ce script.
    pause
    exit /b 1
)

echo Cheat Engine trouvé: %CEPATH%
echo.

:: Créer le dossier autorun s'il n'existe pas
if not exist "%CEPATH%\autorun" (
    echo Création du dossier autorun...
    mkdir "%CEPATH%\autorun"
)

:: Copier les fichiers
echo Copie des fichiers...
copy "SourceTableGenerator.lua" "%CEPATH%\autorun\" > nul
copy "CustomSignatures.lua" "%CEPATH%\autorun\" > nul

echo.
echo Installation terminée!
echo.
echo Le plugin sera chargé automatiquement au prochain démarrage de Cheat Engine.
echo Vous pourrez y accéder via le menu "Source Table Generator" dans Cheat Engine.
echo.
echo Pour plus d'informations, consultez le fichier README.md.
echo.
pause
