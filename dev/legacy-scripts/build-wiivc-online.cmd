@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "WORK_DIR=%ROOT%ioso\workdir.tmp"
set "SOURCE_DOL=%WORK_DIR%\sys\main.dol"
set "LOADER_DIR=%ROOT%wiivc-loader"
set "LOADER_TEXT=%LOADER_DIR%\build\bootstrap-text.bin"
set "LOADER_DATA=%LOADER_DIR%\build\bootstrap-data.bin"
set "PATCHED_DIR=%ROOT%build\wiivc-online"
set "PATCHED_DOL=%PATCHED_DIR%\main.dol"
set "BACKUP_DOL=%PATCHED_DIR%\clean-main.dol"
set "CODE_PUL=%ROOT%ioso\RetroRewind6\Binaries\Code.pul"
set "EXPECTED_CLEAN_HASH=D2BEEC1B1645FCD134EFE9E7E63774B546667764ED8D431029DACCD725995694"
set "SOURCE_REPLACED=0"
set "CHECK_ONLY=0"

if /I "%~1"=="--check" (
    set "CHECK_ONLY=1"
    set "OUTPUT_DIR=%ROOT%build\wiivc-online-image-cmd"
) else if "%~1"=="" (
    set "OUTPUT_DIR=%ROOT%build\wiivc-online-image-cmd"
) else (
    set "OUTPUT_DIR=%~f1"
)

where py >nul 2>&1 || (
    echo ERROR: Python launcher "py" was not found.
    exit /b 1
)
where wit >nul 2>&1 || (
    echo ERROR: WIT was not found in PATH.
    exit /b 1
)
where wsl >nul 2>&1 || (
    echo ERROR: WSL was not found.
    exit /b 1
)

if not exist "%SOURCE_DOL%" (
    echo ERROR: Missing "%SOURCE_DOL%"
    exit /b 1
)
if not exist "%CODE_PUL%" (
    echo ERROR: Missing "%CODE_PUL%"
    exit /b 1
)
if not exist "%LOADER_DIR%\build.sh" (
    echo ERROR: Missing "%LOADER_DIR%\build.sh"
    exit /b 1
)
if exist "%OUTPUT_DIR%" (
    echo ERROR: Output directory already exists:
    echo "%OUTPUT_DIR%"
    exit /b 1
)

py -c "from pathlib import Path; import hashlib,sys; actual=hashlib.sha256(Path(sys.argv[1]).read_bytes()).hexdigest().upper(); expected=sys.argv[2]; print('Clean DOL SHA256: '+actual); raise SystemExit(not actual == expected)" "%SOURCE_DOL%" "%EXPECTED_CLEAN_HASH%"
if errorlevel 1 (
    echo ERROR: workdir main.dol is not the expected clean NTSC-U WiiVC base.
    exit /b 1
)

if "%CHECK_ONLY%"=="1" (
    echo CMD prerequisites and clean DOL check: OK
    exit /b 0
)

for /f "usebackq delims=" %%P in (`wsl -d Ubuntu-24.04 -- wslpath -a "%LOADER_DIR%"`) do set "LINUX_LOADER_DIR=%%P"
if not defined LINUX_LOADER_DIR (
    echo ERROR: Could not translate the loader path for WSL.
    exit /b 1
)

echo Building PowerPC bootstrap...
wsl -d Ubuntu-24.04 -- sh -lc "cd '!LINUX_LOADER_DIR!' && ./build.sh"
if errorlevel 1 (
    echo ERROR: PowerPC bootstrap build failed.
    exit /b 1
)

py "%ROOT%tools\validate_code_pul.py" "%CODE_PUL%"
if errorlevel 1 (
    echo ERROR: Code.pul validation failed.
    exit /b 1
)

if not exist "%PATCHED_DIR%" mkdir "%PATCHED_DIR%"
if errorlevel 1 (
    echo ERROR: Could not create "%PATCHED_DIR%"
    exit /b 1
)

copy /y "%SOURCE_DOL%" "%BACKUP_DOL%" >nul
if errorlevel 1 (
    echo ERROR: Could not back up the clean DOL.
    exit /b 1
)
copy /y "%SOURCE_DOL%" "%PATCHED_DOL%" >nul
if errorlevel 1 (
    echo ERROR: Could not create the patched DOL copy.
    exit /b 1
)

for /f "usebackq delims=" %%H in (`py -c "import os,sys; print(format(os.path.getsize(sys.argv[1]),'x'))" "%LOADER_TEXT%"`) do set "TEXT_HEX=%%H"
for /f "usebackq delims=" %%H in (`py -c "import os,sys; print(format(os.path.getsize(sys.argv[1]),'x'))" "%LOADER_DATA%"`) do set "DATA_HEX=%%H"
if not defined TEXT_HEX (
    echo ERROR: Could not read the bootstrap text size.
    exit /b 1
)
if not defined DATA_HEX (
    echo ERROR: Could not read the bootstrap data size.
    exit /b 1
)

wit dolpatch "%PATCHED_DOL%" "NEW=TEXT,0x80002600,0x!TEXT_HEX!" "LOAD=0x80002600,%LOADER_TEXT%" "NEW=DATA,0x80001C00,0x!DATA_HEX!" "LOAD=0x80001C00,%LOADER_DATA%" 802417DC=4BDC0E24 8000A3B4=4BFF824C
if errorlevel 1 (
    echo ERROR: DOL patching failed.
    exit /b 1
)

copy /y "%PATCHED_DOL%" "%SOURCE_DOL%" >nul
if errorlevel 1 (
    echo ERROR: Could not place the patched DOL in the work directory.
    exit /b 1
)
set "SOURCE_REPLACED=1"

echo Packaging WBFS...
wit "-E$" copy "%WORK_DIR%" -T0 --DEST "%OUTPUT_DIR%\$X" -ovv --links --id RMCETO --ticket-id=RMCR --tmd-id=RMCR --boot-id=RMCE --security-fix --name "Mario Kart Retro Rewind WiiVC Online Test" --wbfs --split
set "BUILD_RC=!ERRORLEVEL!"

copy /y "%BACKUP_DOL%" "%SOURCE_DOL%" >nul
if errorlevel 1 (
    echo ERROR: The build finished, but the clean workdir DOL could not be restored.
    exit /b 1
)
set "SOURCE_REPLACED=0"

if not "!BUILD_RC!"=="0" (
    echo ERROR: WBFS packaging failed with exit code !BUILD_RC!.
    exit /b !BUILD_RC!
)

set "IMAGE="
for %%F in ("%OUTPUT_DIR%\*.wbfs") do if exist "%%~fF" set "IMAGE=%%~fF"
if not defined IMAGE (
    echo ERROR: No WBFS was produced in "%OUTPUT_DIR%".
    exit /b 1
)

wit verify --long "!IMAGE!"
if errorlevel 1 (
    echo ERROR: WBFS verification failed.
    exit /b 1
)

echo.
echo Build complete:
echo "!IMAGE!"
exit /b 0

:fail
set "FAIL_RC=!ERRORLEVEL!"
if "!FAIL_RC!"=="0" set "FAIL_RC=1"
if "!SOURCE_REPLACED!"=="1" copy /y "%BACKUP_DOL%" "%SOURCE_DOL%" >nul
exit /b !FAIL_RC!
