@echo off
:: (c) 2012-09-25, by Wiimm

ren "RetroRewind6/Language/SPA(EU)" "SPAEU"
ren "RetroRewind6/Language/SPA(NTSC)" "SPANTSC"
MKDIR "workdir.tmp\files\Binaries"
MKDIR "workdir.tmp\files\Ghosts"
MKDIR "workdir.tmp\files\Ghosts\ExpertsRT"
MKDIR "workdir.tmp\files\Ghosts\ExpertsCT"
MKDIR "workdir.tmp\files\Jcene"
MKDIR "workdir.tmp\files\Fcene"
MKDIR "workdir.tmp\files\Gcene"
MKDIR "workdir.tmp\files\Dcene"
MKDIR "workdir.tmp\files\Ucene"
MKDIR "workdir.tmp\files\Ecene"
MKDIR "workdir.tmp\files\Ncene"
MKDIR "workdir.tmp\files\Icene"
MKDIR "workdir.tmp\files\Kcene"
MKDIR "workdir.tmp\files\Acene"
MKDIR "workdir.tmp\files\Tcene"
MKDIR "workdir.tmp\files\Ccene"
MKDIR "workdir.tmp\files\Jcene\UI"
MKDIR "workdir.tmp\files\Fcene\UI"
MKDIR "workdir.tmp\files\Gcene\UI"
MKDIR "workdir.tmp\files\Dcene\UI"
MKDIR "workdir.tmp\files\Ucene\UI"
MKDIR "workdir.tmp\files\Ecene\UI"
MKDIR "workdir.tmp\files\Ncene\UI"
MKDIR "workdir.tmp\files\Icene\UI"
MKDIR "workdir.tmp\files\Kcene\UI"
MKDIR "workdir.tmp\files\Acene\UI"
MKDIR "workdir.tmp\files\Tcene\UI"
MKDIR "workdir.tmp\files\Ccene\UI"
MKDIR "workdir.tmp\files\Jace"
MKDIR "workdir.tmp\files\Face"
MKDIR "workdir.tmp\files\Gace"
MKDIR "workdir.tmp\files\Dace"
MKDIR "workdir.tmp\files\Uace"
MKDIR "workdir.tmp\files\Eace"
MKDIR "workdir.tmp\files\Nace"
MKDIR "workdir.tmp\files\Iace"
MKDIR "workdir.tmp\files\Kace"
MKDIR "workdir.tmp\files\Aace"
MKDIR "workdir.tmp\files\Tace"
MKDIR "workdir.tmp\files\Cace"
MKDIR "workdir.tmp\files\patches"
MKDIR "workdir.tmp\files\Race\Map"
MKDIR "workdir.tmp\files\Scene\Model\Driver"
MKDIR "%PCONFIG%\RetroRewind6"
MKDIR "%PCONFIG%\RetroRewind6\Binaries"
IF %PCTRACK%==RetroRewind (
copy /b .\RetroRewind6\Binaries .\%PCONFIG%\RetroRewind6\Binaries
copy /b .\RetroRewind6\Binaries .\workdir.tmp\files\Binaries
copy /b .\RetroRewind6\Character\AllKart .\workdir.tmp\files\Scene\Model\Kart
copy /b .\RetroRewind6\Character .\workdir.tmp\files\Race\Kart
copy /b .\RetroRewind6\Character\MiiOutfitC .\workdir.tmp\files\Race\Kart
copy /b .\RetroRewind6\Character\Driver .\workdir.tmp\files\Scene\Model\Driver
copy /b .\RetroRewind6\Character\Map .\workdir.tmp\files\Race\Map
copy /b .\RetroRewind6\Character\Sound .\workdir.tmp\files\sound
copy /b .\RetroRewind6\Assets .\workdir.tmp\files
copy /b .\Patches .\workdir.tmp\files\patches
copy /b .\RetroRewind6\UI\Font.szs .\workdir.tmp\files\Scene\UI\Font.szs
copy /b .\RetroRewind6\Tracks\ .\workdir.tmp\files\Race\Course\
copy /b .\RetroRewind6\strm\ .\workdir.tmp\files\sound\strm\
if exist .\workdir.tmp\files\patches\*.brstm copy /b .\workdir.tmp\files\patches\*.brstm .\workdir.tmp\files\sound\strm\
if exist .\workdir.tmp\files\patches\revo_kart.brsar copy /b .\workdir.tmp\files\patches\revo_kart.brsar .\workdir.tmp\files\sound\revo_kart.brsar
if exist .\workdir.tmp\files\patches\*.brwsd copy /b .\workdir.tmp\files\patches\*.brwsd .\workdir.tmp\files\sound\
if exist .\workdir.tmp\files\patches\*.brbnk copy /b .\workdir.tmp\files\patches\*.brbnk .\workdir.tmp\files\sound\
if exist .\workdir.tmp\files\patches\*.brseq copy /b .\workdir.tmp\files\patches\*.brseq .\workdir.tmp\files\sound\
if exist .\workdir.tmp\files\patches\*.brstm DEL .\workdir.tmp\files\patches\*.brstm
if exist .\workdir.tmp\files\patches\*.brwsd DEL .\workdir.tmp\files\patches\*.brwsd
if exist .\workdir.tmp\files\patches\*.brbnk DEL .\workdir.tmp\files\patches\*.brbnk
if exist .\workdir.tmp\files\patches\*.brseq DEL .\workdir.tmp\files\patches\*.brseq
if exist .\workdir.tmp\files\patches\revo_kart.brsar DEL .\workdir.tmp\files\patches\revo_kart.brsar
copy /b .\RetroRewind6\CT\Tracks\ .\workdir.tmp\files\Race\Course\
copy /b .\RetroRewind6\BT\Tracks\ .\workdir.tmp\files\Race\Course\
copy /b .\RetroRewind6\Language\JPN\Font\Font.szs .\workdir.tmp\files\Scene\UI\Jont.szs
copy /b .\RetroRewind6\Language\FIN\Font\Font.szs .\workdir.tmp\files\Scene\UI\Iont.szs
copy /b .\RetroRewind6\Language\KOR\Font\Font.szs .\workdir.tmp\files\Scene\UI\Kont.szs
copy /b .\RetroRewind6\Language\RUS\Font\Font.szs .\workdir.tmp\files\Scene\UI\Ront.szs
copy /b .\RetroRewind6\Language\TUR\Font\Font.szs .\workdir.tmp\files\Scene\UI\Tont.szs
copy /b .\RetroRewind6\Language\CZE\Font\Font.szs .\workdir.tmp\files\Scene\UI\Cont.szs
copy /b .\RetroRewind6\Language\JPN\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_J.szs
copy /b .\RetroRewind6\Language\FRA\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_F.szs
copy /b .\RetroRewind6\Language\GER\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_G.szs
copy /b .\RetroRewind6\Language\DUT\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_D.szs
copy /b .\RetroRewind6\Language\SPANTSC\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_AS.szs
copy /b .\RetroRewind6\Language\SPAEU\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_ES.szs
copy /b .\RetroRewind6\Language\FIN\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_FI.szs
copy /b .\RetroRewind6\Language\ITA\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_I.szs
copy /b .\RetroRewind6\Language\KOR\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_K.szs
copy /b .\RetroRewind6\Language\RUS\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_R.szs
copy /b .\RetroRewind6\Language\TUR\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_T.szs
copy /b .\RetroRewind6\Language\CZE\Assets\UIAssets.szs .\workdir.tmp\files\UIAssets_C.szs
copy /b .\RetroRewind6\Language\JPN\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_J.szs
copy /b .\RetroRewind6\Language\FRA\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_F.szs
copy /b .\RetroRewind6\Language\GER\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_G.szs
copy /b .\RetroRewind6\Language\DUT\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_D.szs
copy /b .\RetroRewind6\Language\SPANTSC\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_AS.szs
copy /b .\RetroRewind6\Language\SPAEU\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_ES.szs
copy /b .\RetroRewind6\Language\FIN\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_FI.szs
copy /b .\RetroRewind6\Language\ITA\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_I.szs
copy /b .\RetroRewind6\Language\KOR\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_K.szs
copy /b .\RetroRewind6\Language\RUS\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_R.szs
copy /b .\RetroRewind6\Language\TUR\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_T.szs
copy /b .\RetroRewind6\Language\CZE\Assets\RaceAssets.szs .\workdir.tmp\files\RaceAssets_C.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_E.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_F.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_G.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_I.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_S.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_M.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_Q.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_U.szs
copy /b .\RetroRewind6\Language\JPN\UI\Award_J.szs .\workdir.tmp\files\Jcene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\JPN\UI\Common_J.szs .\workdir.tmp\files\Jace\Common_J.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\JPN\UI\Race_J.szs .\workdir.tmp\files\Jcene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_E.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_F.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_G.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_I.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_S.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_M.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_Q.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_U.szs
copy /b .\RetroRewind6\Language\FRA\UI\Award_F.szs .\workdir.tmp\files\Fcene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\FRA\UI\Common_F.szs .\workdir.tmp\files\Face\Common_J.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\FRA\UI\Race_F.szs .\workdir.tmp\files\Fcene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_E.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_F.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_G.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_I.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_S.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_M.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_Q.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_U.szs
copy /b .\RetroRewind6\Language\GER\UI\Award_G.szs .\workdir.tmp\files\Gcene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\GER\UI\Common_G.szs .\workdir.tmp\files\Gace\Common_J.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\GER\UI\Race_G.szs .\workdir.tmp\files\Gcene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_E.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_F.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_G.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_I.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_S.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_M.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_Q.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_U.szs
copy /b .\RetroRewind6\Language\DUT\UI\Award_D.szs .\workdir.tmp\files\Dcene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\DUT\UI\Common_D.szs .\workdir.tmp\files\Dace\Common_J.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\DUT\UI\Race_D.szs .\workdir.tmp\files\Dcene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_E.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_F.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_G.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_I.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_S.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_M.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_Q.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_U.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Award_ES.szs .\workdir.tmp\files\Ecene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Common_ES.szs .\workdir.tmp\files\Eace\Common_J.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\SPAEU\UI\Race_ES.szs .\workdir.tmp\files\Ecene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_E.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_F.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_G.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_I.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_S.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_M.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_Q.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_U.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Award_AS.szs .\workdir.tmp\files\Ucene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Common_AS.szs .\workdir.tmp\files\Uace\Common_J.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\SPANTSC\UI\Race_AS.szs .\workdir.tmp\files\Ucene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_E.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_F.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_G.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_I.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_S.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_M.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_Q.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_U.szs
copy /b .\RetroRewind6\Language\ITA\UI\Award_I.szs .\workdir.tmp\files\Icene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\ITA\UI\Common_I.szs .\workdir.tmp\files\Iace\Common_J.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\ITA\UI\Race_I.szs .\workdir.tmp\files\Icene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_E.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_F.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_G.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_I.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_S.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_M.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_Q.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_U.szs
copy /b .\RetroRewind6\Language\KOR\UI\Award_K.szs .\workdir.tmp\files\Kcene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\KOR\UI\Common_K.szs .\workdir.tmp\files\Kace\Common_J.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\KOR\UI\Race_K.szs .\workdir.tmp\files\Kcene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_E.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_F.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_G.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_I.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_S.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_M.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_Q.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_U.szs
copy /b .\RetroRewind6\Language\RUS\UI\Award_R.szs .\workdir.tmp\files\Acene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\RUS\UI\Common_R.szs .\workdir.tmp\files\Aace\Common_J.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\RUS\UI\Race_R.szs .\workdir.tmp\files\Acene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_E.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_F.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_G.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_I.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_S.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_M.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_Q.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_U.szs
copy /b .\RetroRewind6\Language\TUR\UI\Award_T.szs .\workdir.tmp\files\Tcene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\TUR\UI\Common_T.szs .\workdir.tmp\files\Tace\Common_J.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\TUR\UI\Race_T.szs .\workdir.tmp\files\Tcene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_E.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_F.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_G.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_I.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_S.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_M.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_Q.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_U.szs
copy /b .\RetroRewind6\Language\CZE\UI\Award_C.szs .\workdir.tmp\files\Ccene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\CZE\UI\Common_C.szs .\workdir.tmp\files\Cace\Common_J.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\CZE\UI\Race_C.szs .\workdir.tmp\files\Ccene\UI\Race_J.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_E.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_F.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_G.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_I.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_S.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_E.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_F.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_G.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_I.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_S.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_M.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_Q.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_U.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_M.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_Q.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_U.szs
copy /b .\RetroRewind6\Language\FIN\UI\Award_FI.szs .\workdir.tmp\files\Ncene\UI\Award_J.szs
copy /b .\RetroRewind6\Language\FIN\UI\Common_FI.szs .\workdir.tmp\files\Nace\Common_J.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_E.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_F.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_G.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_I.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_S.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_U.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_M.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_Q.szs
copy /b .\RetroRewind6\Language\FIN\UI\Race_FI.szs .\workdir.tmp\files\Ncene\UI\Race_J.szs
copy /b .\RetroRewind6\Ghosts\ExpertsRT .\workdir.tmp\files\Ghosts\ExpertsRT
copy /b .\RetroRewind6\Ghosts\ExpertsCT .\workdir.tmp\files\Ghosts\ExpertsCT
ren "RetroRewind6/Language/SPAEU" "SPA(EU)"
ren "RetroRewind6/Language/SPANTSC" "SPA(NTSC)"
GOTO MFILES
)

