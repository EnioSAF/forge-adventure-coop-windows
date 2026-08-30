@echo off
setlocal EnableExtensions
pushd "%~dp0"

if not exist "forge-adventure-coop.jar" (
    echo ERREUR : forge-adventure-coop.jar manque. Reextrais le ZIP complet.
    goto :failed
)
if not exist "res\adventure" (
    echo ERREUR : les ressources Adventure manquent. Reextrais le ZIP complet.
    goto :failed
)

for %%D in ("portable-data" "portable-data\home" "portable-data\user" "portable-data\user\preferences" "portable-data\cache" "portable-data\logs") do (
    if not exist "%%~D" mkdir "%%~D"
)

if not "%1"=="--quiet" (
    echo Pack pret. Aucune installation Forge existante n'a ete modifiee.
    echo Lance maintenant PLAY COOP.bat.
    pause
)
popd
exit /b 0

:failed
if not "%1"=="--quiet" pause
popd
exit /b 1
