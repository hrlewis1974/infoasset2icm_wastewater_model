@echo off
set version=2024
set bit=64

if %bit%==32 (set "path=C:\Program Files (x86)")
if %bit%==64 (set "path=C:\Program Files")

"%path%\Autodesk\InfoWorks ICM Ultimate 2024\ICMExchange.exe" "%~dp0%\ie_script.rb"

PAUSE