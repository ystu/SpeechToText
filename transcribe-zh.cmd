@echo off
setlocal

if "%~1"=="" (
  echo Usage: transcribe-zh.cmd "path\to\audio.m4a"
  exit /b 1
)

subst M: "%~dp0" >nul 2>nul
if not exist "M:\transcribe-zh.ps1" (
  echo Could not map this folder to M:. Please free drive letter M: and try again.
  exit /b 1
)
powershell -ExecutionPolicy Bypass -File "M:\transcribe-zh.ps1" %*
