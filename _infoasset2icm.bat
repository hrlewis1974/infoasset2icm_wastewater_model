@echo off

set version=2024
if %version%==2024 (set "folder=Autodesk\InfoWorks ICM Ultimate 2024\ICMExchange.exe")

set bit=64
if %bit%==32 (set "path=C:\Program Files (x86)")
if %bit%==64 (set "path=C:\Program Files")

"%path%\%folder%" "%~dp0%\_infoasset2icm.rb"

PAUSE