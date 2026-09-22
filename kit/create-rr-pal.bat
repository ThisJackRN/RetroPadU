@echo off
:: (c) 2013-09-25, by Wiimm

::-----------------------------------------------------------------------------
:: settings

set SRC_ID=RMCP01
set SRC_TYPE=PAL
SET BASEVER=EUR
SET GAMEID=RMCP01
SET REGION=P
SET NAND=RetroWFC
SET PCTRACK=RetroRewind
SET PLG=Language
SET PCONFIG=extra
SET PATCHES=neo
SET SAVEPIC=Replace
SET THP=Replace
SET SPLT=--split
SET LANGUAGE=English

set DEST_ID=RMCPTO
set DEST_NAME=Mario Kart Retro Rewind

set IMAGE_TYPE=wbfs

::-----------------------------------------------------------------------------
:: job

ddel -qisa ./workdir.tmp
if not exist RetroRewind6\UI\Title.szs GOTO PACKMISSING
echo USB Loader mode requires use of ISO Loader channel to play.
wit extract . --DEST workdir.tmp --psel data --links --include %SRC_ID% -vv1 -F-.svn/
if errorlevel 1 goto ISOMISSING
if not exist workdir.tmp\setup.txt GOTO ISOMISSING

call .\copy-files.bat

wit -E$ copy workdir.tmp -T0 --DEST new-image/$X -ovv --links --id "%DEST_ID%" --ticket-id=RMCR --tmd-id=RMCR --boot-id=RMC%REGION% --security-fix --name "%DEST_NAME%" --%IMAGE_TYPE% %SPLT%
rmdir workdir.tmp /s /q
rmdir "%PCONFIG%\RetroRewind6" /s /q

:exit
if /%1 == /nopause goto nopause
 pause
:nopause
exit

:PACKMISSING
echo The pack folder "RetroRewind6" is missing. Make sure pack folder is in the same directory as this .bat file.
echo If you don't have it downloaded then go here to download it: https://rwfc.net/downloads
echo The wiki page: https://mkwiiki.org/wiki/Retro_Rewind
pause
exit

:ISOMISSING
echo Could not find a valid Mario Kart Wii image.
echo Make sure to have the image on the same directory and to select the correct region of the image and try again.
echo If 'wit is not recognized' it could mean that Wiimm ISO Tool's not properly installed.
echo The README.txt has the instructions to follow.
pause
exit
