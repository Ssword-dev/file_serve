@echo off
setlocal

REM Define KC* values, KC stands for Keyword Commands
SET "KCPREF=start /B cmd /Q /d /k"
SET "KCCOM=flutter build"

REM Define KT* values, KT stands for Keyword Target
SET "KTTARGETS=windows web apk"

REM Protocols/Actions
SET "KPINF=echo Compiling the code in the background..."

REM Loop through each target in KTTARGETS
REM this does what you expect it to do, spawn a bunch of cmd prompt to
REM compile in parallel (actually, concurrently)
for %%T in (%KTTARGETS%) do (
    %KPINF%
    %KCPREF% "%KCCOM% %%T && exit /b %%errorlevel%%"
)

endlocal
