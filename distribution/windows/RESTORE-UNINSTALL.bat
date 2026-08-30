@echo off
setlocal EnableExtensions
pushd "%~dp0"

echo ATTENTION : cette action efface uniquement les sauvegardes, reglages,
echo caches et journaux contenus dans CE dossier portable.
echo Ton installation Forge principale ne sera pas touchee.
set /p "CONFIRM=Ecris EFFACER pour continuer : "
if /i not "%CONFIRM%"=="EFFACER" (
    echo Annule.
    popd
    exit /b 0
)

if exist "%~dp0portable-data" rmdir /s /q "%~dp0portable-data"
echo Donnees portables effacees. Tu peux maintenant supprimer ce dossier manuellement.
pause
popd
exit /b 0
