@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CreoPDFSaveAsSize.ps1" %*
exit /b %ERRORLEVEL%
