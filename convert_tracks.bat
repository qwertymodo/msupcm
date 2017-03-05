@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF EXIST "%~1" (SET CFGFILE="%~1") ELSE (SET CFGFILE=tracks.cfg)

FOR /f "usebackq delims=" %%x IN (!CFGFILE!) DO (SET line=%%x & IF NOT "!line:~0,1!" == "#" SET "%%x")

ECHO MSU-1 Conversion Script By Qwertymodo
IF NOT "%GAMENAME%" == "" ECHO %GAMENAME%
IF NOT "%PACKNAME%" == "" ECHO %PACKNAME%
IF NOT "%ARTIST%" == "" ECHO Audio by %ARTIST%
IF NOT "%URL%" == "" ECHO %URL%

ECHO.

IF NOT EXIST output MKDIR output

IF "%FIRSTTRACK%" == "" SET FIRSTTRACK=1

FOR /l %%i IN (%FIRSTTRACK%,1,%LASTTRACK%) DO (
    IF "!TRACK%%iFILE!" == "" SET TRACK%%iFILE=%TRACKPREFIX%-%%i.%INPUTFILETYPE%
    IF EXIST "!TRACK%%iFILE!" (
        FOR %%f IN ("!TRACK%%iFILE!") DO SET TRACK%%iTITLE=%%~nf
        ECHO Track %%i: !TRACK%%iTITLE!
        
        IF "!TRACK%%iSTART!" == "" SET TRACK%%iSTART=0
        IF "!TRACK%%iLOOP!" == "" SET TRACK%%iLOOP=!TRACK%%iSTART!
        
        IF NOT "!TRACK%%iCROSSFADE!" == "" (
            SET /A TRACK%%iCROSSFADEASTART=!TRACK%%iTRIM!-!TRACK%%iCROSSFADE!
            SET /A TRACK%%iCROSSFADEBSTART=!TRACK%%iLOOP!-!TRACK%%iCROSSFADE!
            SET /A TRACK%%iCROSSFADEOUT=!TRACK%%iCROSSFADE!/2

            bin\sox "!TRACK%%iFILE!" -r 44.1k output\__track-%%i.wav ^
                gain -h -1 rate trim 0 =!TRACK%%iTRIM!s ^
                fade t 0 !TRACK%%iTRIM!s !TRACK%%iCROSSFADEOUT!s
            bin\sox "!TRACK%%iFILE!" -r 44.1k output\__track-%%i_crossfade.wav ^
                gain -h -1 rate trim !TRACK%%iCROSSFADEBSTART!s =!TRACK%%iLOOP!s ^
                fade t !TRACK%%iCROSSFADE!s pad !TRACK%%iCROSSFADEASTART!s
            FOR %%f IN ("!TRACK%%iFILE!") DO SET TRACK%%iFILE=output\___track-%%i.wav
            bin\sox -m output\__track-%%i.wav output\__track-%%i_crossfade.wav "!TRACK%%iFILE!" gain -h -1

            DEL output\__track-%%i*.wav
        )
        
        IF NOT "!TRACK%%iSTARTPAD!" == "" (
            SET /A TRACK%%iLOOP=!TRACK%%iLOOP!+!TRACK%%iSTARTPAD!
            SET TRACK%%iEFFECTS=!TRACK%%iEFFECTS! pad !TRACK%%iSTARTPAD!s
        )
        
        IF "!OUTPUTPREFIX!" == "" (SET OUTPUTNAME=!TRACK%%iTITLE!) ELSE (SET OUTPUTNAME=%OUTPUTPREFIX%-%%i)

        IF "!TRACK%%iNORMALIZATION!" == "" SET TRACK%%iNORMALIZATION=%NORMALIZATION%
        IF "!TRACK%%iSTART!" == "0" (SET TRACK%%iSTART=0s) ELSE (SET DOTRIM=1 & SET /A TRACK%%iLOOP=!TRACK%%iLOOP!-!TRACK%%iSTART! & SET TRACK%%iSTART=!TRACK%%iSTART!s)
        IF NOT "!TRACK%%iTRIM!" == "" SET DOTRIM=1 & SET TRACK%%iTRIM==!TRACK%%iTRIM!s
        
        IF DEFINED DOTRIM SET TRACK%%iTRIM=rate trim !TRACK%%iSTART! !TRACK%%iTRIM!

        bin\sox.exe !TRACK%%iFORMAT! "!TRACK%%iFILE!" -e signed-integer -L -r 44.1k -b 16 "output\!OUTPUTNAME!.wav" gain -h -1 !TRACK%%iTRIM! !TRACK%%iEFFECTS! !EFFECTS!

        IF NOT "!TRACK%%iNORMALIZATION!" == "" bin\normalize.exe -a !TRACK%%iNORMALIZATION!dBFS "output\!OUTPUTNAME!.wav"

        IF NOT "!TRACK%%iLOOP!" == "" SET TRACK%%iLOOP=-l !TRACK%%iLOOP!

        bin\wav2msu.exe "output\!OUTPUTNAME!.wav" !TRACK%%iLOOP!

        DEL "output\!OUTPUTNAME!.wav"
        IF EXIST "output\___track-%%i.wav" DEL "output\___track-%%i.wav"
    )
)
