@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

SET "TARGET_FOLDER=%~dp0"

echo Deleting all contents of %TARGET_FOLDER%...
rmdir /s /q "%TARGET_FOLDER%"
mkdir "%TARGET_FOLDER%"

SET "ZIP_FILE=%TARGET_FOLDER%\..\MintTag.zip"
echo Extracting %ZIP_FILE% to %TARGET_FOLDER%...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TARGET_FOLDER%' -Force"

SET "JSON_FILE=%TARGET_FOLDER%\config.json"

echo Updating JSON file...
powershell -Command ^
    "$json = Get-Content -Raw '%JSON_FILE%' | ConvertFrom-Json; ^
     $json.WorkingFolder = '%TARGET_FOLDER%'; ^
     $json.TessdataPath = Join-Path '%TARGET_FOLDER%' 'tessdata'; ^
     $json | ConvertTo-Json -Compress | Set-Content '%JSON_FILE%'"

echo Done.
pause
