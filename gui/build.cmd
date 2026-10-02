@echo off
rem Builds RetroPadU.exe (the build window) into the RetroPadU folder.
rem Uses the C# compiler that ships with Windows (.NET Framework 4.x). Needs git and
rem Wiimms ISO Tools, which gui\pack-payload.ps1 packs into the exe with the build files.
setlocal
set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
rem A PSModulePath from PowerShell 7 breaks the built-in modules of Windows PowerShell.
set "PSModulePath="
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0pack-payload.ps1" -Out "%~dp0build\payload.zip" || exit /b 1
set "OPTS=/nologo /optimize /target:winexe /platform:anycpu /win32manifest:"%~dp0app.manifest" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll /resource:"%~dp0build\payload.zip",payload.zip"
rem The icon is drawn by the app itself (RetroPadU.exe --write-icon), so build once without it if it is missing.
if not exist "%~dp0RetroPadU.ico" (
    "%CSC%" %OPTS% /out:"%~dp0..\RetroPadU.exe" "%~dp0RetroPadU.cs" || exit /b 1
    "%~dp0..\RetroPadU.exe" --write-icon "%~dp0RetroPadU.ico" || exit /b 1
)
"%CSC%" %OPTS% /win32icon:"%~dp0RetroPadU.ico" /out:"%~dp0..\RetroPadU.exe" "%~dp0RetroPadU.cs"
