@echo off
REM Batch Layer Standards Checker System
REM This script processes all AutoCAD files in a folder using AcCoreConsole.exe

setlocal enabledelayedexpansion

REM Configuration
set "ACCORECONSOLE_PATH=C:\Program Files\Autodesk\AutoCAD 2024\AcCoreConsole.exe"
set "LISP_FILE=%~dp0layer_standards_checker.lsp"
set "SCRIPT_FILE=%~dp0ProcessFiles.scr"
set "LOG_FILE=%~dp0ProcessingLog.txt"

REM Get input folder from user
if "%1"=="" (
    set /p "INPUT_FOLDER=Enter folder path containing DWG files: "
) else (
    set "INPUT_FOLDER=%1"
)

REM Validate input folder
if not exist "%INPUT_FOLDER%" (
    echo ERROR: Folder "%INPUT_FOLDER%" does not exist.
    pause
    exit /b 1
)

REM Check if AcCoreConsole.exe exists
if not exist "%ACCORECONSOLE_PATH%" (
    echo ERROR: AcCoreConsole.exe not found at: %ACCORECONSOLE_PATH%
    echo Please update the ACCORECONSOLE_PATH variable in this script.
    pause
    exit /b 1
)

REM Check if LISP file exists
if not exist "%LISP_FILE%" (
    echo ERROR: LISP file not found: %LISP_FILE%
    echo Make sure layer_standards_checker.lsp is in the same folder as this batch file.
    pause
    exit /b 1
)

REM Initialize log file
echo Batch Layer Standards Processing Log > "%LOG_FILE%"
echo Started: %date% %time% >> "%LOG_FILE%"
echo Input Folder: %INPUT_FOLDER% >> "%LOG_FILE%"
echo ================================================ >> "%LOG_FILE%"

echo.
echo Batch Layer Standards Checker
echo =============================
echo Input Folder: %INPUT_FOLDER%
echo LISP File: %LISP_FILE%
echo Log File: %LOG_FILE%
echo.

REM Count DWG files
set "FILE_COUNT=0"
for %%f in ("%INPUT_FOLDER%\*.dwg") do (
    set /a FILE_COUNT+=1
)

if %FILE_COUNT%==0 (
    echo No DWG files found in the specified folder.
    echo No DWG files found. >> "%LOG_FILE%"
    pause
    exit /b 0
)

echo Found %FILE_COUNT% DWG files to process.
echo Found %FILE_COUNT% DWG files to process. >> "%LOG_FILE%"
echo.

REM Ask for confirmation
set /p "PROCEED=Proceed with processing? (Y/N): "
if /i not "%PROCEED%"=="Y" (
    echo Processing cancelled by user.
    echo Processing cancelled by user. >> "%LOG_FILE%"
    exit /b 0
)

echo.
echo Processing files...
echo.

REM Process each DWG file
set "PROCESSED_COUNT=0"
set "ERROR_COUNT=0"

for %%f in ("%INPUT_FOLDER%\*.dwg") do (
    set /a PROCESSED_COUNT+=1
    echo Processing [!PROCESSED_COUNT!/%FILE_COUNT%]: %%~nxf
    echo Processing [!PROCESSED_COUNT!/%FILE_COUNT%]: %%~nxf >> "%LOG_FILE%"
    
    REM Create script file for this drawing
    call :CreateScriptFile "%%f"
    
    REM Run AcCoreConsole
    "%ACCORECONSOLE_PATH%" /i "%%f" /s "%SCRIPT_FILE%" > nul 2>&1
    
    if !errorlevel! equ 0 (
        echo   - SUCCESS
        echo   - SUCCESS >> "%LOG_FILE%"
    ) else (
        echo   - ERROR ^(Exit Code: !errorlevel!^)
        echo   - ERROR ^(Exit Code: !errorlevel!^) >> "%LOG_FILE%"
        set /a ERROR_COUNT+=1
    )
)

REM Clean up temporary script file
if exist "%SCRIPT_FILE%" del "%SCRIPT_FILE%"

REM Summary
echo.
echo ================================================
echo Processing Complete!
echo ================================================
echo Total files processed: %PROCESSED_COUNT%
echo Successful: %SUCCESSFUL_COUNT%
echo Errors: %ERROR_COUNT%
echo.
echo Check %LOG_FILE% for detailed results.
echo.

REM Log completion
echo ================================================ >> "%LOG_FILE%"
echo Processing Complete: %date% %time% >> "%LOG_FILE%"
echo Total files processed: %PROCESSED_COUNT% >> "%LOG_FILE%"
echo Errors: %ERROR_COUNT% >> "%LOG_FILE%"

pause
goto :eof

:CreateScriptFile
REM Create AutoCAD script file
echo ^(load "%LISP_FILE%"^) > "%SCRIPT_FILE%"
echo ^(c:LayerStandardsCheck^) >> "%SCRIPT_FILE%"
echo QSAVE >> "%SCRIPT_FILE%"
echo QUIT >> "%SCRIPT_FILE%"
goto :eof