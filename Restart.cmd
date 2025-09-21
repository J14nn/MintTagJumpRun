@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

SET "TARGET_FOLDER=%~dp0"
IF "%TARGET_FOLDER:~-1%"=="\" SET "TARGET_FOLDER=%TARGET_FOLDER:~0,-1%"

SET "SUBDIR=%TARGET_FOLDER%\.Wordhighlighter_Release"
SET "JSON_FILE=%SUBDIR%\config.json"

echo Updating JSON file...
powershell -Command "$json = Get-Content -Raw '%JSON_FILE%' | ConvertFrom-Json; $json.WorkingFolder = '%SUBDIR%'; $json.TessdataPath = Join-Path '%SUBDIR%' 'tessdata'; $json | ConvertTo-Json -Compress | Set-Content '%JSON_FILE%'"

echo Done.
pause