IF %PCTRACK%==CTs (
copy /b .\RetroRewind6\Binaries .\%PCONFIG%\RetroRewind6\Binaries
copy /b .\RetroRewind6\Binaries .\workdir.tmp\files\Binaries
copy /b .\RetroRewind6\Assets .\workdir.tmp\files
copy /b .\RetroRewind6\CT\Binaries .\%PCONFIG%\RetroRewind6\Binaries
copy /b .\RetroRewind6\CT\Binaries .\workdir.tmp\files\Binaries
copy /b .\RetroRewind6\CT\Assets .\workdir.tmp\files
copy /b .\RetroRewind6\CT\Ghosts\Experts .\workdir.tmp\files\Experts
copy /b .\RetroRewind6\CT\Tracks\ .\workdir.tmp\files\Race\Course\
copy /b .\RetroRewind6\CT\strm\ .\workdir.tmp\files\sound\strm\
GOTO MFILES
)

:MFILES

IF %GAMEID%==RMCP01 (
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\eu\English.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\eu\French.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\eu\Italian.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\eu\German.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\eu\Spanish_EU.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\eu\Dutch.szs
copy /b .\RetroRewind6\UI\Award.szs .\workdir.tmp\files\Scene\UI\Award.szs
copy /b .\RetroRewind6\UI\Title.szs .\workdir.tmp\files\Scene\UI\Title.szs
copy /b .\RetroRewind6\UI\Race.szs .\workdir.tmp\files\Scene\UI\Race.szs
copy /b .\RetroRewind6\UI\Globe.szs .\workdir.tmp\files\Scene\UI\Globe.szs
copy /b .\RetroRewind6\UI\MenuMulti.szs .\workdir.tmp\files\Scene\UI\MenuMulti.szs
copy /b .\RetroRewind6\UI\MenuSingle.szs .\workdir.tmp\files\Scene\UI\MenuSingle.szs
copy /b .\RetroRewind6\UI\Common.szs .\workdir.tmp\files\Race\Common.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_E.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_F.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_G.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_I.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_S.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_E.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_F.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_G.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_I.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_S.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_Q.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_F.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_G.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_I.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_S.szs
GOTO FONT
)

