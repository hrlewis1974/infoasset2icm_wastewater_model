@echo off

set version=2021.8
if %version%==2021.8 (set "folder=Innovyze Workgroup Client 2021.8\iexchange.exe")

set bit=32
if %bit%==32 (set "path=C:\Program Files (x86)")
if %bit%==64 (set "path=C:\Program Files")

"%path%\%folder%" "%~dp0%\_infoasset2csv.rb" /IA

PAUSE