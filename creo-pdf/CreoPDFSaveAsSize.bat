@echo off
REM Author: mnheia
REM Copyright (c) 2026 mnheia
REM Repository: https://github.com/mnheia/ptc-tools
REM License: GPL-3.0 (see LICENSE)
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CreoPDFSaveAsSize.ps1" %*
exit /b %ERRORLEVEL%
