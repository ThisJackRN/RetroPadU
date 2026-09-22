
	*******************************************
	***** Retro Rewind to Image Converter *****
	*****            by Wiimm             *****
	*******************************************
	*****               for               *****
	*****           Retro Rewind          *****
	*****              by ZPL             *****
	*******************************************

These scripts work only with the pack Retro Rewind.
For other versions the script 'copy-files.*' must be fixed.

Theses scripts are only tested rarely.



-------------------------------------------------------------------------------

1.) Install wit tools: http://wit.wiimm.de/  Then restart PC (Omit this if it is installed)

2.) Copy the Retro Rewind pack into this directory (only 'RetroRewind6/...' is needed).

3.) Copy a backup of the original "Mario Kart Wii" in this directory.
    Supported image formats: iso, wbfs, wdf, wia, ciso

4.) Linux and Mac users only: Execute: chmod a+x *.sh

5.) Call one of these scripts to select the output format: (Omit if you want the .wbfs format)

      set-image-type-ISO.sh   : Linux+Mac: Set output format to plain ISO
      set-image-type-WBFS.sh  : Linux+Mac: Set output format to WBFS
      set-image-type-WDF.sh   : Linux+Mac: Set output format to WDF

      set-image-type-ISO.bat  : Windows: Set output format to plain ISO
      set-image-type-WBFS.bat : Windows: Set output format to WBFS
      set-image-type-WDF.bat  : Windows: Set output format to WDF


6.) Call one of these scripts:

      create-rr-pal.sh  : Linux and Mac users, create a PAL version
      create-rr-usa.sh  : Linux and Mac users, create a NTSC/USA version
      create-rr-jpn.sh  : Linux and Mac users, create a NTSC/JAPAN version

      create-rr-pal.bat : Windows users, create a PAL version
      create-rr-usa.bat : Windows users, create a NTSC/USA version
      create-rr-jpn.bat : Windows users, create a NTSC/JAPAN version

    The scripts will create a new image of selected type.

7.) You will find the new image in the sub directory 'new-image'.

Have fun, Wiimm

