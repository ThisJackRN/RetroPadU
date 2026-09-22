@echo off
call create-rr-pal.bat nopause
call create-rr-usa.bat nopause
call create-rr-jpn.bat nopause

if /%1 == /nopause goto nopause
 pause
:nopause