IF %GAMEID%==RMCE01 (
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\us\English.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\us\French.szs
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\us\Spanish_US.szs
copy /b .\RetroRewind6\UI\Award.szs .\workdir.tmp\files\Scene\UI\Award.szs
copy /b .\RetroRewind6\UI\Title.szs .\workdir.tmp\files\Scene\UI\Title.szs
copy /b .\RetroRewind6\UI\Race.szs .\workdir.tmp\files\Scene\UI\Race.szs
copy /b .\RetroRewind6\UI\Globe.szs .\workdir.tmp\files\Scene\UI\Globe.szs
copy /b .\RetroRewind6\UI\MenuMulti.szs .\workdir.tmp\files\Scene\UI\MenuMulti.szs
copy /b .\RetroRewind6\UI\MenuSingle.szs .\workdir.tmp\files\Scene\UI\MenuSingle.szs
copy /b .\RetroRewind6\UI\Common.szs .\workdir.tmp\files\Race\Common.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_M.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_Q.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_U.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_M.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_Q.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_U.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_M.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_Q.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_U.szs
GOTO FONT
)

IF %GAMEID%==RMCJ01 (
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\jp\jp.szs
copy /b .\RetroRewind6\UI\Award.szs .\workdir.tmp\files\Scene\UI\Award.szs
copy /b .\RetroRewind6\UI\Title.szs .\workdir.tmp\files\Scene\UI\Title.szs
copy /b .\RetroRewind6\UI\Race.szs .\workdir.tmp\files\Scene\UI\Race.szs
copy /b .\RetroRewind6\UI\Globe.szs .\workdir.tmp\files\Scene\UI\Globe.szs
copy /b .\RetroRewind6\UI\MenuMulti.szs .\workdir.tmp\files\Scene\UI\MenuMulti.szs
copy /b .\RetroRewind6\UI\MenuSingle.szs .\workdir.tmp\files\Scene\UI\MenuSingle.szs
copy /b .\RetroRewind6\UI\Common.szs .\workdir.tmp\files\Race\Common.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_J.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_J.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_J.szs
GOTO FONT
)

