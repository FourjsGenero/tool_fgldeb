@echo off
setlocal EnableExtensions
set CURDIR=%CD%
set CURDRIVE=%CURDIR:~0,2%
set FGLDEBDIR=%~dp0
set FGLDEBDRIVE=%FGLDEBDIR:~0,2%
%FGLDEBDRIVE%
cd %FGLDEBDIR%
rem we recompile everything: hence never version clashes
fglcomp -M fgldeb.4gl
if %errorlevel% neq 0 exit /b %errorlevel%
for %%F in (*.per) do fglform -M %%F
set FGLRESOURCEPATH=%FGLDEBDIR%;%FGLRESOURCEPATH%
set DBPATH=%FGLDEBDIR%:%DBPATH%
set FGLIMAGEPATH=%FGLDEBDIR%\icons;%FGLIMAGEPATH%
if exist "%FGLDIR%\lib\image2font.txt" ( set "FGLIMAGEPATH=%FGLIMAGEPATH%;%FGLDIR%\lib\image2font.txt")
%CURDRIVE%
cd %CURDIR%
fglrun %FGLDEBDIR%\fgldeb.42m %*
