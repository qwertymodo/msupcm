@ECHO OFF
SETLOCAL EnableDelayedExpansion
FOR /f "delims=" %%x IN (tracks.cfg) DO (SET line=%%x & IF NOT "!line:~0,1!" == "#" SET "%%x")

FOR /l %%i IN (1,1,%NUMTRACKS%) DO (
    IF "!TRACK%%iFILE!" == "" SET TRACK%%iFILE=%TRACKPREFIX%-%%i.%INPUTFILETYPE%
    IF EXIST "!TRACK%%iFILE!" (
        FOR %%f IN ("!TRACK%%iFILE!") DO (SET TRACK%%iTITLE=%%~nf)
        ECHO !TRACK%%iTITLE!
        IF NOT EXIST output MKDIR output
        
        IF "!OUTPUTPREFIX!" == "" (SET OUTPUTNAME=!TRACK%%iTITLE!) ELSE (SET OUTPUTNAME=%OUTPUTPREFIX%-%%i)

        IF "!TRACK%%iNORMALIZATION!" == "" SET TRACK%%iNORMALIZATION=%NORMALIZATION%
        IF "!TRACK%%iSTART!" == "" (SET TRACK%%iSTART=0s) ELSE (SET DOTRIM=1 & SET /A TRACK%%iLOOP=!TRACK%%iLOOP!-!TRACK%%iSTART! & SET TRACK%%iSTART=!TRACK%%iSTART!s)
        IF NOT "!TRACK%%iTRIM!" == "" SET DOTRIM=1 & SET TRACK%%iTRIM==!TRACK%%iTRIM!s
        
        IF DEFINED DOTRIM SET TRACK%%iTRIM=rate trim !TRACK%%iSTART! !TRACK%%iTRIM!

        bin\sox.exe --norm=-1 !TRACK%%iFORMAT! "!TRACK%%iFILE!" -e signed-integer -L -r 44.1k -b 16 "output\!OUTPUTNAME!.wav" !TRACK%%iTRIM! !EFFECTS! !TRACK%%iEFFECTS!

        IF NOT "!TRACK%%iNORMALIZATION!" == "" bin\normalize.exe -a !TRACK%%iNORMALIZATION!dBFS "output\!OUTPUTNAME!.wav"

        IF NOT "!TRACK%%iLOOP!" == "" SET TRACK%%iLOOP=-l !TRACK%%iLOOP!

        bin\wav2msu.exe "output\!OUTPUTNAME!.wav" !TRACK%%iLOOP!

        DEL "output\!OUTPUTNAME!.wav"
    )
)