IF %GAMEID%==RMCK01 (
copy /b .\extra\Boot\Strap\Strap.szs .\workdir.tmp\files\Boot\Strap\kr\Korean.szs
copy /b .\RetroRewind6\UI\Award.szs .\workdir.tmp\files\Scene\UI\Award_R.szs
copy /b .\RetroRewind6\UI\Title.szs .\workdir.tmp\files\Scene\UI\Title_R.szs
copy /b .\RetroRewind6\UI\Race.szs .\workdir.tmp\files\Scene\UI\Race_R.szs
copy /b .\RetroRewind6\UI\Globe.szs .\workdir.tmp\files\Scene\UI\Globe_R.szs
copy /b .\RetroRewind6\UI\MenuMulti.szs .\workdir.tmp\files\Scene\UI\MenuMulti_R.szs
copy /b .\RetroRewind6\UI\MenuSingle.szs .\workdir.tmp\files\Scene\UI\MenuSingle_R.szs
copy /b .\RetroRewind6\UI\Common.szs .\workdir.tmp\files\Race\Common.szs
copy /b .\RetroRewind6\UI\Common_U.szs .\workdir.tmp\files\Race\Common_J.szs
copy /b .\RetroRewind6\UI\Title_U.szs .\workdir.tmp\files\Scene\UI\Title_K.szs
copy /b .\RetroRewind6\UI\Race_U.szs .\workdir.tmp\files\Scene\UI\Race_K.szs
GOTO FONT
)

