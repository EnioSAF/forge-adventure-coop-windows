@echo off
setlocal EnableExtensions
pushd "%~dp0"

call "%~dp0INSTALL.bat" --quiet
if errorlevel 1 goto :failed

set "JAVA_EXE=%~dp0runtime\bin\java.exe"
if not exist "%JAVA_EXE%" set "JAVA_EXE=java.exe"

"%JAVA_EXE%" -version >nul 2>&1
if errorlevel 1 (
    echo ERREUR : Java est introuvable.
    echo Reinstalle ce pack ou installe Java 17 64 bits.
    goto :failed
)

set "PACK_HOME=%~dp0portable-data\home"
set "LOG_DIR=%~dp0portable-data\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\forge-coop-last.log"

echo Lancement de Forge Adventure Coop 2.0.13...
"%JAVA_EXE%" -Xmx4096m "-Duser.home=%PACK_HOME%" -Dfile.encoding=UTF-8 --add-opens java.desktop/java.beans=ALL-UNNAMED --add-opens java.desktop/javax.swing.border=ALL-UNNAMED --add-opens java.desktop/javax.swing.event=ALL-UNNAMED --add-opens java.desktop/sun.swing=ALL-UNNAMED --add-opens java.desktop/java.awt.image=ALL-UNNAMED --add-opens java.desktop/java.awt.color=ALL-UNNAMED --add-opens java.desktop/sun.awt.image=ALL-UNNAMED --add-opens java.desktop/javax.swing=ALL-UNNAMED --add-opens java.desktop/java.awt=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/java.text=ALL-UNNAMED --add-opens java.desktop/java.awt.font=ALL-UNNAMED --add-opens java.base/jdk.internal.misc=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/java.math=ALL-UNNAMED --add-opens java.base/java.util.concurrent=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED -Dio.netty.tryReflectionSetAccessible=true -jar forge-adventure-coop.jar >> "%LOG_FILE%" 2>&1
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" (
    echo Forge s'est ferme avec une erreur. Journal :
    echo %LOG_FILE%
    goto :failed
)

popd
exit /b 0

:failed
echo.
echo Consulte README-FR.txt si le probleme continue.
if not "%1"=="--quiet" pause
popd
exit /b 1
