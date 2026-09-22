Just merge these files with Retro Rewind Pack assuming you already downloaded it.
If you don't have it, don't worry just follow this link so you can download it.

https://rwfc.net/downloads

This is fully experimental, don't expect to be fully working.

Make sure you also copy the extra folder as it contain the important patches needed for the ISO/wbfs.

For more in depth instructions, you can visit my old guide from 10 years ago here: https://mega.nz/file/CPIlzC7S#WhMhKN5AshZsyGVFJjavYyPIZSMjIv0Q2O_ASpweAmw

About RetroWFC update of 3/20/2025

Seems that they are checking if memory patches are present, if some are missing you'll get error code 61010
There is no fix if they add more patches so keep in mind that this version should not last forever.

Wii virtual console inject version cannot use any of the memory patches as including them result on black screen on boot.
To patch it on Wiimm edition open on notepad "create-rr-xxx.bat" and locate SET PATCHES=neo, change neo to wvc and save it.
Also make sure to include the pack riivolution folder as well to be able to apply patches. If it is hard then consider using the normal version instead.

About USB Loader "Disable all cheatcode" error
This should only happens if you load any USB Loader from the Homebrew Channel as it would stay on memory, there is no space in RAM to load properly the pack and result in this error.
To solve this issue you must load USB Loader from the Wii system menu. You can also use a custom Wii channel that auto boot designated game directly a.k.a as ISO Loader channel.

Here is the ISO Loader channel prepared to load Retro Rewind directly from Wii system menu: http://bit.ly/3J4auhe

Instruction on setting up the ISO Loader channel (must do this one time)
1- Install the correct WAD for the console and images version you plan to use
2- Make sure Your USB Loader and the patched ISO is correctly set up.
3- Start up Your USB Loader to refresh titlelist and see if Retro Rewind is on there, then exit Your USB Loader to system menu
4- If everything is correct on step 3, start up the Retro Rewind ISO Loader channel and it should load correctly.

Now keep in mind that: (This only applies to USB Loader, NOT Dolphin)

-Installing to ISO is not 100% guaranteed but may work (NTSC-J works now only if Wii is set to 16:9)
-Online is available, You need the latest build otherwise you'll get error code 22010 or not work properly
-Pack specific configuration is not supported meaning you need to set up options everytime.
-This can be reused unless a minor update like a new language get's added
-The USB Loader version is NOT guaranteed to work in the future if more memory patches is being added as there is no more space anymore.

With all that info i guess you want to continue, instruction are below.


It is compatible any region 

ISO Patching Instructions

1.) Install wit and szs tools: (Omit this step if you have it installed already)
http://wit.wiimm.de 
http://szs.wiimm.de 
Restart Computer

2.) Copy a backup of the original "Mario Kart Wii" in this directory.
    Supported image formats: iso, wbfs, wdf, wia, ciso

3.) Click on Build ISO RetroRewind.bat

4.) Answer all questions it asks you.

5.) You found the new image in the sub directory 'new-image'

Have fun.

Save Data Folder=524d4352