:FONT

IF %THP%==Replace (
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\cup_select.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\banana.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\flower.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\kinoko.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\kohona.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\koura.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\special.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\star.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\course\thunder.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\battle\battle_cup_select.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\battle\battle_retro.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\battle\battle_wii.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\battle\battle_select.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\title\title.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\title\title_50.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\title\title_SD.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\title\title_SD_50.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\title\top_menu.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\ending\ending_normal.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\ending\ending_normal_50.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\ending\ending_true.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\ending\ending_true_50.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\button\class_top.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\button\drift_select.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\button\indiv_team.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\button\multi_top.thp
copy /b .\extra\thp\banana.thp .\workdir.tmp\files\thp\button\single_top.thp
copy /b .\RetroRewind6\UI\transmissionType.thp .\workdir.tmp\files\thp\button\transmissionType.thp
GOTO SAVEBANNER
)

IF %THP%==Skip (
GOTO SAVEBANNER
)

:SAVEBANNER
IF %SAVEPIC%==Replace (
copy /b .\extra\savebanner\ .\workdir.tmp\files\Boot\
GOTO PATCHES
)

IF %SAVEPIC%==Skip (
GOTO PATCHES
)

:PATCHES
::set mod-specific variables before patching and building
IF %PATCHES%==neo (
copy /b .\extra\thp\bi2.bin .\workdir.tmp\sys\
copy /b .\extra\Boot\Loaders\%BASEVER%\Main.dol .\workdir.tmp\sys\
wit dolpatch workdir.tmp/sys/main.dol 80005EFC=0000000A
)
