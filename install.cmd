@echo off
setlocal
REM !! Do not edit without knowledge about what you are about to do !!

SET "ZIPDIR=file_serve-latest.zip"
SET "DIST=https://github.com/Ssword-dev/file_serve/releases/download/main/windows-exe.zip"

curl -L -o %ZIPDIR% %DIST%

REM force-override dir
powershell -Command "Expand-Archive -Path '%zip%' -DestinationPath '%outdir%' -Force"
echo Extraction complete to %outdir%

endlocal
