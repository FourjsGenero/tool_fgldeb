@echo off
@echo off
setlocal EnableExtensions

rem get unique file name 
:loop
set randbase=gen~%RANDOM%
set extractor="%tmp%\%randbase%.4gl"
set extractor42m="%tmp%\%randbase%.42m"
rem important: without quotes 
set _TMPDIR=%tmp%\%randbase%_d
set _IS_BAT_FILE=TRUE
if exist %extractor% goto :loop
if exist %extractor42m% goto :loop
if exist %_TMPDIR% goto :loop
rem echo tmp=%tmp%

set tmpdrive=%tmp:~0,2%
set _CATFILE=%~dpnx0
rem We use a small line extractor program in 4gl to a temp file
rem the bat only solutions at 
rem https://stackoverflow.com/questions/7954719/how-can-a-batch-script-do-the-equivalent-of-cat-eof
rem are too slow for bigger programs, so 4gl rules !

echo # Extractor coming from catsource.bat > %extractor%
echo --note: some 4gl constructs in this file are there to surround the pitfalls >> %extractor%
echo --of echo'ing this file with the windows echo command to a temp 4gl file >> %extractor%
echo --percent signs are avoided as well as or signs, thats why we avoid >> %extractor%
echo --the sfmt operator and the cat operator and mixing quotes with double quotes >> %extractor%
echo OPTIONS SHORT CIRCUIT >> %extractor%
echo IMPORT util >> %extractor%
echo IMPORT os >> %extractor%
echo DEFINE tmpdir,fname,full,lastmodule STRING >> %extractor%
echo DEFINE m_bat INT >> %extractor%
echo DEFINE singlequote,doublequote,backslash,percent,dollar STRING >> %extractor%
echo DEFINE m_binTypeArr,m_resTypeArr,m_imgarr,m_resarr DYNAMIC ARRAY OF STRING >> %extractor%
echo MAIN >> %extractor%
echo   DEFINE line,err,catfile STRING >> %extractor%
echo   DEFINE ch,chw base.Channel >> %extractor%
echo   DEFINE sb base.StringBuffer >> %extractor%
echo   DEFINE write,writebin INT >> %extractor%
echo   LET singlequote=ASCII(39) >> %extractor%
echo   LET doublequote=ASCII(34) >> %extractor%
echo   LET backslash=ASCII(92) --we must not use the literal here >> %extractor%
echo   LET percent=ASCII(37) >> %extractor%
echo   LET dollar=ASCII(36) >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='png'  >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='jpg' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='bmp' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='gif' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='tiff' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='wav' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='mp3' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='aiff' >> %extractor%
echo   LET m_binTypeArr[m_binTypeArr.getLength()+1]='mpg' >> %extractor%
echo -- >> %extractor%
echo   LET m_resTypeArr[m_resTypeArr.getLength()+1]='per'  >> %extractor%
echo   LET m_resTypeArr[m_resTypeArr.getLength()+1]='4st' >> %extractor%
echo   LET m_resTypeArr[m_resTypeArr.getLength()+1]='4tb' >> %extractor%
echo   LET m_resTypeArr[m_resTypeArr.getLength()+1]='4tm' >> %extractor%
echo   LET m_resTypeArr[m_resTypeArr.getLength()+1]='4sm' >> %extractor%
echo   LET m_resTypeArr[m_resTypeArr.getLength()+1]='iem' >> %extractor%
echo   LET sb=base.StringBuffer.create() >> %extractor%
echo   LET catfile=fgl_getenv("_CATFILE") --set by calling script >> %extractor%
echo   LET tmpdir=fgl_getenv("_TMPDIR") --set by calling script >> %extractor%
echo   LET m_bat=fgl_getenv("_IS_BAT_FILE") IS NOT NULL >> %extractor%
echo   IF catfile IS NULL OR tmpdir IS NULL THEN >> %extractor%
echo     CALL myerr("_CATFILE or _TMPDIR not set") >> %extractor%
echo   END IF >> %extractor%
echo   IF catfile IS NULL THEN >> %extractor%
echo     LET catfile=arg_val(1) >> %extractor%
echo     LET tmpdir=arg_val(2) >> %extractor%
echo   END IF >> %extractor%
echo   IF NOT m_bat THEN --windows fullPath is clumsy >> %extractor%
echo     LET tmpdir=os.Path.fullPath(tmpdir) >> %extractor%
echo   END IF >> %extractor%
echo   LET ch=base.Channel.create() >> %extractor%
echo   LET chw=base.Channel.create() >> %extractor%
echo   IF NOT os.Path.exists(tmpdir) THEN >> %extractor%
echo     IF NOT os.Path.mkdir(tmpdir) THEN >> %extractor%
echo       LET err="Can't mkdir :",tmpdir >> %extractor%
echo       CALL myerr(err) >> %extractor%
echo     END IF >> %extractor%
echo   END IF >> %extractor%
echo   CALL ch.openFile(catfile,"r") >> %extractor%
echo   WHILE (line:=ch.readLine()) IS NOT NULL >> %extractor%
echo     CASE >> %extractor%
echo        WHEN m_bat AND line.getIndexOf("rem __CAT_EOF_BEGIN__:",1)==1 >> %extractor%
echo          LET fname=line.subString(23,line.getLength()) >> %extractor%
echo          GOTO mark1 >> %extractor%
echo        WHEN (NOT m_bat) AND  line.getIndexOf("#__CAT_EOF_BEGIN__:",1)==1 >> %extractor%
echo          LET fname=line.subString(20,line.getLength()) >> %extractor%
echo        LABEL mark1: >> %extractor%
echo          LET full=os.Path.join(tmpdir,fname) >> %extractor%
echo          CALL checkSubdirs() >> %extractor%
echo          IF isBinary(fname) THEN >> %extractor%
echo            LET writebin=TRUE >> %extractor%
echo            CALL addDir(m_imgarr,os.Path.dirName(fname)) >> %extractor%
echo            CALL sb.clear() >> %extractor%
echo          ELSE >> %extractor%
echo            IF isResource(fname) THEN >> %extractor%
echo              CALL addDir(m_resarr,os.Path.dirName(fname)) >> %extractor%
echo            END IF >> %extractor%
echo            LET write=TRUE >> %extractor%
echo            CALL chw.openFile(full,"w") >> %extractor%
echo          END IF >> %extractor%
echo        WHEN ((NOT m_bat) AND line=="#__CAT_EOF_END__") OR >> %extractor%
echo             (m_bat AND line=="rem __CAT_EOF_END__") >> %extractor%
echo          IF writebin THEN >> %extractor%
echo            LET writebin=FALSE >> %extractor%
echo            CALL util.Strings.base64Decode(sb.toString(),full) >> %extractor%
echo          ELSE >> %extractor%
echo            LET write=FALSE >> %extractor%
echo            CALL chw.close() >> %extractor%
echo            CALL eventuallyCompileFile() >> %extractor%
echo          END IF >> %extractor%
echo        WHEN writebin >> %extractor%
echo          CALL sb.append(line.subString(IIF(m_bat,5,2),line.getLength())) >> %extractor%
echo        WHEN write >> %extractor%
echo          CALL chw.writeLine(line.subString(IIF(m_bat,5,2),line.getLength())) >> %extractor%
echo     END CASE >> %extractor%
echo   END WHILE >> %extractor%
echo   CALL ch.close() >> %extractor%
echo   CALL runLastModule() >> %extractor%
echo END MAIN >> %extractor%
echo -- >> %extractor%
echo FUNCTION addDir(arr,dirname) >> %extractor%
echo   DEFINE arr DYNAMIC ARRAY OF STRING >> %extractor%
echo   DEFINE dirname STRING >> %extractor%
echo   DEFINE i INT >> %extractor%
echo   FOR i=1 TO arr.getLength() >> %extractor%
echo     IF arr[i]=dirname THEN >> %extractor%
echo       RETURN --already contained >> %extractor%
echo     END IF >> %extractor%
echo   END FOR >> %extractor%
echo   LET arr[arr.getLength()+1]=dirname >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION setPathFor(arr,envName,cmd) >> %extractor%
echo   DEFINE arr DYNAMIC ARRAY OF STRING >> %extractor%
echo   DEFINE envName,tmp STRING >> %extractor%
echo   DEFINE cmd STRING >> %extractor%
echo   DEFINE i INT >> %extractor%
echo   IF arr.getLength()>0 THEN >> %extractor%
echo     LET tmp=envName,"=" >> %extractor%
echo     LET cmd=cmd,IIF(m_bat,"set ",""),tmp >> %extractor%
echo     IF fgl_getenv(envName) IS NOT NULL THEN >> %extractor%
echo       IF m_bat THEN >> %extractor%
echo         LET cmd=percent,envName,percent,";" >> %extractor%
echo       ELSE >> %extractor%
echo         LET cmd=dollar,envName,":" >> %extractor%
echo       END IF >> %extractor%
echo     END IF >> %extractor%
echo     FOR i=1 TO arr.getLength() >> %extractor%
echo         IF i>1 THEN >> %extractor%
echo           LET cmd=cmd,IIF(m_bat,";",":") >> %extractor%
echo         END IF >> %extractor%
echo         LET cmd=cmd,quotePath(os.Path.join(tmpdir,arr[i])) >> %extractor%
echo     END FOR >> %extractor%
echo     LET cmd=cmd,IIF(m_bat,"&&"," ") >> %extractor%
echo   END IF >> %extractor%
echo   RETURN cmd >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION runLastModule() --we must get argument quoting right >> %extractor%
echo   DEFINE i INT >> %extractor%
echo   DEFINE arg,cmd,cmdsave,image2font STRING >> %extractor%
echo   IF lastmodule IS NULL THEN RETURN END IF >> %extractor%
echo   LET cmd=setPathFor(m_resarr,"FGLRESOURCEPATH",cmd) >> %extractor%
echo   LET image2font=os.Path.join(os.Path.join(fgl_getenv("FGLDIR"),"lib"),"image2font.txt") >> %extractor%
echo   LET cmdsave=cmd >> %extractor%
echo   LET cmd=setPathFor(m_imgarr,"FGLIMAGEPATH",cmd) >> %extractor%
echo   IF cmd!=cmdsave AND os.Path.exists(image2font) THEN >> %extractor%
echo     IF m_bat THEN >> %extractor%
echo       LET cmd=cmd.subString(1,cmd.getLength()-2),";",quotePath(image2font),"&&" >> %extractor%
echo     ELSE >> %extractor%
echo       LET cmd=cmd.subString(1,cmd.getLength()-1),":",quotePath(image2font)," " >> %extractor%
echo     END IF >> %extractor%
echo   END IF >> %extractor%
echo   LET cmd=cmd,"fglrun ",os.Path.join(tmpdir,lastmodule) >> %extractor%
echo   FOR i=1 TO num_args() >> %extractor%
echo     LET arg=arg_val(i) >> %extractor%
echo     CASE >> %extractor%
echo       WHEN m_bat AND arg.getIndexOf(' ',1)==0 AND  >> %extractor%
echo                      arg.getIndexOf(doublequote,1)==0 >> %extractor%
echo         LET cmd=cmd,' ',arg --we don't need quotes >> %extractor%
echo       WHEN m_bat OR arg.getIndexOf(singlequote,1)!=0  >> %extractor%
echo         --we must use double quotes on windows >> %extractor%
echo         LET cmd=cmd,' ',doublequote,quoteDouble(arg),doublequote >> %extractor%
echo       OTHERWISE >> %extractor%
echo         --sh: you can't quote single quotes inside single quotes >> %extractor%
echo         --everything else does not need to be quoted >> %extractor%
echo         LET cmd=cmd,' ',singlequote,arg,singlequote >> %extractor%
echo     END CASE >> %extractor%
echo   END FOR >> %extractor%
echo   --DISPLAY "cmd:",cmd >> %extractor%
echo   CALL myrun(cmd) >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION quotePath(p) >> %extractor%
echo   DEFINE p STRING >> %extractor%
echo   --TODO: quote space with backlash space >> %extractor%
echo   --IF NOT m_bat AND p.getIndexOf(" ",1)!=0 >> %extractor%
echo     --RETURN quoteSpace(p) >> %extractor%
echo   --END IF >> %extractor%
echo   RETURN p >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION myerr(err) >> %extractor%
echo   DEFINE err STRING >> %extractor%
echo   DISPLAY "ERROR:",err >> %extractor%
echo   EXIT PROGRAM 1 >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION eventuallyCompileFile() >> %extractor%
echo   DEFINE cmd STRING >> %extractor%
echo   CASE >> %extractor%
echo     WHEN os.Path.extension(fname)=="4gl" >> %extractor%
echo       LET cmd="cd ",tmpdir," && fglcomp -M ",fname >> %extractor%
echo       CALL myrun(cmd) >> %extractor%
echo       --DISPLAY "dirname:",fname,",basename:",os.Path.baseName(fname) >> %extractor%
echo       LET lastmodule=os.Path.baseName(fname) >> %extractor%
echo       --cut extension >> %extractor%
echo       LET lastmodule=lastmodule.subString(1,lastmodule.getLength()-4) >> %extractor%
echo       --DISPLAY "lastmodule=",lastmodule >> %extractor%
echo     WHEN os.Path.extension(fname)=="per" >> %extractor%
echo       LET cmd="cd ",tmpdir," && fglform -M ",fname >> %extractor%
echo       CALL myrun(cmd) >> %extractor%
echo     --other (resource) files are just copied >> %extractor%
echo   END CASE >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION myrun(cmd) >> %extractor%
echo   DEFINE cmd STRING, code INT >> %extractor%
echo   --DISPLAY "myrun:",cmd >> %extractor%
echo   RUN cmd RETURNING code >> %extractor%
echo   IF code THEN >> %extractor%
echo     EXIT PROGRAM 1 >> %extractor%
echo   END IF >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION checkSubdirs() >> %extractor%
echo   DEFINE i,found INT >> %extractor%
echo   DEFINE dir,err STRING >> %extractor%
echo   DEFINE dirs DYNAMIC ARRAY OF STRING >> %extractor%
echo   LET dir=os.Path.fullPath(os.Path.dirName(full)) >> %extractor%
echo   WHILE TRUE >> %extractor%
echo     CASE >> %extractor%
echo       WHEN dir IS NULL >> %extractor%
echo         EXIT WHILE >> %extractor%
echo       WHEN dir==tmpdir >> %extractor%
echo         LET found=true >> %extractor%
echo         EXIT WHILE >> %extractor%
echo       OTHERWISE >> %extractor%
echo         CALL dirs.insertElement(1) >> %extractor%
echo         LET dirs[1]=dir >> %extractor%
echo     END CASE >> %extractor%
echo     LET dir=os.Path.fullPath(os.Path.dirName(dir)) >> %extractor%
echo   END WHILE >> %extractor%
echo   IF NOT found THEN >> %extractor%
echo     --we can't use sfmt because of .bat echo pitfalls >> %extractor%
echo     LET err=singlequote,fname,singlequote,' does point outside' >> %extractor%
echo     CALL myerr(err) >> %extractor%
echo   END IF >> %extractor%
echo   FOR i=1 TO dirs.getLength() >> %extractor%
echo     LET dir=dirs[i] >> %extractor%
echo     IF NOT os.Path.exists(dir) THEN >> %extractor%
echo       IF NOT os.Path.mkdir(dir) THEN >> %extractor%
echo         LET err="Can't create directory:",dir >> %extractor%
echo         CALL myerr(err) >> %extractor%
echo       END IF >> %extractor%
echo     END IF >> %extractor%
echo   END FOR >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION quoteDouble(s) >> %extractor%
echo   DEFINE s STRING >> %extractor%
echo   DEFINE c STRING >> %extractor%
echo   DEFINE i INT >> %extractor%
echo   DEFINE sb base.StringBuffer >> %extractor%
echo   LET sb=base.StringBuffer.create() >> %extractor%
echo   FOR i=1 TO s.getLength() >> %extractor%
echo     LET c=s.getCharAt(i) >> %extractor%
echo     CASE >> %extractor%
echo       WHEN c==doublequote >> %extractor%
echo         CALL sb.append(backslash) >> %extractor%
echo       WHEN (NOT m_bat) AND  c==backslash >> %extractor%
echo         CALL sb.append(backslash) >> %extractor%
echo     END CASE >> %extractor%
echo     CALL sb.append(c) >> %extractor%
echo   END FOR >> %extractor%
echo   RETURN sb.toString() >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION isInArray(arr,fname) >> %extractor%
echo   DEFINE arr DYNAMIC ARRAY OF STRING >> %extractor%
echo   DEFINE fname,ext STRING >> %extractor%
echo   DEFINE i INT >> %extractor%
echo   LET ext=os.Path.extension(fname) >> %extractor%
echo   FOR i=1 TO arr.getLength() >> %extractor%
echo     IF arr[i]==ext THEN  >> %extractor%
echo       RETURN TRUE >> %extractor%
echo     END IF >> %extractor%
echo   END FOR >> %extractor%
echo   RETURN FALSE >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION isBinary(fname) >> %extractor%
echo   DEFINE fname STRING >> %extractor%
echo   RETURN isInArray(m_binTypeArr,fname) >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
echo FUNCTION isResource(fname) >> %extractor%
echo   DEFINE fname STRING >> %extractor%
echo   RETURN isInArray(m_resTypeArr,fname) >> %extractor%
echo END FUNCTION >> %extractor%
echo -- >> %extractor%
set mydir=%cd%
set mydrive=%~d0
%tmpdrive%
cd %tmp%
fglcomp -M %randbase%
if ERRORLEVEL 1 exit /b
del %extractor%
rem extract the 4gl code behind us to another 4GL file
%mydrive%
cd %mydir%
fglrun %extractor42m% %1 %2 %3 %4 %5
if ERRORLEVEL 1 exit /b
del %extractor42m%
exit /b
rem __CAT_EOF_BEGIN__:icons/debug_break.png
rem iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMBAMAAACkW0HUAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAABB0
rem Uk5T////////////////////AOAjXRkAAAABYktHRA8YugDZAAAACXBIWXMAABJyAAAScgFeZVvj
rem AAAALklEQVQIW2P4DwYM//9/FARRHyVnCoKomTMnAinJmTNnyqNTUDmoSqg+mCkgGgCabDW5XAvf
rem 6AAAAABJRU5ErkJggg==
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_break_disabled.png
rem iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMBAMAAACkW0HUAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAABB0
rem Uk5T////////////////////AOAjXRkAAAABYktHRA8YugDZAAAACXBIWXMAABJyAAAScgFeZVvj
rem AAAAKklEQVQIHQXBAQEAAAgCIC+0wP/zXEAQIOyI1YkxUTSKRtEYE6sTdgQI8M6vPJH6WTkbAAAA
rem AElFTkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_break_disabled_marker.png
rem iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMBAMAAACgrpHpAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAABB0
rem Uk5T////////////////////AOAjXRkAAAABYktHRA8YugDZAAAACXBIWXMAABJyAAAScgFeZVvj
rem AAAAO0lEQVR42kWMMQoAMAgD09lB+gL/v7n7Kl+QqiA9hCNEBaks0HOtLYdpAMRJg0SEMsde3rz9
rem 7u/9/zc8vwg2mP4aLQ8AAAAASUVORK5CYII=
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_break_marker.png
rem iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMBAMAAACgrpHpAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAABB0
rem Uk5T////////////////////AOAjXRkAAAABYktHRA8YugDZAAAACXBIWXMAABJyAAAScgFeZVvj
rem AAAAO0lEQVQIW2P4/5//PxAwgJCgPIjmZpw5UZ6BgYF7w8yZ8gzcu3fv5pw5EUxvgNIgPkweph6h
rem H2YeGAAAqxExFnEl46cAAAAASUVORK5CYII=
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_find.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAMFBMVEUAAACAAAAAgACAgAAAAICA
rem AIAAgIDAwMCAgID/AAAA/wD//wAAAP//AP8A//////9PEyZJAAAAC3RSTlP/////////////AEpP
rem AfIAAAAJcEhZcwAACnUAAAp1AUol3f0AAAA9SURBVHjaVYsxCgAwCANvdvH/m7Ov6xPq0UJpiOEw
rem hL6iCy2s8feBGA8kkUKhLBaVEB9wwPBcuHyAYNVXG6ThJVT+F6ySAAAAAElFTkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_hand.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAMFBMVEUAAACAAAAAgACAgAAAAICA
rem AIAAgIDAwMCAgID/AAAA/wD//wAAAP//AP8A//////9PEyZJAAAAC3RSTlP/////////////AEpP
rem AfIAAAAJcEhZcwAACnUAAAp1AUol3f0AAAA9SURBVHjaXckxDgAwCAJAZpf+f3P2dfyAVqNNUwZy
rem AUSE26kEaAUneWEDPnAMhL4WJSVcP2I1arICgERnA1iMVIksXpxXAAAAAElFTkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_logo.png
rem iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAIAAAD9b0jDAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlz
rem AAAOwgAADsIBFShKgAAAAAZ0Uk5TAP8AAAD/icAvkAAAAAZiS0dEAP8A/wD/oL2nkwAAAvBJREFU
rem eNqtlu9LU2EUx+9f06tK0nBLnT8aTJ1Tc3NT55hTp6vYujnncFoqSkkqtcItbMty/gBZE0cSqFhD
rem CaJcL1wU+qIg9iY0X0mRwuyLD12euDefIR0eHs52z/3cc77n2bnjDrnD/77Y0D7K0oUyWRxlAvok
rem UJr1V/Qf6+3tZULFRIYsCOi/38aGiolMLoLZUEL8tfeDSdz8tEW46UITiQQTGp55RifLhi4uLq6u
rem vTwGvfEu0e26AQftklSWE6uZTCYdNlto4onOqq1yGKo9xsqbdQq+tKgxr0Sv7L7VZTKZXi3F6FvY
rem UKzQZMjS3GgbvB7f35z/vtaxfMcc7uB9dn1XBZ5El5wuVOB2LwygOnzpXLqGSuHI+7M0TZrd7b0T
rem QrH4hR7XhyHjW7dh3c31cdkPTzcGTTnFCvoWBlQcZA20oeqSaTN3ZLbZBigAQek0UQEDiggairZU
rem 85rKq0VKUyZ0UDoKssozIQsFZR0pWqO91MHn5FfSa+BW1sPYtZ06We0F93CnqCwWlCSLnef5FxvL
rem q7vxp1vR2++DPR+D6Jt9xqV0qTjB0oSCRVIA4stBMh6Pr3x7AyKWZcHpeO0xzTdzsMJCbMRhawqK
rem kC8x/8wwavf4eBwDfBRYWHlHBuefUMyRVCpFftdIdjw+KzmkUQGJl+DSULEC2JGyMWJvWr7SR1nd
rem SotmTC+vkR/HFUOH/MNEAQwUyHdprjZjojRvtEQ1kF8xqVVOqXXjdRkVZxEgzRVDI5EIcZxOp93M
rem 49iDIgvkyu8qiz05qoAKftUjncKYa7U0eO+NSnNp6P7hz53tHTherxf0aDSKpJCmIVzeHNJV+TSq
rem 52rZWHbrY0N+/ZnpuQCeijBJrsTrRPBxJC+OqoseZJn9ZU1RPZzWqfpiqwoSCfMf8RJcmjgyMkLT
rem W9zW3MsKpAYo8rUHaiyD2vau9lgsJoRh7Ir0paCk4zSU9O1c2Sm9S41JWm7LKdCeJ5fApd8rNJfx
rem ZwL7ya7+Bkh3B7Qeq2f0AAAAAElFTkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_mag.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAMFBMVEUAAACAAAAAgACAgAAAAICA
rem AIAAgIDAwMCAgID/AAAA/wD//wAAAP//AP8A//////9PEyZJAAAAC3RSTlP/////////////AEpP
rem AfIAAAAJcEhZcwAACnUAAAp1AUol3f0AAABPSURBVAhbTcwhDsAgEETRcZA1vSpuJKs5BZL8CyJb
rem QxPcU0+QqoCYxS1A1Hc7QevZdhtodtuOG76xA61i9zYQ1d75hwoEqTqFAEBxMHWAPp6BO1UUEYID
rem AAAAAElFTkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_marker.png
rem iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMBAMAAACkW0HUAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAABB0
rem Uk5T////////////////////AOAjXRkAAAABYktHRA8YugDZAAAACXBIWXMAAAp0AAAKdAGYYj8Z
rem AAAAMUlEQVQIHQXBQQEAMBACIBtc/xb7W8oGDMIQdoQ9sqQna/tkbXtZ2ydLesIeYUcYAnxV2zn8
rem 1L8KgAAAAABJRU5ErkJggg==
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_printer.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAJFBMVEUAAACAAAAAgACAgAAAAICA
rem AIAAgIDAwMCAgID/AAAA/wD//wD6/7E/AAAAC3RSTlP/////////////AEpPAfIAAAAJcEhZcwAA
rem CnUAAAp1AUol3f0AAABVSURBVAhbNYqxDYBADMQsUQSFZSh/rHSHxAKMkfoqepajeHBlycZuAGOz
rem 3Z/AksYdUqWZC4nXMcZeRQNEQEhSVTGJIqTjUiQhnY/IPyU9Z2MA0vjjBdHbIsrk6XPMAAAAAElF
rem TkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_quest.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAJFBMVEUAAACAAAAAgACAgAAAAICA
rem AIAAgIDAwMCAgID/AAAA/wD//wD6/7E/AAAAC3RSTlP/////////////AEpPAfIAAAAJcEhZcwAA
rem CnUAAAp1AUol3f0AAAA7SURBVAhbdYuhDQBBDMOCm/15sFF5lztQ9dkzy7IFkQoEnhGIjNyFSFcO
rem 1qBsA+69sPiD1JkvPsg1ADxhTD1aHVAv+gAAAABJRU5ErkJggg==
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_restart.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAAXNSR0IArs4c6QAAAARnQU1BAACx
rem jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlz
rem AAAOxAAADsQBlSsOGwAAAGVJREFUeNqtkt0JwCAQgzO6a3QDHzpQVyi4gw2IV4/AYasfQQ5JCP6g
rem fgRnPgIBieLgAuW+VNw365hBmxSauL4+JBdAJwisNRB4LMDBaabB3FHDwhkMDQQNZPct7X4HRf/S
rem z9/6ANS5LVdL6EHNAAAAAElFTkSuQmCC
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_run.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAwBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAwMDAwNzApsrwQCAAYCAAgCAAoCAAwCAA4CAAAEAAIEAAQEAA
rem YEAAgEAAoEAAwEAA4EAAAGAAIGAAQGAAYGAAgGAAoGAAwGAA4GAAAIAAIIAAQIAAYIAAgIAAoIAA
rem wIAA4IAAAKAAIKAAQKAAYKAAgKAAoKAAwKAA4KAAAMAAIMAAQMAAYMAAgMAAoMAAwMAA4MAAAOAA
rem IOAAQOAAYOAAgOAAoOAAwOAA4OAAAABAIABAQABAYABAgABAoABAwABA4ABAACBAICBAQCBAYCBA
rem gCBAoCBAwCBA4CBAAEBAIEBAQEBAYEBAgEBAoEBAwEBA4EBAAGBAIGBAQGBAYGBAgGBAoGBAwGBA
rem 4GBAAIBAIIBAQIBAYIBAgIBAoIBAwIBA4IBAAKBAIKBAQKBAYKBAgKBAoKBAwKBA4KBAAMBAIMBA
rem QMBAYMBAgMBAoMBAwMBA4MBAAOBAIOBAQOBAYOBAgOBAoOBAwOBA4OBAAACAIACAQACAYACAgACA
rem oACAwACA4ACAACCAICCAQCCAYCCAgCCAoCCAwCCA4CCAAECAIECAQECAYECAgECAoECAwECA4ECA
rem AGCAIGCAQGCAYGCAgGCAoGCAwGCA4GCAAICAIICAQICAYICAgICAoICAwICA4ICAAKCAIKCAQKCA
rem YKCAgKCAoKCAwKCA4KCAAMCAIMCAQMCAYMCAgMCAoMCAwMCA4MCAAOCAIOCAQOCAYOCAgOCAoOCA
rem wOCA4OCAAADAIADAQADAYADAgADAoADAwADA4ADAACDAICDAQCDAYCDAgCDAoCDAwCDA4CDAAEDA
rem IEDAQEDAYEDAgEDAoEDAwEDA4EDAAGDAIGDAQGDAYGDAgGDAoGDAwGDA4GDAAIDAIIDAQIDAYIDA
rem gIDAoIDAwIDA4IDAAKDAIKDAQKDAYKDAgKDAoKDAwKDA4KDAAMDAIMDAQMDAYMDAgMDAoMDA//vw
rem oKCkgICA/wAAAP8A//8AAAD//wD/AP//////WNI0RAAAAQB0Uk5T////////////////////////
rem ////////////////////////////////////////////////////////////////////////////
rem ////////////////////////////////////////////////////////////////////////////
rem ////////////////////////////////////////////////////////////////////////////
rem ////////////////////////////////////////////////////////////////////////////
rem ////////////AFP3ByUAAAABYktHRP+lB/LFAAAACXBIWXMAABJyAAAScgFeZVvjAAAAWUlEQVQY
rem GQXBsQ0AMAjAsEgM/f8HvmRw7cACECsJkH3ZEpBIXkDbltoC9agQqM2St0R6u5pSl7K13axuklJN
rem KRVoTuWmQNM51xTQzWgugW7qaqaA0qQEoIIPm+SYLn0ZGakAAAAASUVORK5CYII=
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_runtocursor.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAAAl0
rem Uk5T//////////8AU094EgAAAAFiS0dEDxi6ANkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAzSURB
rem VAhbY+iAAgYsDA8gbuAAEi5AEkgxuLg4QBhwkQ4PGAOssYGDAURARfAwYCajWwoAaA02gbOx1jQA
rem AAAASUVORK5CYII=
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_stepinto.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAAAl0
rem Uk5T//////////8AU094EgAAAAFiS0dEDxi6ANkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA+SURB
rem VAgdBcGhAcBADAChkxnsRcaKqGDsQu+9hfBBsIjsjdxYyY2V3Ly3yc33JLFucoPkBskNkhsk4kYA
rem AfyntjTxEBOGnAAAAABJRU5ErkJggg==
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_stepout.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAAAl0
rem Uk5T//////////8AU094EgAAAAFiS0dEDxi6ANkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA8SURB
rem VAhbfcmhDcBADATBgy7MwGUZPJiyQ14BAVk00ga6R3A4gsHE1oSJmK0PbHVfnM4W8i5+sSWI24sH
rem cQo0cRfguvoAAAAASUVORK5CYII=
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:icons/debug_stepover.png
rem iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
rem AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADBQTFRF
rem AAAAgAAAAIAAgIAAAACAgACAAICAgICAwMDA/wAAAP8A//8AAAD//wD/AP//////ex+xxAAAAAl0
rem Uk5T//////////8AU094EgAAAAFiS0dEDxi6ANkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA7SURB
rem VAhbY2hxAQKPjg4GIO7oaAEyOsDAA8ho4GCAMEBMTAZQH4TR4tLBABQHsuFqOvAzwCbD7UJiAABT
rem ejRpyWJ7hgAAAABJRU5ErkJggg==
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb.per
rem TOPMENU
rem   GROUP top_file (TEXT="File")
rem     --COMMAND save_state    (TEXT="Save breakpoints")
rem     COMMAND restore_breakpoints (TEXT="Load breakpoints")
rem     COMMAND quit (TEXT="Exit")
rem   END
rem   GROUP edit (TEXT="Edit")
rem     COMMAND find
rem     COMMAND findnext
rem   END
rem   GROUP edit (TEXT="View")
rem     COMMAND inspectvariable 
rem     COMMAND viewstack     (TEXT="Stack...")
rem     COMMAND viewbreak     (TEXT="Breakpoints...")
rem     COMMAND viewmodules   (TEXT="Modules...")
rem     COMMAND viewfunctions (TEXT="Functions...")
rem     COMMAND viewglobals   
rem     COMMAND viewlocals   
rem     COMMAND viewwatchlist (TEXT="Watches...") 
rem   END
rem   GROUP run (TEXT="Run")
rem     COMMAND run 
rem     COMMAND run_args
rem     SEPARATOR
rem     COMMAND stepinto 
rem     COMMAND stepover 
rem     COMMAND stepout 
rem     SEPARATOR
rem     COMMAND fdbcommand 
rem   END
rem   GROUP breakpoints (TEXT="Breakpoints")
rem     COMMAND togglebreak 
rem     COMMAND togglebreakdisable 
rem     COMMAND addbreak 
rem     COMMAND viewbreak (TEXT="Shows all Breakpoints...")
rem   END
rem   GROUP options (TEXT="Options")
rem     COMMAND optgeneral(TEXT="General...")
rem   END
rem   GROUP help (TEXT="Help")
rem     COMMAND help (TEXT="Help",IMAGE="quest")
rem     COMMAND about (TEXT="About")
rem   END
rem END
rem 
rem TOOLBAR
rem   ITEM find
rem   SEPARATOR
rem   ITEM rerun 
rem   SEPARATOR
rem   ITEM run (TEXT="Run/Cont")
rem   ITEM stepinto
rem   ITEM stepover
rem   ITEM stepout
rem   ITEM run2cursor (TEXT="To Cursor")
rem   SEPARATOR
rem   ITEM inspectvariable (TEXT="Inspect")
rem   SEPARATOR
rem   ITEM togglebreak (TEXT="Toggle")
rem END
rem 
rem 
rem LAYOUT(text="Debugger",style="basic")
rem 
rem VBOX(tag="main_vbox")
rem TABLE(tag="debugger",unmovablecolumns,unsortablecolumns)
rem {
rem  B  Line
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem [b |lnum |      line                                                                        |ib]
rem }
rem END
rem   HBOX
rem   GROUP(TEXT="Auto Variables",tag="auto_group")
rem   GRID
rem   {   
rem    [auto                    ]
rem    [                        ]
rem    [                        ]
rem    [                        ]
rem    [                        ]
rem   }
rem   END
rem   END
rem   GROUP(TEXT="Watched Variables",tag="watch_group")
rem   GRID
rem   {   
rem    [watch                   ]
rem    [                        ]
rem    [                        ]
rem    [                        ]
rem    [                        ]
rem   }
rem   END
rem   END
rem   END
rem   GRID
rem   {   
rem    [l1               ] [currFunc                ][l3       ] [cLine] Status [cStatus][hideauto][hidewatch]
rem   }
rem   END
rem END
rem 
rem ATTRIBUTES
rem   Label l1:text="Current function",justify=right;
rem   Label l3:text="Current Line",justify=right;
rem -- the source file
rem   Image  b = formonly.b,unhidable,comment="Breakpoints and Line Marker area";
rem -- b = formonly.b,WIDGET="BMP",CONFIG="smiley f9";
rem   Edit lnum=formonly.lnum,noentry,fontpitch=fixed,comment="Line numbers" ; 
rem   Edit line=formonly.line,fontpitch=fixed,noentry,SCROLL,unhidable,comment="Source code lines";
rem   Edit ib=formonly.isBreak,fontpitch=fixed,noentry,hidden;
rem -- the info fields
rem   Edit currfunc = formonly.currFunc,noentry,SCROLL;
rem   cLine         = formonly.cLine,noentry;
rem   cStatus       = formonly.cStatus,noentry,SCROLL;
rem   Button hideauto:togglehideauto,text="Hide &Auto";
rem   Button hidewatch:togglehidewatch,text="Hide &Watches";
rem --watch textedit
rem   TextEdit auto    =formonly.g_auto, fontPitch=fixed,stretch=x,scrollBars=both,noentry,tag="textedit_auto";
rem   TextEdit watch    =formonly.g_watch, fontPitch=fixed,stretch=x,scrollBars=both,noentry,tag="textedit_watch";
rem 
rem INSTRUCTIONS 
rem   SCREEN RECORD src(formonly.b thru formonly.isBreak)
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_addbreak.per
rem ACTION DEFAULTS
rem   ACTION lookup ( COMMENT="Look up the current name in the function list", image="zoom",ACCELERATOR=TAB)
rem   ACTION browsefunctions ( TEXT="Browse F&unctions",COMMENT="(Ctrl-u) Shows all functions and allows to select one", ACCELERATOR=CONTROL-U)
rem END
rem LAYOUT(text="Add Breakpoint in Function",style="dialog")
rem GRID
rem {
rem <G "Add Breakpoint in Function"                                            >
rem 
rem  Input Break Function Name [funcName                                   :z]
rem 
rem }
rem end
rem 
rem 
rem ATTRIBUTES
rem ButtonEdit funcName = formonly.g_funcName, action=history_show, image="bigcombo",comment="Browse history with Cursor Up/Down/F7";
rem Button z:lookup;
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_break.per
rem ACTION DEFAULTS
rem   ACTION delete ( TEXT="&Delete breakpoint",COMMENT="Deletes the focused breakpoint",ACCELERATOR=DELETE )
rem   ACTION addbreak ( TEXT="&Add breakpoint...",COMMENT="Opens a dialog to choose a break function",ACCELERATOR=CONTROL-A )
rem   ACTION deleteAll ( TEXT="Delete A&ll",COMMENT="Deletes all breakpoints",ACCELERATOR=ALT-L )
rem   ACTION jumpto ( TEXT="&Jump To",COMMENT="Jumps to the source location of the breakpoint",ACCELERATOR=ALT-J )
rem END
rem 
rem LAYOUT(text="Breakpoints",style="dialog")
rem GRID
rem {
rem <T Table1                                                                                                    >
rem   Enable  Nr  Type  Function                         Line   Module                       Hits  
rem  [e     |num|t   |funcName                        |lnum  |modName                       |hits|line|isFunction]
rem  [e     |num|t   |funcName                        |lnum  |modName                       |hits|line|isFunction]
rem  [e     |num|t   |funcName                        |lnum  |modName                       |hits|line|isFunction]
rem  [e     |num|t   |funcName                        |lnum  |modName                       |hits|line|isFunction]
rem  [e     |num|t   |funcName                        |lnum  |modName                       |hits|line|isFunction]
rem  [e     |num|t   |funcName                        |lnum  |modName                       |hits|line|isFunction]
rem                                                                    
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem Checkbox e = FORMONLY.enable,comment="enable or disable breakpoint",valueChecked="y",valueUnchecked="n",NOT NULL ;
rem EDIT num=FORMONLY.breakNum,noentry;
rem EDIT t=FORMONLY.breakType,noentry;
rem EDIT funcName = FORMONLY.funcName,noentry;
rem EDIT lnum = FORMONLY.lineNumber,noentry;
rem EDIT modName = FORMONLY.modName,noentry;
rem EDIT hits = FORMONLY.hits,noentry;
rem EDIT line = FORMONLY.line,HIDDEN;
rem EDIT isFunction = FORMONLY.isFunction,HIDDEN;
rem Table table1 :table1, style="breaklist";
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD brk (FORMONLY.*);
rem END
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_complete_function.per
rem LAYOUT(text="Choose a Function",style="combo")
rem 
rem TABLE Table1(WANTFIXEDPAGESIZE)
rem {
rem    Function Name                 
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem   [funcName                       ]
rem }
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT funcName      = FORMONLY.funcName,noentry,comment="Function Name" ;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD complete_function (FORMONLY.*);
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_complete_variable.per
rem LAYOUT(text="Choose a Variable",style="combo")
rem 
rem TABLE Table1(WANTFIXEDPAGESIZE)
rem {
rem    Variable Name                   global 
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem   [varname                       | global   ]
rem }
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT varname      = FORMONLY.varname,noentry,comment="Variable Name" ;
rem Checkbox global   = FORMONLY.global ,noentry,comment="Global scope"  ;
rem --TABLE Table1 : width=2;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD complete_variable (FORMONLY.varname,FORMONLY.global);
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_dirlist.per
rem LAYOUT(text="Choose a Source Directory",style="dialog")
rem 
rem GRID
rem {
rem <T src_mods                                                                              >
rem    Directory
rem  [dirname                                                        ]
rem  [dirname                                                        ]
rem  [dirname                                                        ]
rem  [dirname                                                        ]
rem  [dirname                                                        ]
rem  [dirname                                                        ]
rem                                                                    
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT dirname=FORMONLY.dirname,noentry;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD dirlist (FORMONLY.dirname);
rem END
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_edit_watch.per
rem ACTION DEFAULTS
rem   ACTION delete ( TEXT="&Delete",COMMENT="Deletes the current variable",ACCELERATOR=DELETE )
rem   ACTION deleteall ( TEXT="Delete &All",COMMENT="Deletes all variables",ACCELERATOR=ALT-A )
rem   ACTION addwatch ( TEXT="Add &Watch...",COMMENT="Opens up the inspect variable dialog",ACCELERATOR=ALT-W)
rem END
rem 
rem LAYOUT(text="Watched Variables",style="dialog")
rem --featuring the ancient DisplayArray
rem GRID
rem {
rem <T sg                                                        >
rem   Watched Variables
rem  [line                                                     ]
rem  [line                                                     ]
rem  [line                                                     ]
rem  [line                                                     ]
rem  [line                                                     ]
rem  [line                                                     ]
rem  [line                                                     ]
rem  [line                                                     ]
rem 
rem }
rem END
rem -- [accept    :cancel    :delete   :deleteall :]   
rem 
rem ATTRIBUTES
rem TABLE sg:;
rem line = FORMONLY.line,noentry,SCROLL ;
rem --Button accept:accept;
rem --Button cancel:cancel;
rem --Button delete:delete;
rem --Button deleteall:deleteall;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD edit_watch (FORMONLY.line);
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_fdbcommand.per
rem LAYOUT(text="Input Debugger Command",style="dialog")
rem GRID
rem {
rem <G "Input Debugger Command"                                  >
rem  [fdbcommand                                                ]
rem   Debugger Output
rem  [debout                                                    ]
rem  [                                                          ]
rem  [                                                          ]
rem  [                                                          ]
rem  [                                                          ]
rem  [                                                          ]
rem  [                                                          ]
rem  [                                                          ]
rem 
rem }
rem end
rem 
rem 
rem ATTRIBUTES
rem ButtonEdit fdbcommand = formonly.g_fdbcommand, action=history_show, image="bigcombo",comment="Browse history with Cursor Up/Down/F7";
rem TextEdit debout       =formonly.g_debout, fontPitch=fixed,stretch=both,scrollBars=both;
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_fdbcommandlist.per
rem LAYOUT(text="Fdb Command Overview",style="dialog")
rem 
rem GRID
rem {
rem <T Table1                                                                    >
rem    Command    Description
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem  [cmd       |hlp                                                            ]
rem                                                                    
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT cmd = FORMONLY.cmd,noentry,comment="Debugger Command" ;
rem EDIT hlp = FORMONLY.hlp,noentry,comment="Description for the Command" ;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD rec (FORMONLY.cmd,FORMONLY.hlp);
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_fdbhistory.per
rem ACTION DEFAULTS
rem   ACTION delete ( TEXT="Delete",COMMENT="Deletes the current line",ACCELERATOR=DELETE )
rem END
rem 
rem LAYOUT(text="History",style="combo")
rem --featuring the ancient DisplayArray
rem GRID
rem {
rem <S sg                                         >
rem  [line                                       ]
rem  [line                                       ]
rem  [line                                       ]
rem  [line                                       ]
rem  [line                                       ]
rem  [line                                       ]
rem  [line                                       ]
rem  [line                                       ]
rem }
rem END
rem 
rem ATTRIBUTES
rem Scrollgrid sg:GRIDCHILDRENINPARENT;
rem line = FORMONLY.line,noentry,SCROLL ;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD hist (FORMONLY.line);
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_finish.per
rem LAYOUT(style="dialog")
rem GRID
rem {
rem    ["The function :          "][finishFunc                                 ] 
rem    ["endet with  the result :"][finishResult                               ]
rem }
rem END
rem 
rem ATTRIBUTES
rem 
rem finishFunc    = formonly.finishFunc,noentry,SCROLL;
rem finishResult  = formonly.finishResult,noentry,SCROLL;
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_functions.per
rem LAYOUT(text="Inspect Functions",style="dialog")
rem HBOX
rem TABLE Table1
rem {
rem    Function Name                 
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem   [funcName                                  ]
rem }
rem END
rem GRID
rem {
rem   <G "Function Details"                        >
rem    Module Name   [modName                    ]
rem    Full File Name[fileName                   ]
rem    Line Number   [lineNumber]
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT funcName   = FORMONLY.funcName  ,NOENTRY,comment="Function Name" ;
rem EDIT modName    = FORMONLY.modName   ,NOENTRY,comment="Module Name" ;
rem EDIT fileName   = FORMONLY.fileName  ,NOENTRY,
rem                   comment   ="Full File Name of the Module" ;
rem EDIT lineNumber = FORMONLY.lineNumber,NOENTRY,comment="Line Number" ;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD functions (FORMONLY.funcName)
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_help.per
rem ACTION DEFAULTS
rem   ACTION close ( Text="&Close", COMMENT="Closes the help window", ACCELERATOR=ESCAPE)
rem   ACTION backspace (ACCELERATOR=BACKSPACE)
rem   ACTION del (ACCELERATOR=DELETE)
rem END
rem 
rem LAYOUT(TEXT="Help Window",style="help")
rem GRID
rem {
rem  [helpstr                                                             ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                                                    ]
rem  [                                   :find      :findnext  :close     ] 
rem } 
rem END
rem 
rem ATTRIBUTES
rem 
rem TextEdit helpstr=formonly.g_helpstr,scrollbars=vertical,stretch=both,fontpitch=fixed;
rem Button find:find;
rem Button findnext:findnext;
rem Button close:close;
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_inspectvariable.per
rem ACTION DEFAULTS
rem   ACTION grab ( TEXT="Grab Var&iable",COMMENT="(Ctrl-i)  Tries to grab the variable from the current source line",ACCELERATOR=CONTROL-I )
rem   ACTION viewlocals ( TEXT="&Locals",COMMENT="Shows a dialog with all local variables",ACCELERATOR=CONTROL-L)
rem   ACTION viewglobals ( TEXT="&Globals",COMMENT="Shows a dialog with all local variables",ACCELERATOR=CONTROL-G)
rem   ACTION addwatch ( TEXT="Add &Watch",COMMENT="Adds the current variable to the watch list",ACCELERATOR=ALT-W)
rem   ACTION delwatch ( TEXT="&Delete Watch",COMMENT="Deletes the current variable from the watch list",ACCELERATOR=ALT-D)
rem   --ACTION hidewatch ( TEXT="&Hide Watches",COMMENT="Hides the Text Control with the watched variables",ACCELERATOR=ALT-D)
rem   ACTION viewwatchlist ( TEXT="&Edit Watches",COMMENT="Edits the list of watched variables",ACCELERATOR=ALT-E)
rem   ACTION lookup ( COMMENT="Looks up the name in the variable list", image="zoom",ACCELERATOR=TAB)
rem END
rem 
rem TOOLBAR
rem   ITEM find
rem   SEPARATOR
rem   ITEM rerun 
rem   SEPARATOR
rem   ITEM run (TEXT="Run/Cont")
rem   ITEM stepinto
rem   ITEM stepover
rem   ITEM stepout
rem   ITEM run2cursor (TEXT="To Cursor")
rem END
rem 
rem LAYOUT(text="Inspect Variables",style="dialogplusTB")
rem VBOX
rem GROUP(text="Watch Variable Actions")
rem GRID
rem {
rem  [addwatch  :" ":delwatch  :" "viewwatchlist :                      ]
rem }
rem END --GRID
rem END --GROUP
rem GROUP(text="Input Variable Name(s)")
rem GRID
rem {
rem  Variable Name [varname                                            :z]
rem  Variable Value 
rem  [debout                                                             ]
rem  [                                                                   ]
rem  [                                                                   ]
rem  [                                                                   ]
rem  [                                                                   ]
rem  [                                                                   ]
rem  [                                                                   ]
rem }
rem END --GROUP
rem END --GRID
rem END --VBOX
rem 
rem 
rem ATTRIBUTES
rem ButtonEdit varname = formonly.g_inspectvariable_name,action=history_show,image="bigcombo";
rem Button z:lookup;
rem TextEdit debout    =formonly.g_inspectvariable_value, fontPitch=fixed,stretch=both,scrollBars=both,noentry;
rem Button addwatch:addwatch;
rem Button delwatch:delwatch;
rem --Button hidewatch:hidewatch;
rem Button viewwatchlist:viewwatchlist;
rem --Group watch_vars:text="Watched Variables",tag="watch_group" ;
rem --TextEdit watch    =formonly.g_watch, fontPitch=fixed,stretch=both,scrollBars=both,noentry;
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_modules.per
rem LAYOUT(text="Source Modules",style="dialog")
rem GRID
rem {
rem <T src_mods                                                                              >
rem    Source Modules
rem  [mod                                                                               ]
rem  [mod                                                                               ]
rem  [mod                                                                               ]
rem  [mod                                                                               ]
rem  [mod                                                                               ]
rem  [mod                                                                               ]
rem                                                                    
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT mod=FORMONLY.mod,noentry;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD src (FORMONLY.mod);
rem END
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_search.per
rem LAYOUT (style="dialog",TEXT="Search")
rem GRID
rem {
rem <G "Search"                                         >
rem 
rem  Find what:  [search                          ] 
rem  [""]
rem  ------------------------------------------------
rem  [""]
rem   Options                            Direction
rem  [wholeword                       ] [updown   ]
rem  [matchcase                       ] [         ]
rem  [useMATCHES                      ] [         ]
rem                             
rem                            
rem                           
rem }
rem END
rem 
rem ATTRIBUTES
rem ButtonEdit search  =formonly.srch_search,action = history_show,image="bigcombo" ;
rem CHECKBOX wholeword =formonly.srch_wholeword, text="Match &whole word only",NOT NULL;
rem CHECKBOX matchcase =formonly.srch_matchcase, text="Match &case",NOT NULL;
rem CHECKBOX useMATCHES=formonly.srch_useMATCHES, text="use &MATCHES",NOT NULL;
rem RADIOGROUP updown   =formonly.srch_updown   , items= (("Up","&Up"),("Down","&Down")),NOT NULL;
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_stack.per
rem LAYOUT(text="Call Stack",style="listchoice")
rem TABLE
rem {
rem   M  L   Function                         Line   Module
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem  [m |l  |funcName                        |lnum  |modName                       ]
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem Image m = FORMONLY.marker ;
rem EDIT l = FORMONLY.level,noentry,comment="Level (Depth)" ;
rem EDIT funcName = FORMONLY.funcName,noentry;
rem EDIT lnum = FORMONLY.lineNumber,noentry;
rem EDIT modName = FORMONLY.modName,noentry;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD stk (FORMONLY.*) ;
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_variables.per
rem TOOLBAR
rem   ITEM find
rem   SEPARATOR
rem   ITEM rerun 
rem   SEPARATOR
rem   ITEM run (TEXT="Run/Cont")
rem   ITEM stepinto
rem   ITEM stepover
rem   ITEM stepout
rem   ITEM run2cursor (TEXT="To Cursor")
rem END
rem 
rem LAYOUT(text="Variables",style="dialogplusTB")
rem GRID
rem {
rem <T Table1                                                                                                                                                                                     >
rem    Name                 Value                                                                                                                                                 Module
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem  [name                 |value                                                                                                                                                |modname      ]
rem                                                                    
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT name          = FORMONLY.name,noentry,comment="Variable Name" ;
rem EDIT value         = FORMONLY.value,noentry,comment="Variable Value";
rem EDIT modname       = FORMONLY.modname,noentry,comment="Module Name";
rem TABLE Table1:width = 80;
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD variables (FORMONLY.*)
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb_viewlocals.per
rem LAYOUT(text="View Local Variables")
rem GRID
rem {
rem <T Table1                                                          >
rem    Name            Value
rem  [varname        |value                                         ]
rem  [varname        |value                                         ]
rem  [varname        |value                                         ]
rem  [varname        |value                                         ]
rem  [varname        |value                                         ]
rem  [varname        |value                                         ]
rem                                                                    
rem }
rem END
rem END
rem 
rem ATTRIBUTES
rem 
rem EDIT varname = FORMONLY.varname,comment="Local Variable Name" ;
rem EDIT value = FORMONLY.value,comment="Local Variable Value";
rem                                                                                 
rem INSTRUCTIONS
rem SCREEN RECORD loc (FORMONLY.varname,FORMONLY.value);
rem END
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb.msg
rem .1;
rem   The Debugger main window
rem   ------------------------
rem 1. Basics:
rem ==========
rem In this window you can inspect the source code of the debuggee(the program to debug) and perform the debugger standard actions like run/step over/step into or setting a breakpoint at a source code line. Below the source code area there are visible the \'Auto Variables\' and \'Watched Variables\' group boxes.
rem 
rem 1.1 Setting a breakpoint <F9>:
rem ------------------------------
rem Setting/Deleting a breakpoint is just pressing <Enter> or <F9> at the current source code line.
rem 
rem 2. Debugger standard stepping actions
rem =====================================
rem The hotkeys for these actions are the same as in the Microsoft Visual Studio Debugger, however it is possible to change this by exchanging the fgldeb.4ad Action Default file. (For example to make the hotkeys INFORMIX/BDL compatible)
rem 
rem 2.1 Run/Continue <F5>
rem ---------------------
rem Starts the program if it is not started, or continues the programm,
rem  if it is already running. 
rem 
rem 2.1 Step Over (Next)<F10>
rem -------------------------
rem Jumps over the next statement
rem 
rem 2.3 Step Into (Step)<F11>
rem -------------------------
rem If the current line marker is at a line containing a function call, this command lets the debugger jump to the first instruction of the function.
rem 
rem 2.4. Step Out (Fin)<Shift-F11>
rem -------------------------
rem Continues the program until the current function was left. Shows a popup window with the result(s) of the function.
rem 
rem 2.5. Restart <Ctrl-Shift-F5>
rem ----------------------------
rem Restarts the debuggee and resets all variables.
rem 
rem 3. Auto Variables
rem =================
rem fgldeb tries to get the information about the variables at the current line,
rem and keeps this information visible until new variables arrive.
rem This reduces the need of the "INSPECT_VARIABLE" dialog.
rem 
rem 4. Watched Variables
rem ====================
rem User defined list of variables to observe. 
rem Add the variable names with the "INSPECT_VARIABLE" dialog.
rem 
rem 
rem 5. Dialogs
rem ==========
rem Dialogs have all a Hotkey beginning with the 'Ctrl' key together with a letter (Except the Add Breakpoint Dialog).The "INSPECT_VARIABLE" dialog and the dialogs for the Local/Global Variables allow to stay open for the standard stepping operations(implemented by a kind of pseudo non modality)
rem 5.1 Inspect Variable(s) <Ctrl-i>
rem --------------------------------
rem Tries to get the variable names from the current line and opens up a dialog to input/search variable names and to display their values.
rem It is possible to inspect multiple variables by using whitespace between the variable names.
rem The formatting is somewhat different from the original debugger output one gets via "print" commands: fgldeb tries to produce more readable output.
rem If you type the name of an array, all element are listed by index
rem 
rem 5.2 Breakpoints
rem ---------------
rem Shows a list with all currently defined breakpoints. It is possible to delete/enable/disable a breakpoint or to jump to the source code location of the breakpoint.Another hotkey opens an additional dialog to add breakpoints by typing a function name (or selecting from the function list).  
rem 
rem 5.2 Stack Window <Ctrl-s>
rem -------------------------
rem Shows a list with the current call stack. It is possible to select a stack frame with <Enter> or <DoubleClick>, then the debugger jumps to the source location inside the call chain and selects also the stack frame for inspecting variables in that level. Hence the auto-variables display also changes.
rem The next stepping command goes back to the top level/current line .
rem 
rem 5.3 Module Window <Ctrl-m>
rem --------------------------
rem Shows a list of all (4gl) modules of the debuggee. It is possible to select a module with <Enter> or <DoubleClick>, then fgldeb shows the selected source code module.
rem The next stepping command goes back to the current line.
rem 
rem 5.4 Functions Window <Ctrl-u>
rem -----------------------------
rem Shows a list of all functions in the program. You can search a function with <Ctrl-f> and it is possible to jump to the source code location of a function with <Enter> or <DoubleClick>.
rem 
rem 5.5 Local Variables <Ctrl-l>
rem -----------------------------
rem Shows a list of all local variables in the currently selected stackframe.You can search a variable with <Ctrl-f> and it is possible to inspect a variable further with <Enter> or <DoubleClick> (invokes the "INSPECT_VARIABLE" dialog).
rem 
rem 5.6 Global Variables <Ctrl-g>
rem -----------------------------
rem Shows a list of all global variables.You can search a variable name with <Ctrl-f> and it is possible to inspect a variable further with <Enter> or <DoubleClick> (invokes the "INSPECT_VARIABLE" dialog).
rem 
rem 5.7 Watched Variables <Ctrl-g>
rem ------------------------------
rem Shows a list of all currently watched variables.You can delete variables by pressing <Del> and add variables by invoking the "INSPECT_VARIABLE" dialog.
rem 
rem 5.8 Execute Debugger Command <Control-d>
rem ----------------------------------------
rem Gives you direct access to the true underlying 'fglrun -d' debugger backend. You can type in all gdb compatible commands in an edit control and get the answer in the window below. Step Into is "s", Step (Next) is "n" .
rem 
rem 5.9 Find dialog <Ctrl-f>
rem ------------------------
rem Searches for a source code line. <F3> continues the search. In most of the dialogs displaying lists, <Ctrl-f> and <F3> are the hotkeys for search and bring up this dialog.
rem 
rem 5.10 Add breakpoint in function <Ctrl-F9>
rem -----------------------------------------
rem Asks for a function where to add a breakpoint. It is possible to choose from the function list with <Ctrl-u>.
rem 
rem .2;
rem 
rem   The Variable inspector window 
rem   -----------------------------
rem 1. General possibilities
rem =========================
rem In this window one can input multiple variable names in the 
rem "Variable Name" ButtonEdit and obtain their values.
rem Variable names must be delimited with spaces. 
rem By pressing the <Tab> key one can try to complete an incomplete variable name.
rem If there is only 1 match in the list of available variables, 
rem fgldeb completes the variable automatically, otherwise it presents a list of 
rem matching variable names.
rem By pressing Up/Down or clicking the Button of the ButtonEdit field one can 
rem browse in the history of variable names already entered.
rem 
rem 2. Inspecting records
rem =====================
rem If the variable name entered is a record variable, fgldeb displays each member on a separate row. 
rem (in contradiction to the original "print" output of fglrun -d ) 
rem 
rem 3. Inspecting arrays
rem =====================
rem If the variable name entered is a 4GL array, 
rem each element of the array is printed on a seperate row.
rem By using the Python slices syntax, one can inspect parts of the array.
rem Example:
rem Variable name for the array is "a"
rem a[1:4]
rem prints the first 4 Elements of the array
rem a[35:90]
rem prints the range a[35] until a[90]
rem a[90:35]
rem reverses the rows
rem (Note:you must use digits for the range, you can't use other variable names to index the slice)
rem 
rem 4. Add/Delete variables to/from the watch list
rem =============================================
rem By clicking "Add Watch" the variable(s) currently displayed in this dialog 
rem are added to the watch list if they are not already contained in the 
rem watch list. 
rem By clicking "Delete Watch" fgldeb tries to delete the variable(s) 
rem currently displayed from the watch list.
rem 
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb.4ad
rem <?xml version="1.0" encoding="ANSI_X3.4-1968"?>
rem <ActionDefaultList>
rem   <ActionDefault name="accept"   text="OK"       acceleratorName="Return"/>
rem   <ActionDefault name="cancel"   text="Cancel"   acceleratorName="Escape"/>
rem   <ActionDefault name="help"     text="Help"     acceleratorName="F1"/>
rem   <ActionDefault name="delete"   text="Delete"/>
rem 
rem   <ActionDefault name="nextrow"  text="Next" image="goforw"  comment="" acceleratorName="Down"/>
rem   <ActionDefault name="prevrow"  text="Previous" image="gorev" comment="" acceleratorName="Up"/>
rem   <ActionDefault name="firstrow" text="First" image="gobegin" comment="" acceleratorName="Home"/>
rem   <ActionDefault name="lastrow"  text="Last" image="goend"   comment="" acceleratorName="End"/>
rem <!--
rem   <ActionDefault name="first"     text="First"    image="gobegin"/>
rem   <ActionDefault name="last"      text="Last"     image="goend"/>
rem -->
rem 
rem   <ActionDefault name="editcopy"  text="Copy" image="copy"    comment="Copy" acceleratorName="Control-c" />
rem   <ActionDefault name="editcut"   text="Cut" image="cut"     comment="Cut" acceleratorName="Control-x" />
rem   <ActionDefault name="editpaste" text="Paste" image="paste"   comment="Paste" acceleratorName="Control-v" />
rem 
rem   <ActionDefault name="print" text="Print" image="debug_printer" comment="Print" />
rem   <ActionDefault name="help"  text="Help" image="debug_quest"   comment="Context Help" />
rem   <ActionDefault name="run" text="Run/Continue" image="debug_run" comment="Run/Continue the program" acceleratorName="F5" />
rem   <ActionDefault name="run_args" text="Program arguments..." comment="Opens a dialog to change the program arguments (Control-r)" acceleratorName="Control-r" />
rem   <ActionDefault name="rerun" text="Restart" image="debug_restart" comment="(Ctrl-Shift-F5) Restarts the Program" acceleratorName="Control-Shift-F5" />
rem   <ActionDefault name="stepinto" text="Step Into" image="debug_stepinto" comment="(F11) single step into the next statement,jumps into functions" acceleratorName="F11" />
rem   <ActionDefault name="stepover" text="Step Over" image="debug_stepover" comment="(F10) single step over the next statement" acceleratorName="F10" />
rem   <ActionDefault name="stepout" text="Step Out" image="debug_stepout" comment="(Shift-F11) continues until function returns and shows the return value" acceleratorName="Shift-F11" />
rem   <ActionDefault name="run2cursor" text="Run to Cursor" image="debug_runtocursor" comment="(F4) runs the program to the line containing the cursor" acceleratorName="F4" acceleratorName2="Control-F10"/>
rem   <ActionDefault name="togglebreak" text="Toggle Breakpoint" image="debug_hand" comment="(F9) Toggle breakpoint at current location" acceleratorName="F9" />
rem   <ActionDefault name="togglebreakdisable" text="Toggle Breakpoint Enabled/Disabled" comment="(Shift-F9) Toggle the enable of a breakpoint at the current location" acceleratorName="Shift-F9" />
rem   <ActionDefault name="addbreak" text="Add Breakpoint in function..." comment="(Ctrl-F9) Opens a dialog to input the function name" acceleratorName="Control-F9" />
rem   <ActionDefault name="viewbreak" text="View Breakpoints..." comment="Show all breakpoints" acceleratorName="Control-b" />
rem   <ActionDefault name="viewstack" text="View Stack" comment="Shows the current call stack" acceleratorName="Control-s" />
rem   <ActionDefault name="viewwatchlist" text="View Watches..." comment="Shows the current variable watch list" acceleratorName="Control-w" />
rem   <ActionDefault name="quit" text="Exit" comment="Exits the debugger" acceleratorName="Control-q" />
rem   <ActionDefault name="quit" text="Exit" comment="Exits the debugger" acceleratorName="Control-q" />
rem   <ActionDefault name="fdbcommand" text="Execute Debugger Command..." comment="performs direct low level commands" acceleratorName="Control-d" />
rem   <ActionDefault name="history_show" text="shows history" comment="shows a choice dialog of the history of the current field" acceleratorName="F7" defaultView="no" />
rem   <ActionDefault name="history_up" text="History Up" comment="goes up in the history" acceleratorName="Up" defaultView="no" />
rem   <ActionDefault name="history_down" text="History Down" comment="goes down in the history" acceleratorName="Down" defaultView="no" />
rem   <ActionDefault name="showfdbcommands" text="Show all commands" comment="shows a choice dialog with all available debugger commands" acceleratorName="F8" defaultView="yes" />
rem   <ActionDefault name="viewmodules" text="(Control-m) Show Source Modules..." comment="shows all modules with debug line information" acceleratorName="Control-m" />
rem   <ActionDefault name="viewfunctions" text="(Control-u) Show Function Names..." comment="shows all function names in this program" acceleratorName="Control-u" />
rem   <ActionDefault name="find" text="Find..." comment="(Control-f) Finds the specified text" acceleratorName="Control-f" image="debug_find" />
rem   <ActionDefault name="findnext" text="Find Next" comment="Finds the next occurence of the search string" acceleratorName="F3" />
rem   <ActionDefault name="about" text="About" comment="Shows the version number" />
rem   <ActionDefault name="viewlocals" text="Local Variables..." comment="Inspects the local variables" acceleratorName="Control-l" />
rem   <ActionDefault name="viewglobals" text="Global Variables..." comment="Inspects the glocal variables" acceleratorName="Control-g" />
rem   <ActionDefault name="inspectvariable" text="Inspect Variable(s)..." comment="Inspects a variable of your choice" image="debug_mag" acceleratorName="Control-i" />
rem   <ActionDefault name="top_file" text="The File Menu" comment="test" image="debug_mag" acceleratorName="Alt-f" />
rem   <ActionDefault name="restore_breakpoints" text="Restore Breakpoints" comment="Restores the breakpoints from the .fgldeb file" acceleratorName="Alt-r" />
rem </ActionDefaultList>
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb.4st
rem <?xml version="1.0" encoding="ANSI_X3.4-1968"?>
rem <StyleList>
rem   <Style name="Window.basic">
rem      <StyleAttribute name="actionPanelPosition" value="none" />
rem      <StyleAttribute name="ringMenuPosition" value="none" />
rem   </Style>
rem   <Style name="Window.listchoice">
rem      <StyleAttribute name="actionPanelPosition" value="none" />
rem      <StyleAttribute name="ringMenuPosition" value="none" />
rem      <StyleAttribute name="toolBarPosition" value="none" />
rem      <StyleAttribute name="windowType" value="modal" />
rem      <StyleAttribute name="position" value="center" />
rem   </Style>
rem   <Style name="Window1.combo1">
rem      <StyleAttribute name="actionPanelPosition" value="none" />
rem      <StyleAttribute name="ringMenuPosition"    value="none" />
rem      <StyleAttribute name="toolBarPosition"     value="none" />
rem      <StyleAttribute name="windowType"          value="modal" />
rem      <StyleAttribute name="position"            value="field" />
rem      <StyleAttribute name="border"              value="frame" />
rem      <StyleAttribute name="statusBarType"       value="none" />
rem   </Style>
rem   <Style name="Window.combo">
rem      <StyleAttribute name="actionPanelPosition" value="none" />
rem      <StyleAttribute name="ringMenuPosition"    value="none" />
rem      <StyleAttribute name="toolBarPosition"     value="none" />
rem      <StyleAttribute name="windowType"          value="modal" />
rem      <StyleAttribute name="statusBarType"       value="none" />
rem      <StyleAttribute name="border"              value="frame" />
rem      <StyleAttribute name="position"            value="field" />
rem   </Style>
rem   <Style name="Window.dialog">
rem      <StyleAttribute name="windowType" value="modal" />
rem      <StyleAttribute name="sizable" value="yes" />
rem      <StyleAttribute name="position" value="center" />
rem      <StyleAttribute name="actionPanelPosition" value="bottom" />
rem      <StyleAttribute name="ringMenuPosition" value="bottom" />
rem      <StyleAttribute name="toolBarPosition" value="none" />
rem   </Style>
rem   <Style name="Window.dialogplusTB">
rem      <StyleAttribute name="windowType" value="modal" />
rem      <StyleAttribute name="sizable" value="yes" />
rem      <StyleAttribute name="position" value="center" />
rem      <StyleAttribute name="actionPanelPosition" value="bottom" />
rem      <StyleAttribute name="ringMenuPosition" value="bottom" />
rem      <StyleAttribute name="toolBarPosition" value="top" />
rem   </Style>
rem   <Style name="Window.viewer">
rem      <StyleAttribute name="windowType" value="modal" />
rem      <StyleAttribute name="sizable" value="yes" />
rem      <StyleAttribute name="position" value="center" />
rem      <StyleAttribute name="actionPanelPosition" value="none" />
rem      <StyleAttribute name="statusBarType"       value="none" />
rem      <StyleAttribute name="ringMenuPosition" value="none" />
rem      <StyleAttribute name="toolBarPosition" value="none" />
rem   </Style>
rem   <Style name="Table.breaklist">
rem      <StyleAttribute name="highlightCurrentRow" value="yes" />
rem      <StyleAttribute name="showGrid" value="no" />
rem   </Style>
rem </StyleList>
rem 
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb.4tb
rem <?xml version="1.0" encoding="ANSI_X3.4-1968"?>
rem <ToolBar>
rem   <ToolBarItem name="find" />
rem   <ToolBarSeparator/>
rem   <ToolBarItem name="run" text="Run/Cont" />
rem   <ToolBarItem name="stepinto" />
rem   <ToolBarItem name="stepover" />
rem   <ToolBarItem name="stepout" />
rem   <ToolBarItem name="run2cursor" />
rem   <ToolBarSeparator/>
rem   <ToolBarItem name="togglebreak" text="Toggle" />
rem </ToolBar>
rem __CAT_EOF_END__
rem __CAT_EOF_BEGIN__:fgldeb.4gl
rem IMPORT FGL fgldialog
rem ------------------------------------------------------------------------------
rem -- $Id: fgldeb.4gl,v 1.2 2013/04/08 08:33:17 rene Exp $
rem -- main module for "fgldeb" - the Debugger Frontend for "fglrun -d "
rem -------------------------------------------------------------------------------
rem DEFINE g_version_str String
rem CONSTANT g_version_major=1
rem CONSTANT g_version_minor=1
rem CONSTANT g_version_patch=1
rem CONSTANT BUILD_NUMBER=27
rem --maximum number of auto variables grabbed from the source
rem CONSTANT MAXAUTO = 8
rem CONSTANT CVS_DATE="$Date: 2013/04/08 08:33:17 $"
rem CONSTANT CVS_REVISION="$Revision: 1.2 $"
rem 
rem --Types--
rem --source code array for the current source
rem DEFINE src_arr DYNAMIC ARRAY OF RECORD
rem   marker String, { line marker image }
rem   lnum Integer,
rem   line String,
rem   isBreak Integer
rem END RECORD
rem 
rem --answer lines from the debugger
rem DEFINE deb_arr DYNAMIC ARRAY OF String
rem --the number of lines from the debugger
rem DEFINE deb_arr_len INTEGER
rem 
rem --window hierarchy
rem DEFINE win_arr DYNAMIC ARRAY OF String
rem 
rem --breakpoint structure
rem --current breakpoint list
rem DEFINE break_arr DYNAMIC ARRAY OF RECORD
rem   enabled String, breakNum Integer, breakType String, funcName String, lineNumber Integer, modName String, hits Integer, line String, isFunction Integer
rem END RECORD
rem 
rem 
rem --current stack list
rem DEFINE stk_arr DYNAMIC ARRAY OF RECORD
rem   marker String ,
rem   level Integer,
rem   funcName String,
rem   lineNumber Integer,
rem   modName String
rem END RECORD
rem 
rem --history arrays
rem DEFINE fdb_hist_arr DYNAMIC ARRAY OF STRING
rem DEFINE inspectvar_hist_arr DYNAMIC ARRAY OF STRING
rem DEFINE search_hist_arr DYNAMIC ARRAY OF STRING
rem DEFINE func_hist_arr DYNAMIC ARRAY OF STRING
rem 
rem --array of variables to watch
rem DEFINE watch_arr DYNAMIC ARRAY OF STRING
rem 
rem --keeps track of the finish function returns (stepout command)
rem DEFINE finish_arr DYNAMIC ARRAY OF RECORD
rem    funcName String,
rem    caller String
rem END RECORD
rem 
rem --all directories containing sources
rem --DEFINE dir_arr DYNAMIC ARRAY OF STRING
rem 
rem --all module names of the debugee
rem DEFINE mod_arr DYNAMIC ARRAY OF STRING
rem 
rem DEFINE global_var_arr,local_var_arr DYNAMIC ARRAY OF RECORD
rem     varname String,
rem     value String,
rem     modname String
rem END RECORD
rem 
rem --auto variables, for each active stack frame there is an array of variables
rem DEFINE auto_arr DYNAMIC ARRAY OF RECORD
rem   frame_name STRING ,
rem   var_arr DYNAMIC ARRAY OF STRING,
rem   pos_arr DYNAMIC ARRAY OF INTEGER
rem END RECORD
rem 
rem --globals
rem --THE command channel to the real debugger
rem DEFINE g_channel base.Channel
rem --number of command sent to real debugger
rem DEFINE g_cmdcount Integer
rem --the file name for the file currently displayed
rem DEFINE g_file_displayed String
rem --the "long" version (complete path)
rem DEFINE g_file_displayed_long String
rem --the currently active file inside this debugger frontend
rem DEFINE g_file_current String
rem --the file where frame 0 is currently active(top of stack)
rem DEFINE g_file_0 String
rem --the "long" version (complete path)
rem DEFINE g_file_current_long String
rem define g_src_path String
rem 
rem DEFINE g_state STRING -- 3 states: "initial", "running" or "stopped"
rem CONSTANT ST_INITIAL="initial"
rem CONSTANT ST_RUNNING="running"
rem CONSTANT ST_STOPPED="stopped"
rem 
rem DEFINE g_active, g_source_changed ,g_in_display Integer
rem --the current displayed line in the current displayed (g_file_displayed)
rem DEFINE g_line Integer
rem --linenumber showed in the statusbar
rem DEFINE g_status_line_no Integer
rem DEFINE g_source_lines Integer --number of lines in the file
rem --the source line number of frame 0 (top of stack)
rem DEFINE g_line_0 Integer
rem DEFINE g_verbose Integer
rem DEFINE g_frame_no Integer -- current stackframe
rem DEFINE g_frame_name String -- current stackframe function name
rem DEFINE g_view_function String -- current viewed function
rem --the line number and filename for the main function
rem DEFINE g_main_lineNumber INTEGER
rem DEFINE g_main_modName STRING
rem -- last module for breakpoint restore info
rem DEFINE g_lastmod STRING
rem -- debugger output sent to the console
rem DEFINE g_show_output INT
rem 
rem --- searchdialog
rem DEFINE srch_search String
rem DEFINE srch_wholeword,srch_matchcase,srch_useMATCHES Integer
rem DEFINE srch_updown String
rem 
rem -- if this variable is set, get_deb_out() does not interpret
rem -- a line number info in the output (and changes automaticaly the displayed file)
rem DEFINE g_deb_out_ignore_linenumber Integer
rem -- the filename and line parsed in get_deb_out
rem DEFINE g_deb_out_filename String
rem DEFINE g_deb_out_line Integer
rem DEFINE g_deb_out_active,g_deb_out_repeat INTEGER
rem --do we continue the step command if the program ended ?
rem DEFINE g_continue INTEGER
rem --do we reload the whole program if the debugger backend died
rem DEFINE g_reload INTEGER
rem 
rem --flag to prevent being recursive in the function
rem DEFINE g_read_in_source_active Integer
rem --is set to 1 if the read in of a source file didnt work
rem DEFINE g_read_in_source_error Integer
rem --
rem -- variables for raising the debugger in gdc, to switch back and forth
rem DEFINE g_debugger_raised Integer
rem -- (debuggee is the program which is debugged)
rem DEFINE g_debuggee_widget String
rem DEFINE g_debuggee_raised Integer
rem 
rem DEFINE g_inspectvariable_name , g_inspectvariable_value String
rem DEFINE g_fdbcommand , g_debout String
rem DEFINE g_tty STRING
rem 
rem DEFINE g_program,g_args STRING
rem 
rem --how many times was get_function_names called ?
rem DEFINE g_function_names_called STRING
rem --array containing ALL function names
rem DEFINE g_func_arr DYNAMIC ARRAY OF STRING
rem 
rem --remembers the last command sent to the debugger
rem DEFINE g_last_deb_cmd STRING
rem 
rem --function name for adding breakpoints
rem DEFINE g_funcName STRING
rem 
rem --do we run gdb in the pipe ?
rem DEFINE g_isgdb INTEGER
rem 
rem --do we need to check for a function return ?
rem DEFINE g_check_finish INTEGER
rem DEFINE g_finish_result STRING
rem 
rem --flag to test the end state
rem DEFINE g_quit INTEGER
rem 
rem --string displayed in the help window
rem DEFINE g_helpstr STRING
rem --cursor position in the help window
rem DEFINE g_helpcursor INTEGER
rem 
rem --global configuration variables for reading ~/.fgldeb
rem --DEFINE g_cfg_restoreBreak, g_cfg_restoreHistory INTEGER
rem --DEFINE g_cfg_showAuto, g_cfg_showWatch INTEGER
rem 
rem DEFINE g_restore_breakpoints INT
rem 
rem --THE main proc
rem MAIN
rem   --state variable for the quasi nonmodal dialogs:
rem   --normal state is "fgldeb", dialog states are
rem   --"inspectvariable" "fdbcommand" "local_variables" "global_variables"
rem   --go out with "exitapp"
rem   DEFINE da_state String
rem   DEFINE breakNum,dummy Integer
rem   --initialize globals
rem   LET g_version_str=sfmt("%1.%2.%3",g_version_major,g_version_minor,g_version_patch)
rem   LET g_channel=base.channel.create()
rem   LET g_file_displayed_long=" "
rem   LET g_in_display=0
rem   LET g_line=0
rem   LET g_line_0=0
rem   LET g_frame_no=0
rem   LET g_source_changed=0
rem   LET g_source_lines=0
rem   CALL parse_args() RETURNING g_program,g_args
rem   --load UI stuff
rem   CALL ui.Interface.loadActionDefaults("fgldeb")
rem   CALL ui.Interface.loadStyles("fgldeb")
rem   --CALL ui.Interface.loadToolBar("fgldeb")
rem   --open the one and only debugger window
rem   --be resistant to Control-c, hence allow passing it to the debuggee
rem   CLOSE WINDOW screen 
rem   OPTIONS INPUT WRAP
rem   OPTIONS HELP FILE "fgldeb.iem"
rem   DEFER INTERRUPT
rem   OPEN WINDOW fgldeb WITH FORM "fgldeb" 
rem   CALL add_splitter()
rem   CALL set_current_dialog("fgldeb")
rem   CALL set_debug_logo()
rem   CALL set_g_state(ST_INITIAL)
rem   --open form form1 from "fgldeb"
rem   --display form form1
rem   IF length(g_program)==0 THEN
rem     DISPLAY "usage: fglrun fgldeb <progname>"
rem     EXIT PROGRAM
rem   END IF
rem   CALL open_program()
rem   IF g_active=0 THEN
rem     EXIT PROGRAM
rem   END IF
rem   --CALL deb_write("break main")
rem   --now disable the currframe
rem   LET g_frame_no=0
rem   CALL goto_src_line(g_line_0,TRUE) RETURNING dummy
rem   --CALL do_run()
rem   --CALL update_breakpoints()
rem   --CALL update_stack()
rem   -- main debugger loop
rem   LET da_state="initial"
rem   WHILE g_active AND da_state<>"exitapp"
rem     IF g_source_changed THEN
rem       CALL update_breakpoints()
rem     END IF
rem     LET g_source_changed=0
rem     CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem     --CALL set_count(g_source_lines)
rem     CALL set_count(src_arr.getLength())
rem     --this interaction statement shows the current source file,
rem     --allows to set breakpoints and to invoke step actions and
rem     --various dialogs
rem     DISPLAY ARRAY src_arr TO src.*
rem       HELP 1
rem       ATTRIBUTES(UNBUFFERED,KEEP CURRENT ROW)
rem       BEFORE DISPLAY
rem         --checking the dialog state machine
rem         LET g_in_display=1
rem         --DISPLAY "BEFORE DISPLAY:goto_src_line:",g_line
rem         IF NOT goto_src_line(g_line,FALSE) THEN
rem           CALL update_arr_curr(g_line)
rem         END IF
rem         -- call a small hackish proc to update the marker correctly
rem         IF g_file_displayed=g_file_0 AND g_line_0<>0 THEN
rem           IF src_arr[g_line_0].marker IS NOT NULL AND
rem            (da_state="fdbcommand" OR da_state="inspectvariable" ) THEN
rem             CALL pokeMarker()
rem           END IF
rem         END IF
rem         --set the dialog name for debug purposes
rem         CALL _deb_setDialogName("qa_main")
rem         -- check if we left the display array because of a step command in
rem         -- a modal dialog , in this case we re-enter here the dialog to
rem         -- refresh the array and exit the dialog immediately
rem         -- DISPLAY "da_state in BEFORE DISPLAY array fgldeb is ",da_state
rem       BEFORE ROW
rem         CASE da_state
rem           WHEN "inspectvariable"
rem             EXIT DISPLAY
rem           WHEN "fdbcommand"
rem             EXIT DISPLAY
rem           WHEN "local_variables"
rem             EXIT DISPLAY
rem           WHEN "global_variables"
rem             EXIT DISPLAY
rem         END CASE
rem       --comment this in case of trouble with the autovars
rem       --{
rem       --BEFORE ROW
rem       -- LET g_line=arr_curr()
rem       -- CALL update_stack()
rem       -- CALL update_autovars()
rem       --}
rem       ON ACTION close
rem         LET da_state=do_quit(da_state)
rem         EXIT DISPLAY
rem       ON KEY(interrupt)
rem         LET da_state=do_quit(da_state)
rem         EXIT DISPLAY
rem       ON ACTION quit
rem         LET da_state=do_quit(da_state)
rem         EXIT DISPLAY
rem       ON ACTION run
rem         CALL do_run()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION run_args
rem         CALL do_input_run_args()
rem       ON ACTION rerun
rem         LET g_line=arr_curr()
rem         CALL do_rerun()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION stepinto
rem         LET g_line=arr_curr()
rem         CALL do_stepinto()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION stepover
rem         LET g_line=arr_curr()
rem         CALL do_stepover()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION stepout
rem         LET g_line=arr_curr()
rem         CALL do_stepout()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION run2cursor
rem         LET g_line=arr_curr()
rem         --DISPLAY "arr_curr=",g_line
rem         call do_run2cursor()
rem         IF g_source_changed OR g_state=ST_RUNNING THEN EXIT DISPLAY END IF
rem         --DISPLAY "run2cursor fin,arr_curr():",arr_curr()
rem       ON ACTION viewbreak
rem         LET g_line=arr_curr()
rem         CALL show_breakpoints()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION viewstack
rem         LET g_line=arr_curr()
rem         CALL update_stack()
rem         IF show_stack()=1 THEN
rem           EXIT DISPLAY
rem         END IF
rem       ON ACTION viewmodules
rem         LET g_line=arr_curr()
rem         CALL show_modules()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION viewfunctions
rem         LET g_line=arr_curr()
rem         LET g_view_function=show_functions(1)
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION accept
rem         GOTO mytogglebreak
rem       ON ACTION togglebreak
rem LABEL mytogglebreak:
rem         LET g_line=arr_curr()
rem         CALL do_toggle_break()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION togglebreakdisable
rem         CALL do_toggle_breakdisable()
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION addbreak
rem         CALL do_add_break() RETURNING breakNum
rem         IF g_source_changed THEN EXIT DISPLAY END IF
rem       ON ACTION find
rem         CALL do_find("src","source code")
rem       ON ACTION findnext
rem         CALL do_findnext("src")
rem       ON ACTION about
rem         CALL do_about()
rem       -- call pseudo non modal dialogs
rem       ON ACTION fdbcommand
rem         LET g_line=arr_curr()
rem         --IF g_source_changed THEN EXIT DISPLAY END IF
rem         LET da_state="fdbcommand"
rem         EXIT DISPLAY
rem       ON ACTION viewlocals
rem         LET da_state="local_variables"
rem         EXIT DISPLAY
rem       ON ACTION viewglobals
rem         LET da_state="global_variables"
rem         EXIT DISPLAY
rem       ON ACTION viewwatchlist
rem         LET da_state= do_view_watches_from("fgldeb")
rem         IF da_state<>"fgldeb" THEN EXIT DISPLAY END IF
rem       ON ACTION inspectvariable
rem         LET g_line=arr_curr()
rem         LET da_state=do_grab_variables_from("fgldeb")
rem         EXIT DISPLAY
rem       --ON ACTION save_state
rem         --CALL save_state()
rem       ON ACTION restore_breakpoints
rem         CALL restore_breakpoints()
rem       ON ACTION togglehideauto
rem         CALL toggle_hide_group("auto_group","togglehideauto","&Auto")
rem       ON ACTION togglehidewatch
rem         CALL toggle_hide_group("watch_group","togglehidewatch","&Watch")
rem       --ON ACTION optgeneral
rem         --CALL dialog_general_options()
rem       --ON ACTION help
rem         --CALL help_dialog(MAIN_HELP)
rem     END DISPLAY
rem     LET g_in_display=0
rem     CASE da_state
rem       WHEN "inspectvariable"
rem         LET da_state=inspectvariable(1)
rem       WHEN "fdbcommand"
rem         LET da_state=do_fdb_command()
rem       WHEN "local_variables"
rem         LET da_state=showvariables("local")
rem       WHEN "global_variables"
rem         LET da_state=showvariables("global")
rem     END CASE
rem   END WHILE
rem   CALL g_channel.close()
rem END MAIN
rem 
rem --opens up a pipe to "fglrun -d" or gdb and
rem --intializes breakpoints and the main line number
rem FUNCTION open_program()
rem   DEFINE program String
rem   DEFINE fglrun String
rem   IF NOT g_isgdb THEN
rem     IF fgl_getenv("FGLRUN") IS NOT NULL THEN
rem       LET fglrun = fgl_getenv("FGLRUN")
rem     ELSE
rem       LET fglrun = "fglrun"
rem     END IF
rem     LET program = fglrun || " -d " || g_program || " 2>&1"
rem     IF g_tty IS NOT NULL THEN
rem       IF file_on_windows() THEN
rem         LET program="set FGLGUI=0&&",program
rem       ELSE
rem         LET program="FGLGUI=0;export FGLGUI;",program
rem       END IF
rem     END IF
rem   ELSE
rem     LET program = "gdb " || g_program
rem   END IF
rem   CALL g_channel.openpipe(program,"u")
rem   DISPLAY "program is: \"",program,"\", status is:",status
rem   IF status < 0 THEN
rem     DISPLAY "can't open :",program
rem     EXIT PROGRAM
rem   END IF
rem   CALL g_channel.setDelimiter("")
rem   LET g_active=1
rem   IF NOT g_isgdb THEN
rem     CALL deb_write("set prompt (fglgui)")
rem   ELSE
rem     CALL deb_write("set prompt (fglgui)\\n")
rem   END IF
rem   CALL deb_write("set annotate 1")
rem   CALL get_deb_out()
rem   CALL restore_state()
rem   --CALL update_watch()
rem   LET g_frame_no=1
rem   LET g_show_output=TRUE
rem   CALL deb_write("info line main")
rem   CALL get_deb_out()
rem   LET g_show_output=FALSE
rem   LET g_frame_no=0
rem   IF g_file_displayed_long = " " THEN
rem     CALL no_source()
rem   END IF
rem   IF g_tty IS NOT NULL THEN
rem     DISPLAY "fgldeb:set tty to ",g_tty
rem     CALL deb_write("tty "||g_tty)
rem     CALL get_deb_out()
rem   END IF
rem   LET g_main_lineNumber=g_line_0
rem   LET g_main_modName =g_file_0
rem END FUNCTION
rem 
rem FUNCTION no_source()
rem   DEFINE i,i1,i2,found INT
rem   DEFINE sourceName,line,msg STRING
rem   --we did not find an exact source code module information
rem   --look for the result of "info line main"
rem   FOR i=1 TO deb_arr_len
rem     LET line=deb_arr[i]
rem     --DISPLAY "line:",line
rem     IF line.getIndexOf("Line",1)>0 AND line.getIndexOf("starts at",1)>0 THEN
rem       LET i1=line.getIndexOf("\"",1)
rem       LET i2=line.getIndexOf("\"",i1+1)
rem       --DISPLAY "i1:",i1,",i2:",i2
rem       IF i1>0 AND i2>i1 THEN
rem         LET sourceName=line.subString(i1+1,i2-1)
rem         LET found=TRUE
rem         EXIT FOR
rem       END IF
rem     END IF
rem   END FOR
rem   IF found THEN
rem     LET msg="Cannot find the source code file \"",sourceName,"\" containing MAIN"
rem   ELSE
rem     LET msg="Cannot find the source code file containing MAIN"
rem   END IF
rem   LET msg=msg," for program \"",g_program,"\" ,please check FGLSOURCEPATH !"
rem   CALL fgl_winMessage("Debugger", msg, "error")
rem   EXIT PROGRAM 1
rem END FUNCTION
rem 
rem 
rem --this function is called in case the
rem --underlying fglrun -d died for some reason...
rem --nobody is expected to be bugfree...
rem FUNCTION reopen_program()
rem   CALL g_channel.close()
rem   CALL save_state()
rem   LET g_channel = base.channel.create()
rem   LET g_reload=0
rem   CALL open_program()
rem   CALL set_g_state(ST_INITIAL)
rem   DISPLAY "reopened :" , g_program
rem END FUNCTION
rem 
rem --wrapper function around grab_variables() to check
rem --the location from where it was called
rem --if coming from the main loop, then inspectvariable()
rem --is called, if already inside inspectvariable, then
rem --just stay in the dialog and update the values
rem FUNCTION do_grab_variables_from(where)
rem   DEFINE where STRING
rem   DEFINE input_arr DYNAMIC ARRAY OF STRING
rem   DEFINE varnames,da_state STRING
rem   DEFINE i,len INTEGER
rem   CALL grab_variables(input_arr)
rem   LET len=input_arr.getLength()
rem   FOR i=1 TO len
rem     LET varnames=varnames.append(input_arr[i])
rem     LET varnames=varnames.append(" ")
rem   END FOR
rem   IF varnames IS NOT NULL THEN
rem     --cut the last space
rem     LET varnames=varnames.subString(1,varnames.getLength()-1)
rem   END IF
rem   LET da_state="inspectvariable"
rem   IF where="fgldeb" THEN
rem     --IF varnames IS NOT NULL THEN
rem     -- LET g_inspectvariable_name=varnames
rem     -- LET da_state=inspectvariable(1)
rem     --
rem     --ELSE
rem     -- LET da_state=inspectvariable(0)
rem     --END IF
rem     LET g_inspectvariable_name=varnames
rem   ELSE
rem     LET g_inspectvariable_name=varnames
rem   END IF
rem   RETURN da_state
rem END FUNCTION
rem 
rem --tiny function to force an update of the main display array
rem --for showing correctly the current line marker
rem FUNCTION pokeMarker()
rem   DEFINE tabNode om.DomNode
rem   DEFINE idx,pageSize,offset Integer
rem   LET tabNode= _deb_omId2Node(_deb_getOmIdTable("src"))
rem   LET pageSize=tabNode.getAttribute("pageSize")
rem   LET offset=tabNode.getAttribute("offset")
rem   --FOR i=offset TO offset+pageSize
rem   -- DISPLAY src_arr[i+1].marker TO src[i-offset+1].b
rem   --END FOR
rem   LET idx=tabNode.getAttribute("currentRow")-tabNode.getAttribute("offset")+1
rem   DISPLAY src_arr[g_line_0].marker TO src[idx].b
rem   --CALL ui.interface.refresh()
rem END FUNCTION
rem 
rem --finds the breakpoint number of the main() function
rem FUNCTION find_break_main()
rem   DEFINE i,len INTEGER
rem   LET len=break_arr.getLength()
rem   FOR i=1 TO len
rem     IF g_main_lineNumber=break_arr[i].lineNumber AND
rem         g_main_modName =break_arr[i].modName THEN
rem        RETURN break_arr[i].breakNum
rem     END IF
rem   END FOR
rem   RETURN -1
rem END FUNCTION
rem 
rem --removes the breakpoint of the main() function
rem FUNCTION remove_break_main()
rem   DEFINE bmain,idx INTEGER
rem   LET bmain=find_break_main()
rem   IF bmain<>-1 THEN
rem     LET idx=get_breakpoint_index(bmain)
rem     IF break_arr[idx].breakType="del" THEN
rem       CALL deb_write(sfmt("delete %1",bmain))
rem       CALL get_deb_out()
rem     END IF
rem     CALL update_breakpoints()
rem   END IF
rem END FUNCTION
rem 
rem --when invoking a step command like "next" or "step" then
rem --check if the program already runs
rem --if not,check for a breakpoint in main, set if necessary and
rem --invoke the "run" command
rem FUNCTION check_initial_step_state()
rem   DEFINE bmain INTEGER
rem   IF g_state=ST_INITIAL OR
rem      (g_state=ST_STOPPED AND g_isgdb) THEN
rem     -- search if we already have a breakpoint at the main line
rem     LET bmain=find_break_main()
rem     LET g_show_output=TRUE
rem     IF bmain=-1 THEN
rem       CALL deb_write(sfmt("tbreak %1:%2",g_main_modName,g_main_lineNumber))
rem       CALL get_deb_out()
rem       CALL update_breakpoints()
rem     END IF
rem     CALL set_g_state(ST_RUNNING)
rem     CALL deb_write(sfmt("run %1",g_args))
rem     CALL get_deb_out()
rem     LET g_show_output=FALSE
rem     RETURN 1
rem   ELSE
rem     RETURN 0
rem   END IF
rem END FUNCTION
rem 
rem --sends either "run" or "continue" depending on the
rem --current state
rem FUNCTION do_run()
rem   DEFINE cmd String
rem   CALL raise_debuggee("run")
rem   CASE g_state
rem     WHEN ST_RUNNING
rem       LET cmd="continue"
rem     WHEN ST_STOPPED
rem       LET cmd=sfmt("run %1",g_args)
rem     WHEN ST_INITIAL
rem       LET cmd=sfmt("run %1",g_args)
rem     OTHERWISE
rem       CALL deb_error ("unknown state :"||g_state)
rem   END CASE
rem   CALL set_g_state(ST_RUNNING)
rem   CALL do_debugger_step_cmd(cmd)
rem   CALL raise_debugger("run")
rem END FUNCTION
rem 
rem FUNCTION do_input_run_args()
rem   DEFINE prev_args STRING
rem   LET prev_args=g_args
rem   PROMPT "Enter the program arguments:" FOR g_args 
rem     ATTRIBUTE(WITHOUT DEFAULTS=1,HELP="Enter the program arguments")
rem   IF equalStringsAndNULLequalsEmpty(prev_args,g_args)=0 AND 
rem      g_state<>ST_INITIAL THEN
rem      CALL fgl_winmessage("Debugger","The new arguments will be taken into account after the next program restart","info")
rem   END IF
rem END FUNCTION
rem 
rem --one of the easy things, let the program start from the beginning
rem FUNCTION do_rerun()
rem   --DEFINE cmd String
rem   CALL raise_debuggee("rerun")
rem   CALL do_debugger_step_cmd(sfmt("run %1",g_args))
rem   CALL raise_debugger("rerun")
rem END FUNCTION
rem 
rem --checks first if the fgldeb is in initial state
rem --and performs the step command.
rem FUNCTION try_stepcmd(name,cmd)
rem   DEFINE name STRING
rem   DEFINE cmd STRING
rem   CALL raise_debuggee(name)
rem LABEL again:
rem   IF NOT check_initial_step_state() THEN
rem     IF name="stepout" THEN
rem       CALL do_stepout_int()
rem     ELSE
rem       CALL do_debugger_step_cmd(cmd)
rem     END IF
rem   ELSE
rem     IF name="stepout" THEN
rem       CALL do_stepout_int()
rem     ELSE
rem       CALL do_debugger_step_cmd(cmd)
rem     END IF
rem     CALL remove_break_main()
rem   END IF
rem   --if the programs stops during the excution, apply
rem   --the command again
rem   IF g_state=ST_INITIAL AND g_continue THEN
rem     GOTO :again
rem   END IF
rem   CALL raise_debugger(name)
rem END FUNCTION
rem 
rem --instructs "fglrun -d" to run to the current source code position
rem --when other breakpoints are hit before reaching the wanted source
rem --line, the command is ignored
rem --(the internal breakpoint will be deleted by "fglrun -d")
rem FUNCTION do_run2cursor()
rem   CALL try_stepcmd("run2cursor",sfmt("until %1",g_line))
rem END FUNCTION
rem 
rem --causes stepping into a function
rem FUNCTION do_stepinto()
rem   CALL try_stepcmd("stepinto","s")
rem END FUNCTION
rem 
rem --causes stepping over the next line
rem FUNCTION do_stepover()
rem   CALL try_stepcmd("stepover","n")
rem END FUNCTION
rem 
rem --causes stepping out of the current function
rem --and displaying a messagebox with the function result
rem FUNCTION do_stepout()
rem   CALL try_stepcmd("stepout","dummy")
rem END FUNCTION
rem 
rem --real work of doing step out
rem FUNCTION do_stepout_int()
rem   DEFINE i,found,len Integer
rem   DEFINE caller,funcName String
rem   LET found=0
rem   call update_stack()
rem   --remember the caller function if there is one
rem   LET caller=""
rem   LET funcName=stk_arr[1].funcName
rem   IF stk_arr.getLength()>1 THEN
rem     LET caller=stk_arr[2].funcName
rem   END IF
rem   LET len=finish_arr.getLength()
rem   --go through finish_arr and search if we can already find the current function
rem   --or the caller function
rem   FOR i=1 TO len
rem     IF funcName.getLength()>0 AND finish_arr[i].funcName=funcName THEN
rem       --DISPLAY "found finish_entry ",i," for funcName:",funcName,"set caller:",caller,"previous was :",finish_arr[i].caller
rem       LET finish_arr[i].caller=caller
rem       LET found=1
rem       EXIT FOR
rem     ELSE IF caller.getLength()>0 AND finish_arr[i].caller=caller THEN
rem       --DISPLAY "found finish_entry ",i," for caller:",caller,"set funcName:",funcName,"previous was :",finish_arr[i].funcName
rem       LET finish_arr[i].funcName=funcName
rem       LET found=1
rem       EXIT FOR
rem     END IF
rem     END IF
rem   END FOR
rem   --add the top function and his caller to finish_arr
rem   IF found=0 AND caller.getLength()>0 AND funcName.getLength()>0 THEN
rem     LET i=len+1
rem     LET finish_arr[i].funcName = funcName
rem     LET finish_arr[i].caller = caller
rem     --DISPLAY "add  finish_entry ",i," for caller:",caller,"set funcName:",funcName
rem   END IF
rem   CALL do_debugger_step_cmd("finish")
rem END FUNCTION
rem 
rem --parses the command line arguments of this program
rem --and returns the program name and arguments for the debuggee
rem FUNCTION parse_args()
rem   DEFINE i Integer
rem   DEFINE debugger_args,arg_count Integer
rem   DEFINE arg_arr DYNAMIC ARRAY OF String
rem   DEFINE program,args String
rem   LET g_verbose=0
rem   LET debugger_args=0
rem   LET arg_count=0
rem   LET program=""
rem   --DISPLAY "num_args are:",num_args()
rem   FOR i=1 TO num_args()
rem     IF arg_val(i) = "--" THEN
rem       LET debugger_args=1
rem     ELSE IF arg_val(i) = "\\-\\-" THEN
rem       IF debugger_args=0 THEN
rem         LET arg_count=arg_count+1
rem         LET arg_arr[arg_count]="--"
rem       END IF
rem     ELSE
rem       IF debugger_args=0 THEN
rem         LET arg_count=arg_count+1
rem         --DISPLAY "arg_count is ",arg_count
rem         LET arg_arr[arg_count]=arg_val(i)
rem       ELSE
rem         IF arg_val(i)="-v" OR arg_val(i)="--verbose" THEN
rem           LET g_verbose=1
rem         ELSE IF arg_val(i)="-V" OR arg_val(i)="--version" THEN
rem           CALL display_version()
rem         ELSE IF arg_val(i)="-g" OR arg_val(i)="--gdb" THEN
rem           LET g_isgdb=1
rem         ELSE IF arg_val(i)="-h" OR arg_val(i)="--help" THEN
rem           CALL arg_help()
rem         ELSE IF arg_val(i)="-t" OR arg_val(i)="--tty" THEN
rem           LET g_tty = arg_val(i+1)
rem           LET i = i + 1
rem         ELSE IF arg_val(i)="-r" OR arg_val(i)="--restore_breakpoints" THEN
rem           LET g_restore_breakpoints=1
rem         END IF
rem         END IF
rem         END IF
rem         END IF
rem         END IF
rem         END IF
rem       END IF
rem     END IF
rem     END IF
rem   END FOR
rem   FOR i=1 TO arg_count
rem     IF i=1 THEN
rem       LET program=arg_arr[i]
rem     ELSE
rem       LET args=args.append(arg_arr[i])
rem       IF i<>arg_count THEN
rem         LET args=args.append(" ")
rem       END IF
rem     END IF
rem   END FOR
rem   IF g_verbose THEN
rem     DISPLAY "program is \"",program,"\", args are \"",args,"\""
rem   END IF
rem   IF program IS NULL OR ( program == "-h" OR program == "--help") THEN
rem     CALL arg_help()
rem   ELSE IF ( program == "-V" OR program == "--version") THEN
rem     CALL display_version()
rem   END IF
rem   END IF  
rem   RETURN program,args
rem END FUNCTION
rem 
rem FUNCTION arg_help()
rem   DISPLAY "Usage: fgldeb program(.42r|.42m) [programopts] [-- debuggeropts]"
rem   DISPLAY "  Debugger options:"
rem   DISPLAY "    -V or --version   : Display version information"
rem   DISPLAY "    -h or --help      : Display this help"
rem   DISPLAY "    -g or --gdb       : spawn gdb instead of 'fglrun -d'"
rem   DISPLAY "    -t <tty>or --tty <tty> :"
rem   DISPLAY "                        run debuggee with FGLGUI=0 in the terminal"
rem   DISPLAY "    -v or --verbose   : creates a lot of debug output"
rem   EXIT PROGRAM 0
rem END FUNCTION
rem 
rem FUNCTION display_version()
rem   DEFINE d STRING
rem   DISPLAY sfmt("fgldeb %1.%2.%3 build-%4",
rem          g_version_major,g_version_minor,g_version_patch,BUILD_NUMBER)
rem   LET d=CVS_DATE
rem   LET d=d.substring(2,d.getLength()-1)
rem   DISPLAY sfmt("CVS %1",d)
rem   LET d=CVS_REVISION
rem   LET d=d.substring(2,d.getLength()-1)
rem   DISPLAY sfmt("CVS %1",d)
rem   DISPLAY "(c) 2004-2009 Four J's Development Tools"
rem   EXIT PROGRAM 0
rem END FUNCTION
rem 
rem --sets the source code line in the source code array
rem FUNCTION set_src_arr_value(arr,i,str,updatedisplay)
rem   DEFINE arr DYNAMIC ARRAY OF STRING
rem   DEFINE i INTEGER
rem   DEFINE updatedisplay INTEGER
rem   DEFINE str STRING
rem   IF updatedisplay THEN
rem     LET src_arr[i].marker="debug_frame"
rem     LET src_arr[i].lnum=i
rem     LET src_arr[i].line=str
rem     LET src_arr[i].isBreak=0
rem   ELSE
rem     LET arr[i]=str
rem   END IF
rem   --uncomment the next line to see each line read in
rem   --DISPLAY "line ",i,":",str
rem END FUNCTION
rem 
rem --reads in a source code file and saves the content in the
rem --given array "arr"
rem FUNCTION read_in_source (srcName,arr,updatedisplay)
rem   DEFINE srcName STRING --filename of the source code
rem   DEFINE arr DYNAMIC ARRAY OF STRING --array to place the source lines in
rem   DEFINE updatedisplay INTEGER --is this the interactive source file ?
rem   DEFINE errstr,linestr,fullname String
rem   DEFINE ch_src base.Channel
rem   DEFINE i,found Integer
rem   IF g_read_in_source_active THEN
rem     RETURN
rem   END IF
rem   LET g_read_in_source_error=0
rem   LET g_read_in_source_active = 1
rem   LET fullname=srcName
rem   IF NOT file_exists(fullname) THEN
rem     LET found=0
rem     --inspect the directories we already know
rem {
rem -- LET len=dis_arr.getLength()
rem -- FOR i=1 TO len
rem -- --dirarr contains always slashes at the end
rem -- LET fullname=dir_arr[i]||srcName
rem -- IF file_exists(fullname) THEN
rem -- let found=1
rem -- EXIT FOR
rem -- END IF
rem -- END FOR
rem }
rem   ELSE
rem     LET found=1
rem   END IF
rem   IF NOT found THEN
rem     LET fullname=get_full_module_name(srcName)
rem     IF fullname.getLength()=0 THEN
rem       LET found=0
rem     ELSE IF NOT file_exists(fullname) THEN
rem       --LET fullname=input_full_path(srcName)
rem       LET found=0
rem     ELSE
rem       LET found=1
rem     END IF
rem     END IF
rem   END IF
rem   IF NOT found THEN
rem     IF updatedisplay THEN
rem       CALL fgl_winMessage("Debugger", "Cannot find the module\""||srcName||"\",please check FGLSOURCEPATH !", "info")
rem     END IF
rem     CALL deb_error(sfmt("Cannot find the module\"%1\",please check FGLSOURCEPATH !",srcName))
rem     LET g_read_in_source_error=1
rem     GOTO :endfunc
rem   END IF
rem   -- clear the array
rem   IF updatedisplay THEN
rem     CALL src_arr.clear()
rem   ELSE
rem     CALL arr.clear()
rem   END IF
rem   LET ch_src=base.channel.create()
rem   --DISPLAY "read_in_source :",srcName
rem   CALL ch_src.openFile(fullname,"r")
rem   IF status < 0 THEN
rem     LET errstr= "can't read : "||srcName
rem     ERROR errstr
rem     LET g_read_in_source_error=1
rem     GOTO :endfunc
rem   END IF
rem   LET i=1
rem   --CALL ch_src.setDelimiter("")
rem   WHILE (linestr:=ch_src.readline()) IS NOT NULL
rem     {
rem     --look for "\\\n" in the line and deconcat...
rem     WHILE linestr.getIndexOf("\n",1)>0 AND
rem           linestr.getCharAt(linestr.getIndexOf("\n",1)-1)="\\"
rem       LET idx=linestr.getIndexOf("\n",1)
rem       LET l=linestr.subString(1,idx-2)
rem       LET linestr=linestr.subString(idx+1,linestr.getLength())
rem       CALL set_src_arr_value(arr,i,l,updatedisplay )
rem       LET i=i+1
rem     END WHILE
rem     }
rem     CALL set_src_arr_value(arr,i,linestr,updatedisplay)
rem     LET i=i+1
rem   END WHILE
rem   CALL ch_src.close()
rem   IF updatedisplay THEN
rem     LET g_source_lines=i-1
rem     LET g_file_displayed_long=srcName
rem     LET g_file_displayed=get_short_filename(srcName)
rem     CALL fgl_settitle("Debugger - "||srcName)
rem     CALL set_TableColumn_text("src","line",srcName)
rem     MESSAGE "loaded ",srcName
rem     LET g_source_changed=1
rem     LET g_line=1
rem   END IF
rem LABEL endfunc:
rem     LET g_read_in_source_active=0
rem END FUNCTION
rem 
rem FUNCTION get_breakpoint_enabled(breakNum)
rem   DEFINE breakNum, idx INTEGER
rem   LET idx=get_breakpoint_index(breakNum)
rem   IF idx=0 THEN
rem     RETURN "notfound"
rem   END IF
rem   RETURN break_arr[idx].enabled
rem END FUNCTION
rem 
rem --gives back the index in the breakpoint array
rem --if not found, returns 0
rem FUNCTION get_breakpoint_index(breakNum)
rem   DEFINE breakNum,i,len INTEGER
rem   LET len=break_arr.getLength()
rem   FOR i=1 TO len
rem     IF break_arr[i].breakNum=breakNum THEN
rem       RETURN i
rem     END IF
rem   END FOR
rem   RETURN 0
rem END FUNCTION
rem 
rem FUNCTION get_marker (line,breakNum)
rem   DEFINE line,breakNum Integer
rem   DEFINE marker,enabled String
rem   LET marker="debug"
rem   IF breakNum==-1 THEN
rem     LET breakNum=search_breakpoint(line)
rem   END IF
rem   IF breakNum>0 THEN
rem     LET enabled=get_breakpoint_enabled(breakNum)
rem     CASE enabled
rem       WHEN "y"
rem         LET marker=marker || "_break"
rem       WHEN "n"
rem         LET marker=marker || "_break_disabled"
rem     END CASE
rem   END IF
rem   IF line=g_line_0 AND g_file_displayed=g_file_0 THEN
rem     LET marker=marker || "_marker"
rem   ELSE IF g_frame_no>1 AND g_frame_no<=stk_arr.getLength() THEN
rem     IF line=stk_arr[g_frame_no].lineNumber AND
rem         g_file_displayed=stk_arr[g_frame_no].modName THEN
rem       LET marker=marker || "_frame"
rem     END IF
rem   END IF
rem   END IF
rem   IF marker="debug" THEN
rem     --neither a current or breakpoint line
rem     LET marker=""
rem   END IF
rem   IF g_verbose THEN
rem     DISPLAY sfmt("get_marker line:%1,breakNum:%2 returns:%3",line,breakNum,marker)
rem   END IF
rem   RETURN marker
rem END FUNCTION
rem 
rem FUNCTION search_breakpoint(line)
rem   DEFINE line integer
rem   DEFINE i,len Integer
rem   LET len=break_arr.getLength()
rem   FOR i=1 TO len
rem     IF break_arr[i].modName=g_file_displayed AND break_arr[i].lineNumber=line THEN
rem       RETURN break_arr[i].breakNum
rem     END IF
rem   END FOR
rem   RETURN 0
rem END FUNCTION
rem 
rem --deletes the current line marker (top of stack)
rem FUNCTION clear_current_marker()
rem   DEFINE tmp_line Integer
rem   --DISPLAY "clear_current_marker,g_line_0=",g_line_0
rem   IF g_file_0=g_file_displayed AND
rem      g_line_0>0 AND g_line_0<src_arr.getLength() THEN
rem     LET tmp_line=g_line_0
rem     LET g_line_0=-1
rem     --reset the current previous line marker
rem     LET g_line=tmp_line
rem     --DISPLAY "really clear_current_marker,g_line_0=",g_line_0
rem     LET src_arr[tmp_line].marker=get_marker(tmp_line,-1)
rem     LET g_line_0=tmp_line
rem   END IF
rem END FUNCTION
rem 
rem --deletes the frame marker for the current selected stackframe
rem FUNCTION clear_frame_marker()
rem   DEFINE tmp_frame_no,lineNumber Integer
rem   --DISPLAY "clear_frame_marker"
rem   -- DEFINE tmp_line Integer
rem   --IF g_frame_no=1 THEN
rem     --CALL clear_current_marker()
rem   IF g_frame_no>1 AND g_frame_no<=stk_arr.getLength() THEN
rem     LET lineNumber=stk_arr[g_frame_no].lineNumber
rem     IF stk_arr[g_frame_no].modname=g_file_displayed AND
rem        lineNumber>0 AND lineNumber<=src_arr.getLength() THEN
rem       LET tmp_frame_no=g_frame_no
rem       LET g_frame_no=0
rem       LET src_arr[lineNumber].marker=get_marker(lineNumber,-1)
rem       LET g_frame_no=tmp_frame_no
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION clear_all_markers()
rem   --DISPLAY "clear all markers"
rem   CALL clear_frame_marker()
rem   CALL clear_current_marker()
rem END FUNCTION
rem 
rem FUNCTION update_arr_curr(src_line)
rem   DEFINE src_line INT
rem   IF g_in_display THEN
rem     IF g_verbose THEN
rem       DISPLAY "fgl_set_arr_curr:",src_line
rem       DISPLAY "arr_curr():",arr_curr()
rem     END IF
rem     CALL fgl_set_arr_curr(src_line)
rem     --DISPLAY "marker:",src_arr[src_line].marker,",line:",src_arr[src_line].line
rem   ELSE
rem     --IF g_verbose THEN
rem     --  DISPLAY "fgl_dialog_setcurrline ",src_line
rem     --END IF
rem     CALL fgl_dialog_setcurrline (0, src_line)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION goto_src_line (src_line,update_line_0)
rem   DEFINE src_line Integer
rem   DEFINE update_line_0 INT
rem   IF g_verbose THEN
rem     DISPLAY sfmt("goto_src_line:%1,g_line:%2,g_line_0:%3,g_frame_no:%4,g_file_0:%5",src_line,g_line,g_line_0,g_frame_no,g_file_0)
rem   END IF
rem   IF g_file_displayed<>g_file_current THEN
rem     --DISPLAY "exit goto_src_line"
rem     RETURN FALSE
rem   END IF
rem   IF g_frame_no>0 THEN
rem     CALL clear_current_marker()
rem   END IF
rem   CALL update_arr_curr(src_line)
rem 
rem   LET g_line=src_line
rem   IF update_line_0 AND 
rem       g_frame_no=1 AND g_file_0=g_file_displayed THEN
rem     IF g_verbose THEN
rem       DISPLAY "set g_line_0=g_line=",g_line
rem     END IF
rem     LET g_line_0=g_line
rem   END IF
rem   --IF g_frame_no > 1 THEN
rem     --LET src_arr[g_line].marker=get_marker(g_line,-1)
rem     --DISPLAY "marker is ",src_arr[g_line].marker
rem   --END IF
rem   IF g_file_0=g_file_displayed AND 
rem     g_line_0>0 AND g_line_0<=src_arr.getLength() AND
rem     (g_state=ST_INITIAL OR g_state=ST_RUNNING) THEN
rem     LET src_arr[g_line_0].marker=get_marker(g_line_0,-1)
rem     --DISPLAY "set marker in line ",g_line_0," to ",src_arr[g_line_0].marker
rem   END IF
rem   LET g_status_line_no=g_line
rem   CALL update_status(0,"goto_srcline")
rem   RETURN TRUE
rem END FUNCTION
rem 
rem FUNCTION yesno(m)
rem   DEFINE m STRING
rem   DEFINE im,ret STRING
rem   --LET im="exclamation"
rem   LET im="question"
rem   MENU "Message" ATTRIBUTE(STYLE="dialog",COMMENT=m,IMAGE=im)
rem     COMMAND "Yes"
rem       LET ret="yes"
rem       --EXIT MENU
rem     COMMAND "No"
rem       LET ret="no"
rem       --EXIT MENU
rem     {
rem     COMMAND KEY(interrupt)
rem       LET ret="no"
rem       EXIT MENU
rem     }
rem   END MENU
rem   RETURN ret
rem END FUNCTION
rem 
rem --function to get the answer of the debugger
rem --as a response to a g_channel.write("foo")
rem --each answer line from the debugger is
rem --stored in the global "deb_arr"
rem --furthermore the linenumber g_line
rem 
rem FUNCTION get_deb_out()
rem   DEFINE i,num INTEGER
rem   -- check if we are about going recursively into this function
rem   IF g_deb_out_active=1 THEN
rem     LET g_deb_out_repeat=g_deb_out_repeat+1
rem     --DISPLAY "g_deb_out_repeat is ",g_deb_out_repeat
rem   ELSE
rem     LET g_deb_out_active=1
rem     CALL get_deb_out_int()
rem     LET deb_arr_len=deb_arr.getLength()
rem     LET g_deb_out_active=0
rem     LET num=g_deb_out_repeat-1
rem     LET g_deb_out_repeat=0
rem     FOR i=1 TO num
rem       DISPLAY "!!REPEAT g_deb_out, round", i
rem       CALL get_deb_out()
rem     END FOR
rem   END IF
rem END FUNCTION
rem 
rem 
rem FUNCTION get_deb_out_int()
rem   DEFINE linestr,filename,linenumstr String
rem   DEFINE result,i,first,second,ask_continue INTEGER
rem   DEFINE idx,locateidx,len,fatalerror,check_exit,k,dummy INTEGER
rem   DEFINE lastline,err String
rem   --DEFINE check_finish,check_finish2 ,finish_len Integer
rem --Label start:
rem   LET ask_continue=0
rem   LET check_exit=0
rem   CALL deb_arr.clear()
rem   LET idx=0
rem   --read in the lines from the channel
rem   WHILE 1
rem     LET result=g_channel.read(linestr)
rem     IF result= 0 THEN
rem        CALL set_g_state(ST_STOPPED)
rem        DISPLAY "fgldeb:debugger backend terminated"
rem        IF g_quit=0 THEN
rem          LET err="Debugger backend terminated ,"
rem          FOR i=1 TO deb_arr.getLength()
rem            LET err=err.append(sfmt("\n%1",deb_arr[i]))
rem            IF i>10 THEN
rem              EXIT FOR
rem            END IF
rem          END FOR
rem            LET err=err.append("\nContinue?")
rem          --CALL fgl_winmessage("Fatal Error",err,"stop")
rem          IF fgl_winquestion("Fatal Error",err,"no","yes|no","question",0)="yes" THEN
rem            LET g_reload=1
rem          END IF
rem          LET g_quit=1
rem        END IF
rem        LET g_active=0
rem        EXIT WHILE
rem     END IF
rem     LET len=linestr.getLength()
rem     IF g_show_output THEN
rem       IF linestr="(fglgui)" THEN
rem         EXIT WHILE
rem       END IF
rem       DISPLAY linestr
rem     ELSE
rem       IF len> 8000 THEN
rem         --DISPLAY "cut debugger line to 8k"
rem         LET linestr=linestr.subString(1,8000)
rem       END IF
rem       IF g_verbose THEN
rem     --uncomment the next lines to get ALL debugger output
rem     --    IF idx<20 THEN
rem     --      DISPLAY ">>deb>>",idx,":",linestr
rem     --    ELSE IF idx=20 THEN
rem     --      DISPLAY ">>deb .... >>"
rem     --    END IF
rem     --    END IF
rem       END IF
rem       IF linestr="(fglgui)" THEN
rem         EXIT WHILE
rem       END IF
rem     END IF
rem     LET idx=idx+1
rem     LET deb_arr[idx]=linestr
rem     --IF len=0 THEN
rem     -- CONTINUE WHILE
rem     --END IF
rem   END WHILE
rem   LET deb_arr_len=deb_arr.getLength()
rem   LET k=1
rem   LET locateidx=0
rem   --checks the last two answer lines for key strings
rem   FOR i=deb_arr_len TO 1 STEP -1
rem     IF k>2 THEN
rem       EXIT FOR
rem     END IF
rem     LET linestr=deb_arr[i]
rem     LET len=linestr.getLength()
rem     IF len>2 AND linestr.getCharAt(1)==ascii(26) AND linestr.getCharAt(2)==ascii(26) THEN
rem       LET locateidx=idx
rem       LET first=linestr.getIndexOf (":", 3)
rem       IF first<5 THEN
rem         --we got a drive letter followed by a colon
rem         LET first=linestr.getIndexOf (":", first+1)
rem       END IF
rem       LET second=linestr.getIndexOf (":", first+1)
rem       LET filename=linestr.subString(3,first-1)
rem       LET linenumstr=linestr.subString(first+1,second-1)
rem       IF NOT isNumber(linenumstr) THEN
rem         CALL deb_error(sfmt("could not parse linenumber \"%1\" in where line string \"%2\" in get_deb_out_int",linenumstr,linestr))
rem       END IF
rem       LET g_deb_out_filename=filename
rem       LET g_deb_out_line=linenumstr
rem       IF g_verbose THEN
rem         DISPLAY "filename is \"",filename,"\" linenumstr is :",linenumstr
rem       END IF
rem       IF filename<>g_file_displayed_long AND NOT g_deb_out_ignore_linenumber THEN
rem         LET g_source_changed=0
rem         CALL read_in_source(filename,NULL,1)
rem         IF g_source_changed THEN
rem           LET g_file_current_long=filename
rem           LET g_file_current=get_short_filename(g_file_current_long)
rem           IF g_frame_no=1 THEN
rem             LET g_file_0=g_file_current
rem           END IF
rem           IF g_file_0=g_file_current AND g_line_0>0 AND
rem              g_line_0<src_arr.getLength() THEN
rem             --mark the current line
rem             LET src_arr[g_line_0].marker=get_marker(g_line_0,-1)
rem           END IF
rem         END IF
rem       END IF
rem       IF NOT g_deb_out_ignore_linenumber AND g_show_output THEN
rem         IF g_verbose THEN
rem           DISPLAY "get_deb_out:goto_src_line ",g_deb_out_line
rem         END IF
rem         CALL goto_src_line(g_deb_out_line,TRUE) RETURNING dummy
rem       END IF
rem     END IF
rem     IF sent_execution_cmd() OR get_last_keyword()="where" THEN
rem       IF len>0 AND linestr.getIndexOf("Program exited",1)=1 THEN
rem         LET check_exit=1
rem       ELSE IF len>0 AND linestr.getIndexOf("The program is not being run.",1)=1 THEN
rem         CALL set_g_state(ST_STOPPED)
rem         LET ask_continue=1
rem       ELSE IF len>0 AND linestr.getIndexOf("Value returned is ",1)=1 THEN
rem         LET g_check_finish=1
rem           --DISPLAY "set g_check_finish to 1"
rem         LET g_finish_result=linestr.subString(linestr.getIndexOf("Value returned is ",1)+length("Value returned is "),len)
rem       ELSE IF len>0 AND linestr.getIndexOf("Fatal error",1)=1 THEN
rem         LET fatalerror=1
rem       END IF
rem       END IF
rem       END IF
rem       END IF
rem     END IF
rem   END FOR
rem   IF locateidx=deb_arr_len AND deb_arr_len>1 THEN
rem     LET lastline=deb_arr[deb_arr_len-1]
rem   ELSE IF deb_arr_len>0 THEN
rem     LET lastline=deb_arr[deb_arr_len]
rem   ELSE
rem     LET lastline=NULL
rem   END IF
rem   END IF
rem   IF fatalerror=1 THEN
rem     CALL update_status(0,"get_deb_out_int")
rem     CALL fgl_winmessage(deb_arr[1],deb_arr[2],"stop")
rem   END IF
rem   IF check_exit AND lastline IS NOT NULL THEN
rem     IF lastline.getIndexOf("Program exited",1)=1 THEN
rem       DISPLAY "fgldeb:Program exited"
rem       CALL set_g_state(ST_STOPPED)
rem       CALL fgl_winmessage("Debugger",lastline,"stop")
rem     END IF
rem   END IF
rem   IF get_last_keyword()="where" THEN
rem     --fglrun -d answers nothing
rem     IF lastline IS NULL THEN
rem       CALL set_g_state(ST_STOPPED)
rem     --gdb answers no stack
rem     ELSE IF lastline="No stack." THEN
rem       CALL set_g_state(ST_STOPPED)
rem     END IF
rem     END IF
rem   END IF
rem   IF g_state=ST_STOPPED THEN
rem     CALL finish_arr.clear()
rem   END IF
rem   IF g_active=1 AND ask_continue=1 THEN
rem     IF yesno("The program is not being run. Continue debugging ?")="yes" THEN
rem       CALL set_g_state(ST_INITIAL)
rem       LET g_continue=1
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem --lenghty function to parse the "info breakpoints" command
rem --and to update the current viewed modules images correctly
rem 
rem FUNCTION update_breakpoints()
rem   DEFINE len,len2,i,j,startWhat,bcount,lineNumber,breakNum Integer
rem   DEFINE startDisp,endDisp,startEnb,startEnb2,endEnb,tabPos Integer
rem   DEFINE startFunc,endFunc,startMod,endMod,startLine,endNum Integer
rem   DEFINE breakType,enabled,breakNumStr,modName,funcName String
rem   DEFINE head,what,linestr,numStr,inStr,atStr,bpfield String
rem   DEFINE startHit,endHit,break_len integer
rem   DEFINE hitNumStr STRING
rem   --keeps the breakpoint linenumbers of the current module
rem   DEFINE tmp_arr DYNAMIC ARRAY OF Integer
rem   DEFINE break_arr_old DYNAMIC ARRAY OF RECORD
rem     enabled String, breakNum Integer, breakType String, funcName String, lineNumber Integer, modName String, hits Integer, line String, isFunction Integer
rem   END RECORD
rem   DEFINE tmp_count Integer
rem 
rem   --get ALL breakpoints from the runner
rem   CALL deb_write("info breakpoints")
rem   CALL get_deb_out()
rem   LET tmp_count=0
rem   LET len=deb_arr.getLength()
rem   IF len=0 THEN
rem     IF g_verbose THEN
rem       DISPLAY "fgldeb:got no breakpoints"
rem     END IF
rem     RETURN
rem   END IF
rem   --completely update the source array
rem   LET len2=src_arr.getLength()
rem   FOR i=1 TO len2
rem     LET src_arr[i].isBreak=0
rem     LET src_arr[i].marker=""
rem   END FOR
rem   --set the current line Number
rem   IF (g_state=ST_RUNNING OR g_state=ST_INITIAL) AND
rem     g_file_displayed=g_file_0 AND g_line_0>0 AND g_line_0<len2 THEN
rem     LET src_arr[g_line_0].marker="debug_marker"
rem   END IF
rem   --set the current select frame (if ANY)
rem   IF g_frame_no>1 AND g_frame_no<=stk_arr.getLength() THEN
rem     LET lineNumber=stk_arr[g_frame_no].lineNumber
rem     IF g_file_displayed=stk_arr[g_frame_no].modName AND
rem        lineNumber>1 AND lineNumber<len2 THEN
rem       LET src_arr[lineNumber].marker="debug_frame"
rem     END IF
rem   END IF
rem   LET head=deb_arr[1]
rem   --getting the columns for the elements
rem   LET startDisp=head.getIndexOf ("Disp", 3)
rem   LET startEnb=head.getIndexOf ("Enb", 3)
rem   --save this position for worst case
rem   LET startEnb2=startEnb
rem   LET startWhat=head.getIndexOf ("What", 3)
rem   LET bcount=0
rem   --copy the old breakpoint array
rem   LET break_len=break_arr.getLength()
rem   FOR i=1 TO break_len
rem     LET break_arr_old[i].*=break_arr[i].*
rem   END FOR
rem   CALL break_arr.clear()
rem   FOR i=2 TO len
rem     LET linestr=deb_arr[i]
rem     LET tabPos=linestr.getIndexOf("\t",1)
rem     IF tabPos=1 THEN
rem       --ok, we have a tab in the beginning of the line
rem       LET startHit=linestr.getIndexOf("hit ",1)
rem       IF startHit>0 THEN
rem         LET startHit=startHit+length("hit ")+1
rem         LET endHit=linestr.getIndexOf(" ",startHit)-1
rem         LET hitNumStr=linestr.subString(startHit,endHit)
rem         IF breakNum>0 THEN
rem           LET break_arr[breakNum].hits=hitNumStr
rem         END IF
rem       END IF
rem       CONTINUE FOR
rem     END IF
rem     LET endNum=linestr.getIndexOf(" ",1)-1
rem     LET breakNumStr=linestr.subString(1,endNum)
rem     LET breakNum=breakNumStr
rem     WHILE linestr.getCharAt(startDisp)<>"k" AND
rem           linestr.getCharAt(startDisp)<>"d" AND
rem           startDisp<startEnb2
rem       LET startDisp=startDisp+1
rem       LET startEnb =startEnb+1
rem       LET startWhat=startWhat+1
rem     END WHILE
rem     IF linestr.getCharAt(startDisp)<>"k" AND
rem        linestr.getCharAt(startDisp)<>"d" THEN
rem       CALL deb_error("!!!!fgldeb ERROR: can't figure out \"Disp\" location in breakpoint string")
rem       CONTINUE FOR
rem     END IF
rem     LET endDisp=linestr.getIndexOf(" ",startDisp)-1
rem     LET breakType=linestr.subString(startDisp,endDisp)
rem     LET bcount=bcount+1
rem     --LET bcount=breakNum
rem     LET break_arr[bcount].breakType=breakType
rem     LET endEnb=linestr.getIndexOf(" ",startEnb)-1
rem     LET enabled=linestr.subString(startEnb,endEnb)
rem     LET break_arr[bcount].enabled=enabled
rem     LET what=linestr.subString(startWhat,linestr.getLength())
rem     LET inStr=what.subString(1,3)
rem     --DISPLAY "inStr=\"",inStr,"\""
rem     IF inStr="in " THEN
rem       LET break_arr[bcount].breakNum=breakNum
rem       LET startFunc=4
rem       LET endFunc=what.getIndexOf(" ",startFunc)-1
rem       LET funcName=what.subString(startFunc,endFunc)
rem       LET break_arr[bcount].funcName=funcName
rem       LET atStr=what.subString(endFunc+1,endFunc+4)
rem       --DISPLAY "atStr=\"",atStr,"\""
rem       IF atStr=" at " THEN
rem         LET startMod=endFunc+5
rem         LET endMod=what.getIndexOf(":",startMod)-1
rem         LET modName=what.subString(startMod,endMod)
rem         LET break_arr[bcount].modName=modName
rem         LET startLine=endMod+2
rem         LET numStr=what.subString(startLine,what.getLength())
rem         LET lineNumber=numStr
rem         LET break_arr[bcount].lineNumber=lineNumber
rem       END IF
rem       --DISPLAY "bpoint ",bcount,",func:",funcName,",mod:",modName,",line:",lineNumber
rem       IF modName=g_file_displayed THEN
rem         --check if the breakpoint field needs a redisplay
rem         --and remember the linenumber in the tmp_arr
rem         LET tmp_count=tmp_count+1
rem         LET tmp_arr[tmp_count]=lineNumber
rem         LET bpfield=src_arr[lineNumber].marker
rem         --IF bpfield.getLength()=0 OR bpfield<>"circle" THEN
rem         -- LET bpfield="debug_break"
rem         -- IF g_line=lineNumber THEN
rem         -- LET bpfield="debug_breaknmarker"
rem         -- END IF
rem         LET src_arr[lineNumber].marker=get_marker(lineNumber,breakNum)
rem         LET src_arr[lineNumber].isBreak=src_arr[lineNumber].isBreak+1
rem         --END IF
rem       END IF
rem     END IF
rem   END FOR
rem   --look in the old breakpoints, if there is a line information then
rem   -- copy it
rem   LET len=break_arr.getLength()
rem   LET len2=break_arr_old.getLength()
rem   FOR i=1 TO len
rem     LET breakNum=break_arr[i].breakNum
rem     FOR j=1 TO len2
rem       IF break_arr_old[j].breakNum=breakNum THEN
rem         LET break_arr[i].line=break_arr_old[j].line
rem         LET break_arr[i].isFunction=break_arr_old[j].isFunction
rem         EXIT FOR
rem       END IF
rem     END FOR
rem   END FOR
rem   --look if there are breakpoints in the current module array
rem   --which are not in the breakpoint array and delete them
rem   {
rem   LET len=src_arr.getLength()
rem   LET len2=tmp_arr.getLength()
rem   FOR i=1 TO len
rem     IF src_arr[i].isBreak>0 THEN
rem       --we assume a breakpoint in line i
rem       --look if this is true
rem       LET found=0
rem       FOR j=1 TO len2
rem         IF tmp_arr[j]=i THEN
rem           LET found=1
rem           EXIT FOR
rem         END IF
rem       END FOR
rem       IF found=0 THEN
rem         --delete the bitmap
rem         LET bpfield=src_arr[i].marker
rem         IF g_line=lineNumber THEN
rem           LET bpfield="debug_marker"
rem         ELSE
rem           LET bpfield=""
rem         END IF
rem         LET src_arr[lineNumber].marker=bpfield
rem         LET src_arr[lineNumber].isBreak=0
rem       END IF
rem     END IF
rem   END FOR
rem   }
rem END FUNCTION
rem 
rem FUNCTION om_get_current_window_name()
rem   DEFINE w ui.Window
rem   DEFINE n om.DomNode
rem   LET w=ui.Window.getCurrent()
rem   LET n=w.getNode()
rem   RETURN n.getAttribute("name")
rem END FUNCTION
rem 
rem --the following functions build a private
rem --window stack, each ,OPEN_WIN , CURR_WIN
rem --or CLOSE_WIN macro calls the functions
rem 
rem FUNCTION get_current_dialog()
rem   DEFINE win STRING
rem   IF win_arr.getLength()>0 THEN
rem     LET win=win_arr[1]
rem   ELSE
rem     --RETURN om_get_current_window_name()
rem     LET win="fgldeb"
rem   END IF
rem   IF NOT windowExist(win) THEN
rem     LET win="fgldeb"
rem   END IF
rem   RETURN win
rem END FUNCTION
rem 
rem FUNCTION get_current_window_stack()
rem   DEFINE i,len INTEGER
rem   DEFINE result STRING
rem   LET len=win_arr.getLength()
rem   FOR i=1 TO len
rem     LET result=result.append(win_arr[i])
rem     LET result=result.append(" ")
rem   END FOR
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION set_current_dialog(win)
rem   DEFINE win STRING
rem   --DISPLAY "#######CURRENT WINDOW IS ",win
rem   --exclude the main window
rem   IF win="fgldeb" THEN
rem     RETURN
rem   END IF
rem   CALL remove_dialog_name(win)
rem   CALL win_arr.insertElement(1)
rem   LET win_arr[1]=win
rem END FUNCTION
rem 
rem FUNCTION remove_dialog_name(win)
rem   DEFINE win STRING
rem   DEFINE i,len INTEGER
rem   LET len=win_arr.getLength()
rem   FOR i=1 TO len
rem     IF win=win_arr[i] THEN
rem       CALL win_arr.deleteElement(i)
rem       EXIT FOR
rem     END IF
rem   END FOR
rem END FUNCTION
rem 
rem --function to parse the result of "where" (same as "backtrace")
rem --the result is stored in the global "stk_arr"
rem FUNCTION update_stack()
rem   CALL deb_write("where")
rem   CALL get_deb_out()
rem   CALL update_stack1()
rem   CALL check_function_finish()
rem END FUNCTION
rem 
rem FUNCTION update_stack1()
rem   DEFINE i,len,stk_count,endLevel,endFunc,startMod,endMod,found Integer
rem   DEFINE j,stk_len,auto_len INTEGER
rem   DEFINE levelStr,funcName,modName,lineNumberStr,line,auto_frame_name String
rem   CALL stk_arr.clear()
rem   LET len=deb_arr.getLength()
rem   IF len=0 THEN
rem     IF g_verbose THEN
rem       DISPLAY "fgldeb:got no stack"
rem     END IF
rem     CALL auto_arr.clear()
rem     LET auto_arr[1].frame_name="__INIT__"
rem     RETURN
rem   END IF
rem   FOR i=1 TO len
rem     LET line=deb_arr[i]
rem     IF line.subString(1,1)<>"#" THEN
rem       --DISPLAY "line \"",line,"\" is not a \"where\" line "
rem       CONTINUE FOR
rem     END IF
rem     LET stk_count=stk_count+1
rem     --parse out level,funcName,modName and lineNumber
rem     LET endLevel=line.getIndexOf(" ",1)-1
rem     LET levelStr=line.subString(2,endLevel)
rem     LET stk_arr[stk_count].level=levelStr
rem     LET endFunc=line.getIndexOf(" at ",endLevel)-1
rem     LET funcName=line.subString(endLevel+2,endFunc)
rem     LET stk_arr[stk_count].funcName=funcName
rem     LET startMod=endFunc+5
rem     LET endMod=line.getIndexOf(":",startMod)-1
rem     LET modName=line.subString(startMod,endMod)
rem     LET stk_arr[stk_count].modName=modName
rem     LET lineNumberStr=line.subString(endMod+2,line.getLength())
rem     LET stk_arr[stk_count].lineNumber=lineNumberStr
rem     --DISPLAY "level:",levelStr,"count: ",stk_count," funcName:",funcName," modName:",modName," line:",lineNumberStr
rem     --update auto_arr
rem     LET found=0
rem     LET auto_len = auto_arr.getLength()
rem     FOR j=1 TO auto_len
rem       IF auto_arr[j].frame_name=funcName THEN
rem         LET found=1
rem         EXIT FOR
rem       END IF
rem     END FOR
rem     IF NOT found THEN
rem       --DISPLAY "add \"",funcName,"\" to auto_arr"
rem       LET auto_arr[auto_len+1].frame_name=funcName
rem     END IF
rem   END FOR
rem   --IF om_get_current_window_name()=="fgldeb" THEN
rem   -- DISPLAY stk_arr[1].funcName TO currfunc
rem   -- DISPLAY stk_arr[1].lineNumber TO cline
rem   --END IF
rem   LET stk_len=stk_arr.getLength()
rem   IF g_frame_no>0 AND g_frame_no<=stk_len THEN
rem     LET g_frame_name=stk_arr[g_frame_no].funcName
rem     LET g_status_line_no=stk_arr[g_frame_no].lineNumber
rem     CALL update_status(0,"update_stack1")
rem   END IF
rem   --delete unused auto_arr frames
rem   LET auto_len=auto_arr.getLength()
rem   FOR i=1 TO auto_len
rem     LET found=0
rem     LET auto_frame_name=auto_arr[i].frame_name
rem     FOR j=1 TO stk_len
rem       IF stk_arr[j].funcName=auto_frame_name THEN
rem         LET found=1
rem         EXIT FOR
rem       END IF
rem     END FOR
rem     IF NOT found THEN
rem       --DISPLAY "delete \"",auto_frame_name,"\" from auto_arr"
rem       CALL auto_arr.deleteElement(i)
rem     END IF
rem   END FOR
rem END FUNCTION
rem 
rem --is invoked when a get_deb_out gave "Value returned.." back
rem FUNCTION check_function_finish()
rem   DEFINE i,len INTEGER
rem   IF g_check_finish THEN
rem     --check , if one of the break until function returns became true
rem     --DISPLAY "in check_finish2 , stk_arr[1].funcName is:",stk_arr[1].funcName
rem     LET g_check_finish=0
rem     LET len=finish_arr.getLength()
rem     FOR i=1 TO len
rem       --DISPLAY "compare with finish_arr[",i,"]:",finish_arr[i].caller
rem       IF finish_arr[i].caller=stk_arr[1].funcName THEN
rem         OPEN WINDOW finish WITH FORM "fgldeb_finish"
rem         CALL fgl_settitle(sfmt("Step out of %1",finish_arr[i].funcName))
rem         DISPLAY finish_arr[i].funcName TO finishFunc
rem         DISPLAY g_finish_result TO finishResult
rem         MENU "Step Out"
rem           COMMAND "Ok"
rem             EXIT MENU
rem         END MENU
rem         CLOSE WINDOW finish
rem         CALL finish_arr.deleteElement(i)
rem         EXIT FOR
rem       END IF
rem     END FOR
rem   END IF
rem END FUNCTION
rem 
rem --tries to find a slash or backlash
rem --in a given filename
rem FUNCTION get_file_separator(fname)
rem   DEFINE fname,sep String
rem   IF fname.getIndexOf("/",1) <> 0 THEN
rem     LET sep="/"
rem   ELSE IF fname.getIndexOf("\\",1) <> 0 THEN
rem     LET sep="\\"
rem   END IF
rem   END IF
rem   RETURN sep
rem END FUNCTION
rem 
rem --computes a short filename from a long filename
rem FUNCTION get_short_filename(fname)
rem   DEFINE fname,tmpStr,sep String
rem   DEFINE idx Integer
rem   LET tmpStr=fname
rem   LET sep=get_file_separator(fname)
rem   IF sep IS NULL THEN
rem     --no separator, we already have the file
rem     RETURN fname
rem   END IF
rem   LET idx=1
rem   WHILE idx<>0
rem     LET idx=fname.getIndexOf(sep,1)
rem     IF idx<>0 THEN
rem       LET fname=fname.subString(idx+1,fname.getLength())
rem     END IF
rem   END WHILE
rem   --DISPLAY "get_short_filename:original \"",tmpStr,"\" short \"",fname,"\""
rem   RETURN fname
rem END FUNCTION
rem 
rem --gives back the directory portion of a filename
rem FUNCTION get_dirname(fname)
rem   DEFINE fname,dirname,sep String
rem   DEFINE idx,start INTEGER
rem   LET sep=get_file_separator(fname)
rem   --DISPLAY "get_dirname ",fname
rem   IF sep IS NULL THEN
rem     RETURN ""
rem   END IF
rem   LET start=1
rem   LET idx=1
rem   WHILE idx<> 0
rem     LET idx=fname.getIndexOf(sep,1)
rem     IF idx<>0 THEN
rem       LET dirname=dirname.append(fname.subString(start,idx))
rem       LET fname=fname.subString(idx+1,fname.getLength())
rem       LET start=idx+1
rem     END IF
rem   END WHILE
rem   --DISPLAY "dirname= ",dirname
rem   RETURN dirname
rem END FUNCTION
rem 
rem --following a whole bunch of functions to set dynamically the
rem --column title, this should be really a 4gl-library function
rem 
rem FUNCTION set_TableColumn_text(tabName,colName,text)
rem   DEFINE tabName,colName,text String
rem   DEFINE tabId ,colId Integer
rem   DEFINE colNode om.DomNode
rem   LET tabId = _deb_getOmIdTable(tabName)
rem   IF tabId = -1 THEN
rem     RETURN
rem   END IF
rem   --get the TableColumn id
rem   LET colId = _deb_getOmIdTableColumn(tabId,colName)
rem   IF colId = -1 THEN
rem     RETURN
rem   END IF
rem   LET colNode= _deb_omId2Node(colId)
rem   IF colNode IS NULL THEN
rem     RETURN
rem   END IF
rem   CALL colNode.setAttribute("text",text)
rem END FUNCTION
rem 
rem --bunch of om functions
rem 
rem 
rem FUNCTION _deb_omId2Node(omId)
rem    DEFINE omId Integer
rem    DEFINE node om.DomNode
rem    DEFINE doc om.DomDocument
rem    DEFINE idStr String
rem    LET doc =ui.Interface.getDocument()
rem    LET node =doc.getElementById(omId)
rem    IF node IS NULL THEN
rem      LET idStr=omId
rem      CALL deb_error("could not convert id \""||idStr||"\" to a node")
rem    END IF
rem    RETURN node
rem END FUNCTION
rem 
rem FUNCTION _deb_getOmIdXPath(xPathSearchStr,nodeIdForStart)
rem    DEFINE xPathSearchStr String
rem    DEFINE nodeIdForStart Integer
rem    DEFINE r, n om.DomNode
rem    DEFINE nl om.NodeList
rem    DEFINE id Integer
rem    DEFINE doc om.DomDocument
rem    LET doc =ui.Interface.getDocument()
rem    --LET r = ui.Interface.getRootNode()
rem    LET r = doc.getElementById(nodeIdForStart)
rem    IF r IS NULL THEN
rem      RETURN -1
rem    END IF
rem    LET nl = r.selectByPath(xPathSearchStr)
rem    LET id=-1
rem    IF nl.getLength()=1 THEN
rem      let n = nl.item(1)
rem      let id = n.getId()
rem    ELSE IF nl.getLength()>1 THEN
rem      CALL deb_error("_deb_getOmIdXPath:got more than one id for "||xPathSearchStr)
rem      let id = -1
rem    ELSE
rem      CALL deb_error("_deb_getOmIdXPath:did not find an id for "||xPathSearchStr)
rem      let id = -1
rem    END IF
rem    END IF
rem    RETURN id
rem END FUNCTION
rem 
rem FUNCTION _deb_getOmNodeXPath(xPathSearchStr,nodeIdForStart)
rem   DEFINE xPathSearchStr String
rem   DEFINE nodeIdForStart Integer
rem   DEFINE omId INTEGER
rem   LET omId=_deb_getOmIdXPath(xPathSearchStr,nodeIdForStart)
rem   IF omId=-1 THEN
rem     RETURN NULL
rem   END IF
rem   RETURN _deb_omId2Node(omId)
rem END FUNCTION
rem 
rem FUNCTION _deb_getOmIdCurrentWindow()
rem    DEFINE root,currWinNode om.DomNode
rem    DEFINE doc om.DomDocument
rem    DEFINE currWinId Integer
rem    LET root=ui.Interface.getRootNode()
rem    LET currWinId= root.getAttribute("currentWindow")
rem    --sanity check if the currentwindow exists in the tree
rem    LET doc =ui.Interface.getDocument()
rem    LET currWinNode =doc.getElementById(currWinId)
rem    IF currWinNode IS NULL OR currWinNode.getTagName()<>"Window" THEN
rem       CALL deb_error("_deb_getOmIdCurrentWindow, window corrupt")
rem       RETURN -1
rem    END IF
rem    RETURN currWinId
rem END FUNCTION
rem 
rem FUNCTION _deb_getOmNodeByTag(elemName,tagName)
rem   DEFINE elemName String
rem   DEFINE tagName String
rem   DEFINE searchStr String
rem   DEFINE ret om.DomNode
rem   LET searchStr=sfmt("//%1[@tag=\"%2\"]",elemName,tagName)
rem   LET ret= _deb_getOmNodeXPath(searchStr,_deb_getOmIdCurrentWindow())
rem   IF ret IS NULL Then
rem     CALL deb_error("can't get omNode for "||elemName||" with tag \""||tagName||"\"")
rem   END IF
rem   RETURN ret
rem END FUNCTION
rem 
rem FUNCTION _deb_setGroupHidden(tagName,hide)
rem   DEFINE tagName String
rem   DEFINE hide INTEGER
rem   DEFINE node om.DomNode
rem   LET node=_deb_getOmNodeByTag("Group",tagName)
rem   IF node IS NOT NULL THEN
rem     CALL node.setAttribute("hidden",hide)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION _deb_getGroupHidden(tagName)
rem   DEFINE tagName String
rem   DEFINE node om.DomNode
rem   DEFINE result STRING
rem   LET node=_deb_getOmNodeByTag("Group",tagName)
rem   IF node IS NOT NULL THEN
rem     LET result=node.getAttribute("hidden")
rem     IF result IS NULL THEN
rem       LET result="0"
rem     END IF
rem   ELSE
rem     LET result=NULL
rem   END IF
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION _deb_getOmNodeButton(actionName)
rem   DEFINE actionName String
rem   DEFINE searchStr String
rem   DEFINE node om.DomNode
rem   LET searchStr=sfmt("//Button[@name=\"%1\"]",actionName)
rem   LET node= _deb_getOmNodeXPath(searchStr,_deb_getOmIdCurrentWindow())
rem   IF node IS NULL THEN
rem     CALL deb_error("can't get omNode for Button with action \""||actionName||"\"")
rem   END IF
rem   RETURN node
rem END FUNCTION
rem 
rem FUNCTION _deb_setButtonText(actionName,txt)
rem   DEFINE actionName STRING
rem   DEFINE txt STRING
rem   DEFINE node om.DomNode
rem   LET node=_deb_getOmNodeButton(actionName)
rem   IF node IS NOT NULL THEN
rem     CALL node.setAttribute("text",txt)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION _deb_getOmIdTable(tabName)
rem    DEFINE tabName String
rem    DEFINE searchStr String
rem    DEFINE ret Integer
rem    LET searchStr="//Table[@tabName=\"" || tabName || "\"]"
rem    LET ret= _deb_getOmIdXPath(searchStr,0)
rem    IF ret= -1 Then
rem      CALL deb_error("can't get omId for Table \""||tabName||"\"")
rem    END IF
rem    RETURN ret
rem END FUNCTION
rem 
rem 
rem 
rem FUNCTION _deb_getOmIdTableColumn(tabId,colName)
rem   DEFINE tabId Integer
rem   DEFINE colName String
rem   DEFINE searchStr String
rem   DEFINE ret Integer
rem   LET searchStr="//TableColumn[@colName=\"" || colName || "\"]"
rem   LET ret= _deb_getOmIdXPath(searchStr,tabId)
rem   IF ret= -1 Then
rem     CALL deb_error("can't get omId for TableColumn \""||colName||"\"");
rem   END IF
rem   RETURN ret
rem END FUNCTION
rem 
rem FUNCTION _deb_setDialogName(name)
rem   DEFINE name STRING
rem   DEFINE searchStr String
rem   DEFINE currWinId INT
rem   DEFINE node om.DomNode
rem   LET searchStr="//Dialog[@active=\"1\"]"
rem   LET currWinId=_deb_getOmIdCurrentWindow()
rem   LET node= _deb_getOmNodeXPath(searchStr,currWinId)
rem   IF node IS NOT NULL THEN
rem     CALL node.setAttribute("name",name)
rem   ELSE
rem     DISPLAY "fgldeb:can't find active dialog node"
rem   END IF
rem END FUNCTION
rem 
rem 
rem FUNCTION deb_error(str)
rem   define str String
rem   DISPLAY "fgldeb ERROR :",str
rem END FUNCTION
rem 
rem --lets the debugger die
rem FUNCTION do_quit(state)
rem   DEFINE state STRING
rem   -- postpone this until stable
rem   IF yesno("Exit the debugger")="no" THEN
rem     RETURN state
rem   END IF
rem   CALL save_state()
rem   IF g_active THEN
rem     LET g_quit=1
rem     CALL deb_write("quit")
rem     CALL get_deb_out()
rem   END IF
rem   RETURN "exitapp"
rem END FUNCTION
rem 
rem 
rem FUNCTION set_g_state(st)
rem   DEFINE st String
rem   IF (g_state=ST_RUNNING AND st=ST_STOPPED) OR
rem      (g_state=ST_RUNNING AND st=ST_INITIAL) OR
rem      (g_state=ST_STOPPED AND st=ST_RUNNING) OR
rem      (g_state=ST_INITIAL AND st=ST_RUNNING) THEN
rem     --DISPLAY "!!!!!!! clear_all_markers"
rem     CALL clear_all_markers()
rem     CASE st
rem       WHEN ST_RUNNING
rem         IF g_verbose THEN
rem           DISPLAY "set_g_state: switch to running"
rem         END IF
rem         LET g_frame_no=1
rem         LET g_frame_name="main()"
rem         LET g_line_0=g_main_lineNumber
rem         LET g_file_0=g_main_modName
rem       OTHERWISE
rem         IF g_verbose THEN
rem           DISPLAY "set_g_state: reset g_line_0"
rem         END IF
rem         LET g_frame_no=0
rem         LET g_frame_name=""
rem         LET g_line_0=0
rem     END CASE
rem   END IF
rem   IF g_state=ST_INITIAL AND st=ST_STOPPED THEN
rem     LET st=ST_INITIAL
rem   END IF
rem   LET g_state=st
rem   CALL update_status(1,"set_g_state "||g_state)
rem END FUNCTION
rem 
rem --resets the currently selected stackframe to the top
rem --and clears all line markers
rem FUNCTION prepare_stepcmd ()
rem   CALL clear_all_markers()
rem   IF g_state=ST_RUNNING THEN
rem     LET g_frame_no=1
rem   END IF
rem   LET g_continue=0
rem END FUNCTION
rem 
rem --general step function for use within
rem --the main loop
rem FUNCTION do_debugger_step_cmd(cmd)
rem   DEFINE cmd String
rem   CALL prepare_stepcmd()
rem   --while doing the usual step commands we let the output thru to stdout
rem   LET g_show_output=TRUE
rem   CALL set_g_state(ST_RUNNING)
rem   CALL deb_write(cmd)
rem   CALL get_deb_out()
rem   LET g_show_output=FALSE
rem   IF g_state=ST_INITIAL AND g_continue THEN
rem     CALL clear_all_markers()
rem     RETURN
rem   END IF
rem   IF g_state=ST_STOPPED AND g_reload THEN
rem     CALL clear_all_markers()
rem     CALL reopen_program()
rem     RETURN
rem   END IF
rem   CALL update_stack()
rem   CALL update_watch()
rem   CALL update_autovars()
rem   LET g_quit=0
rem END FUNCTION
rem 
rem FUNCTION deb_write (cmd)
rem   DEFINE cmd String
rem   LET g_cmdcount=g_cmdcount+1
rem   IF g_show_output THEN
rem     DISPLAY "$",cmd
rem   ELSE
rem     --uncomment the next line to trace ALL commands sent to the debugger
rem     IF g_verbose THEN
rem       DISPLAY "<<write \"",cmd,"\",count :",g_cmdcount
rem     END IF
rem   END IF
rem   CALL g_channel.write(cmd)
rem   LET g_last_deb_cmd=cmd
rem END FUNCTION
rem 
rem --returns the last command keyword
rem FUNCTION get_last_keyword()
rem   DEFINE endword INTEGER
rem   DEFINE cmd STRING
rem   LET endword=g_last_deb_cmd.getIndexOf(" ",1)
rem   IF endword=0 THEN LET
rem     cmd=g_last_deb_cmd
rem   ELSE
rem     LET cmd=g_last_deb_cmd.subString(1,endword-1)
rem   END IF
rem   LET cmd=complete_fdb_command(cmd)
rem   RETURN cmd
rem END FUNCTION
rem 
rem --did we sent one of the following commands ?
rem FUNCTION sent_execution_cmd()
rem   DEFINE cmd STRING
rem   LET cmd=get_last_keyword()
rem   IF cmd="run" OR cmd="continue" OR cmd="step" OR cmd="next" OR
rem      cmd="until" OR cmd="quit" OR cmd="finish" OR cmd="call" THEN
rem     RETURN 1
rem   ELSE
rem     RETURN 0
rem   END IF
rem END FUNCTION
rem 
rem --makes a complete command name from an incomplete sequence
rem FUNCTION complete_fdb_command (part)
rem   DEFINE part STRING
rem   DEFINE i, len, found, firstidx INTEGER
rem   DEFINE carr DYNAMIC ARRAY OF STRING
rem   LET carr[1] ="break" -- Set breakpoint at specified line or function
rem   LET carr[2] ="tbreak" -- Set a temporary breakpoint
rem   LET carr[3] ="backtrace" -- Print backtrace of all stack frames
rem   LET carr[4] ="bt" -- Print backtrace of all stack frames
rem   LET carr[5] ="continue" -- Continue program being debugged
rem   LET carr[6] ="call" -- Call a function in the program
rem   LET carr[7] ="clear" -- Clear breakpoint at specified line or function.
rem   LET carr[8] ="delete" -- Delete some breakpoints or
rem                            -- auto-display expressions
rem   LET carr[9] ="define" -- Define a new command name.
rem   LET carr[10]="display" -- Print value of expression EXP each time
rem                            -- the program stops
rem   LET carr[11]="disable" -- Disable some breakpoints
rem   LET carr[12]="down" -- Select and print FUNCTION called by this one
rem   LET carr[13]="enable" -- Enable some breakpoints
rem   LET carr[14]="echo" -- Print a constant string
rem   LET carr[15]="file" -- Use FILE as program to be debugged
rem   LET carr[16]="finish" -- Execute until selected stack frame returns
rem   LET carr[17]="frame" -- Select and print a stack frame.
rem   LET carr[18]="help" -- Print list of commands.
rem   LET carr[19]="info" -- Generic command for showing things about
rem                            -- the program being debugged.
rem   LET carr[20]="list" -- List specified function or line
rem   LET carr[21]="next" -- Step program
rem   LET carr[22]="output" -- Like "print" but doesnt put in value history
rem                            -- and doesnt print newline.
rem   LET carr[23]="print" -- Print value of expression EXP
rem   LET carr[24]="quit" -- Exit fgldb
rem   LET carr[25]="run" -- Start debugged program
rem   LET carr[26]="step" -- Step program until it reaches a different source
rem                            -- line
rem   LET carr[27]="set" -- Evaluate expression EXP and assign result to
rem                            -- variable VAR
rem   LET carr[28]="signal" -- Continue program giving it signal specified by
rem                            -- the argument
rem   LET carr[29]="source" -- Read commands from a file named FILE.
rem   LET carr[30]="tty" -- Set terminal for future runs of program being
rem                            -- debugged.
rem   LET carr[31]="up" -- Select and print FUNCTION that called this one
rem   LET carr[32]="undisplay" -- Cancel some expressions to be displayed when
rem                            -- program stops
rem   LET carr[33]="until" -- Execute until the program reaches a source line
rem                            -- greater than the current or a specified line or
rem                            -- address or function (same args as break command)
rem   LET carr[34]="watch" -- Set a watchpoint for an expression
rem   LET carr[35]="where" -- Print backtrace of all stack frames
rem 
rem   LET len=carr.getLength()
rem   FOR i=1 TO len
rem     IF carr[i].getIndexOf(part,1)=1 THEN
rem       LET found=found+1
rem       IF found=1 THEN
rem         LET firstidx=i
rem       -- ELSE
rem         -- DISPLAY "ambigous command \"",part,"\",can be :",carr[firstidx]," or ",carr[i]
rem       END IF
rem     END IF
rem   END FOR
rem   IF found>0 THEN
rem     -- DISPLAY "completed \"",part,"\" to \"",carr[firstidx],"\""
rem     RETURN carr[firstidx]
rem   END IF
rem   RETURN "none"
rem END FUNCTION
rem 
rem --interacts directly with the underlying "TRUE" fdb debugger
rem --the user can type in commands and sees the answer from the
rem --debugger , useful in special situations and for exploring
rem --the richness of the debugger interface
rem 
rem FUNCTION do_fdb_command()
rem   DEFINE c,result,cmd String
rem   DEFINE go_out,i,idxhist,refresh,cidx,insert_in_history Integer
rem   --<BEGIN_OPEN_WIN>
rem   IF NOT windowExist("fdbcommand") THEN 
rem     OPEN WINDOW fdbcommand WITH FORM "fgldeb_fdbcommand" 
rem   ELSE 
rem     CURRENT WINDOW IS fdbcommand 
rem   END IF 
rem   CALL set_current_dialog("fdbcommand")
rem   --<END_OPEN_WIN>
rem   LET go_out=0
rem     WHILE NOT go_out
rem     LET idxhist=0
rem     INPUT BY NAME g_fdbcommand,g_debout WITHOUT DEFAULTS ATTRIBUTES(UNBUFFERED)
rem       --AFTER INPUT
rem         --DISPLAY "COMMAND is ",g_fdbcommand
rem       --<BEGIN_HISTORY>
rem       ON ACTION history_up 
rem         IF INFIELD(g_fdbcommand) THEN 
rem           CALL history_up(fdb_hist_arr,idxhist,g_fdbcommand) RETURNING g_fdbcommand,idxhist 
rem         END IF 
rem       ON ACTION history_down 
rem         IF INFIELD(g_fdbcommand) THEN 
rem           CALL history_down(fdb_hist_arr,idxhist,g_fdbcommand) RETURNING g_fdbcommand,idxhist 
rem         END IF 
rem       ON ACTION history_show 
rem         IF INFIELD(g_fdbcommand) THEN 
rem           CALL history_show(fdb_hist_arr,idxhist,g_fdbcommand) RETURNING g_fdbcommand,idxhist 
rem         END IF
rem       --<END_HISTORY>
rem       ON ACTION showfdbcommands
rem         LET cmd=do_show_all_commands()
rem         IF cmd IS NOT NULL THEN
rem           LET g_fdbcommand=cmd
rem         END IF
rem       ON ACTION refresh
rem         LET refresh=1
rem       ON KEY(Interrupt)
rem         LET go_out=1
rem         --LET g_fdbcommand=""
rem         EXIT INPUT
rem     END INPUT
rem     IF go_out=1 THEN
rem       EXIT WHILE
rem     END IF
rem      -- we need to go out of the current window if one of the following commands
rem     -- is executed
rem     IF refresh THEN
rem       LET g_fdbcommand="where"
rem     END IF
rem     IF length(g_fdbcommand) = 0 THEN
rem       CONTINUE WHILE
rem     END IF
rem     LET cidx=g_fdbcommand.getIndexOf(" ",1)
rem     IF cidx=0 THEN
rem       LET cidx=g_fdbcommand.getLength()+1
rem     END IF
rem     LET c =g_fdbcommand.subString(1,cidx-1)
rem     --DISPLAY "c is \"",c,"\""
rem     LET c= complete_fdb_command (c)
rem     IF refresh OR c="step" OR c="next" OR
rem        c="continue" OR c="break" OR c="tbreak" OR
rem        c="clear" OR c="delete" OR c="return" OR
rem        c="finish" OR c="call" OR c="enable" OR
rem        c="disable" OR c="where" OR c="run" THEN
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       LET refresh=1
rem       IF c="run" THEN
rem         LET g_state=ST_RUNNING
rem       END IF
rem     END IF
rem     IF  c="step" OR c="run" OR c="next" OR c="finish" OR c="continue" THEN
rem       CALL prepare_stepcmd()
rem     END IF
rem     CALL update_status(1,"do_fdb_command")
rem     CALL deb_write(g_fdbcommand)
rem     CALL get_deb_out()
rem     LET result=""
rem     LET insert_in_history=0
rem     FOR i=1 TO deb_arr_len
rem       IF i=1 AND deb_arr[1].getIndexOf("Undefined command",1)=0 THEN
rem         LET insert_in_history=1
rem       END IF
rem       LET result=result.append(deb_arr[i])
rem       LET result=result.append("\n")
rem     END FOR
rem     IF insert_in_history THEN
rem       CALL history_insert(fdb_hist_arr,g_fdbcommand)
rem     END IF
rem     CURRENT WINDOW IS fdbcommand CALL set_current_dialog("fdbcommand")
rem     LET g_debout=result
rem     DISPLAY result TO g_debout
rem     LET c=g_fdbcommand
rem     -- we need to go out of the current window if one of the following commands
rem     -- is executed
rem     IF refresh THEN
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL update_stack()
rem       CALL update_breakpoints()
rem       --DISPLAY "return fdbcommand on ",g_fdbcommand
rem       RETURN "fdbcommand"
rem     END IF
rem     IF c="q" OR c="quit" THEN
rem       LET go_out=1
rem     END IF
rem   END WHILE
rem   CLOSE WINDOW fdbcommand CALL remove_dialog_name("fdbcommand")
rem   --DISPLAY "end of fdbcommand,current window is ", get_current_dialog()
rem   --DISPLAY "stack is \"", get_current_window_stack() , "\""
rem   --RETURN "fgldeb"
rem   RETURN get_current_dialog()
rem END FUNCTION
rem 
rem --inserts an entry into to gieven history array
rem --the function checks for duplicates
rem --and deletes them before inserting the new entry
rem FUNCTION history_insert (hist_arr,entry)
rem   DEFINE hist_arr DYNAMIC ARRAY OF STRING
rem   DEFINE entry STRING
rem   DEFINE i,len INTEGER
rem   --insert the command into the history
rem   --first look if its already in the history
rem   LET len=hist_arr.getLength()
rem   FOR i=1 TO len
rem     IF hist_arr[i]=entry THEN
rem       --DISPLAY "delete entry ",i," for command ",entry
rem       CALL hist_arr.deleteElement(i)
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   CALL hist_arr.insertElement(1)
rem   LET hist_arr[1]=entry
rem   {
rem   -- print out the history array
rem   --LET len=hist_arr.getLength()
rem   --FOR i=1 TO len
rem   -- DISPLAY "hist_arr[",i,"]=",hist_arr[i]
rem   --END FOR
rem   }
rem END FUNCTION
rem 
rem --goes up in the given history array
rem FUNCTION history_up (hist_arr,idx,prevEntry)
rem   DEFINE hist_arr DYNAMIC ARRAY OF STRING
rem   DEFINE idx INTEGER
rem   DEFINE prevEntry,entry STRING
rem   IF hist_arr.getLength()<1 THEN
rem     RETURN prevEntry,idx
rem   END IF
rem LABEL fdb_history_up:
rem   LET idx=idx+1
rem   IF idx>hist_arr.getLength() THEN
rem     LET idx=hist_arr.getLength()
rem   END IF
rem   IF idx=0 THEN
rem     LET entry=""
rem   ELSE
rem     LET entry=hist_arr[idx]
rem   END IF
rem   IF entry IS NOT NULL AND entry=prevEntry AND
rem      hist_arr.getLength()>1 AND idx<hist_arr.getLength() THEN
rem     --the value didnt change
rem     GOTO :fdb_history_up
rem   END IF
rem   RETURN entry,idx
rem END FUNCTION
rem 
rem --goes down in the given history array
rem FUNCTION history_down (hist_arr,idx,prevEntry)
rem   DEFINE hist_arr DYNAMIC ARRAY OF STRING
rem   DEFINE idx INTEGER
rem   DEFINE prevEntry,entry STRING
rem   LET idx=idx-1
rem   IF idx<0 THEN
rem     LET idx=0
rem   END IF
rem   IF idx=0 THEN
rem     LET entry=""
rem   ELSE
rem     LET entry=hist_arr[idx]
rem   END IF
rem   RETURN entry,idx
rem END FUNCTION
rem 
rem --shows a dialog containing the history list
rem FUNCTION history_show(hist_arr,idx,oldvalue)
rem   DEFINE hist_arr DYNAMIC ARRAY OF STRING
rem   DEFINE idx Integer
rem   DEFINE oldvalue,value STRING
rem   DEFINE prevIdx,i,len INTEGER
rem   LET prevIdx=idx
rem   LET value=oldvalue
rem   OPEN WINDOW fdbhistory WITH FORM "fgldeb_fdbhistory" 
rem   CALL set_count(hist_arr.getLength())
rem   DISPLAY ARRAY hist_arr to hist.* ATTRIBUTES(UNBUFFERED)
rem     BEFORE DISPLAY
rem       LET len=hist_arr.getLength()
rem       FOR i=1 TO len
rem         IF hist_arr[i]=value THEN
rem           CALL fgl_set_arr_curr(i)
rem           EXIT FOR
rem         END IF
rem       END FOR
rem     ON KEY(Interrupt)
rem       LET value=oldValue
rem       LET idx=prevIdx
rem       EXIT DISPLAY
rem     ON ACTION delete
rem       --delete the current line in the array
rem       --because this leads to core dumps when we
rem       --stay in the DISPLAY ARRAY, we go out
rem       --and reenter the interaction
rem       CALL hist_arr.deleteElement(arr_curr())
rem     AFTER DISPLAY
rem       LET prevIdx=-1
rem       LET idx=arr_curr()
rem       --DISPLAY "set idx to",idx
rem   END DISPLAY
rem   CLOSE WINDOW fdbhistory
rem   IF idx!=prevIdx THEN
rem     LET value=hist_arr[idx]
rem   ELSE
rem     LET value=oldvalue
rem   END IF
rem   RETURN value,idx
rem END FUNCTION
rem 
rem --shows a dialog containing all commands
rem FUNCTION do_show_all_commands()
rem   DEFINE cmd_arr DYNAMIC ARRAY OF RECORD
rem     cmd String,
rem     hlp String
rem   END RECORD
rem   DEFINE cmd_idx,i,minus2Idx INTEGER
rem   DEFINE line STRING
rem   CALL deb_write("help")
rem   CALL get_deb_out()
rem   IF deb_arr.getLength()<1 THEN
rem     ERROR "debugger did not respond"
rem     RETURN ""
rem   END IF
rem   --DISPLAY "deb_arr[1]=\"",deb_arr[1],"\""
rem   IF deb_arr[1]<>"List of commands" THEN
rem     ERROR "did not get \"List of commands\""
rem     RETURN ""
rem   END IF
rem   CALL cmd_arr.clear()
rem   LET cmd_idx=0
rem   FOR i=2 TO deb_arr_len
rem     LET cmd_idx=cmd_idx+1
rem     LET line=deb_arr[i]
rem     LET minus2Idx=line.getIndexOf(" -- ",1)
rem     LET cmd_arr[cmd_idx].cmd=line.subString(1,minus2Idx-1)
rem     LET cmd_arr[cmd_idx].hlp=line.subString(minus2Idx+3,line.getLength())
rem   END FOR
rem   OPEN WINDOW fdbcommandlist WITH FORM "fgldeb_fdbcommandlist"
rem     LET cmd_idx=0
rem     CALL set_count(cmd_arr.getLength())
rem     DISPLAY ARRAY cmd_arr TO rec.*
rem       AFTER DISPLAY
rem         LET cmd_idx=arr_curr()
rem       ON KEY(Interrupt)
rem         EXIT DISPLAY
rem     END DISPLAY
rem   CLOSE WINDOW fdbcommandlist
rem   IF cmd_idx>0 THEN
rem      RETURN cmd_arr[cmd_idx].cmd
rem      --DISPLAY g_fdbcommand TO g_fdbcommand
rem   END IF
rem   RETURN ""
rem END FUNCTION
rem 
rem 
rem --tries to toggle the breakpoint at the current line
rem --main problem: the debugger does not treat every line as valid
rem --so the debugger eventually takes one of the next lines for
rem --the breakpoint
rem --for switching a breakpoint on this is no problem, however
rem --for switching a breakpoint off this causes problems, because
rem --if we are in a line which has no breakpoint, we think we require
rem --a new one,but it may result that an already existing breakpoints is
rem --created twice,because the real line is different
rem FUNCTION do_toggle_break()
rem   define cmd,breakNum,currlineStr String
rem   define currline,clear Integer
rem   LET cmd="help"
rem   LET breakNum=-1
rem   LET currline=g_line
rem   LET currlineStr=currline
rem   IF search_breakpoint(currline)=0 THEN
rem     LET clear=0
rem     LET cmd=sfmt("break %1:%2",g_file_displayed,currlineStr)
rem   ELSE
rem     --find which breakpoint we have to delete
rem     LET clear=1
rem     LET breakNum=search_breakpoint(currline)
rem     IF breakNum<>0 THEN
rem       LET cmd=sfmt("delete %1",breakNum)
rem     END IF
rem     --LET src_arr[currline].isBreak=0
rem     --IF currline=g_line THEN
rem     -- LET src_arr[currline].marker="debug_marker"
rem     --ELSE
rem     -- LET src_arr[currline].marker=""
rem     --END IF
rem   END IF
rem   CALL deb_write(cmd)
rem   CALL get_deb_out()
rem   CALL check_break_line(currline,clear,g_file_displayed,NULL)
rem END FUNCTION
rem 
rem FUNCTION check_break_line(currline,clear,filename,line_arr)
rem   define filename,breakNumStr,cmd String
rem   define line_arr DYNAMIC ARRAY OF STRING
rem   define currline,clear,breakNum,breakNum2,realLine,bcount,bcount2 Integer
rem   LET bcount=break_arr.getLength()
rem   CALL update_breakpoints()
rem   LET bcount2=break_arr.getLength()
rem   IF clear=0 AND bcount2>bcount THEN
rem     --we requested adding a breakpoint and we also got one breakpoint more
rem     LET breakNum=break_arr[bcount2].breakNum
rem     LET realLine=break_arr[bcount2].lineNumber
rem     --check if we added a 2nd breakpoint
rem     LET breakNum2=search_breakpoint(realLine)
rem     IF realLine!=currline AND breakNum<>breakNum2 THEN
rem       --we have another breakpoint at the same line
rem       --we assume deleting both in this case
rem       --DISPLAY "found breakpoints ",breakNum,",",breakNum2," for line ",realLine,",deleting both"
rem       LET breakNumStr=breakNum
rem       LET cmd="delete "||breakNumStr
rem       CALL deb_write(cmd)
rem       CALL get_deb_out()
rem       LET breakNumStr=breakNum2
rem       LET cmd="delete "||breakNumStr
rem       CALL deb_write(cmd)
rem       CALL get_deb_out()
rem       --finally redisplay the breakpoints again
rem       CALL update_breakpoints()
rem     ELSE
rem 
rem       --remember the context of the breakpoint
rem       IF break_arr[bcount2].modName=filename THEN
rem         IF filename=g_file_displayed THEN
rem           LET break_arr[bcount2].line=src_arr[realLine].line
rem         END IF
rem         IF line_arr.getLength()>=realLine THEN
rem           LET break_arr[bcount2].line=line_arr[realLine]
rem         END IF
rem       END IF
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION do_toggle_breakdisable()
rem   DEFINE breakNumStr,cmd String
rem   LET breakNumStr=search_breakpoint(arr_curr())
rem   IF breakNumStr=="0" THEN
rem     --DISPLAY "no breakpoint found at ",arr_curr()
rem     RETURN
rem   END IF
rem   IF break_arr[breakNumStr].enabled="y" THEN
rem     LET cmd= "disable "
rem   ELSE
rem     LET cmd= "enable "
rem   END IF
rem   LET cmd=cmd || breakNumStr
rem   CALL deb_write(cmd)
rem   CALL get_deb_out()
rem   CALL update_breakpoints()
rem END FUNCTION
rem 
rem 
rem {
rem --implementation using "tbreak"
rem FUNCTION do_run2cursor_int()
rem   DEFINE breakNumStr,cmd,currlineStr String
rem   DEFINE currline,breakNum,bcount,bcount2 Integer
rem   LET currline=arr_curr()
rem   LET currlineStr=currline
rem   LET breakNum=search_breakpoint(currline)
rem   IF breakNum=0 THEN
rem     --remember the number of breakpoints
rem     LET bcount=break_arr.getLength()
rem     LET cmd="tbreak " || g_file_displayed || ":" || currlineStr
rem     CALL deb_write(cmd)
rem     CALL get_deb_out()
rem     CALL update_breakpoints()
rem     LET breakNum=search_breakpoint(currline)
rem     IF breakNum=0 THEN
rem       --the number of breakpoints didnt change, bail out
rem       LET bcount2=break_arr.getLength()
rem       IF bcount2<=bcount THEN
rem         IF g_verbose THEN
rem           CALL deb_error(sfmt("can't set temporary breakpoint on line:%1",currline))
rem         END IF
rem         RETURN
rem       END IF
rem       --ok, we got a new breakpoint, now look if there is already a breakpoint
rem       --with the same line number
rem       LET breakNum=search_breakpoint(break_arr[bcount2].lineNumber)
rem       IF break_arr[bcount2].breakNum<> breakNum THEN
rem         --there is already a breakpoint with the same line number
rem         --delete our temporary breakpoint
rem         LET breakNumStr=break_arr[bcount2].breakNum
rem         --DISPLAY "breakpoint :",breakNum," already handles line number ",break_arr[bcount2].lineNumber," delete temporary breakpoint #",breakNumStr
rem         LET cmd="delete "||breakNumStr
rem         CALL deb_write(cmd)
rem         CALL get_deb_out()
rem         CALL update_breakpoints()
rem       END IF
rem     END IF
rem   END IF
rem   CALL deb_write("continue")
rem   CALL get_deb_out()
rem   CALL update_breakpoints()
rem END FUNCTION
rem }
rem 
rem 
rem FUNCTION show_stack()
rem   DEFINE frame_cmd String
rem   DEFINE frame_no,tmp_frame_no,tmp_line,result,lineNumber Integer
rem   LET result=0
rem   OPEN WINDOW stack WITH FORM "fgldeb_stack"
rem   MESSAGE "Choose a call frame for inspecting"
rem   CALL set_count(stk_arr.getLength())
rem   DISPLAY ARRAY stk_arr TO stk.* ATTRIBUTES(UNBUFFERED)
rem     BEFORE DISPLAY
rem       IF g_state<>ST_RUNNING THEN
rem         CONTINUE DISPLAY
rem       END IF
rem       IF g_frame_no <= stk_arr.getLength() THEN
rem         LET stk_arr[g_frame_no].marker="debug_frame"
rem         CALL fgl_set_arr_curr(g_frame_no)
rem       END IF
rem       IF stk_arr.getLength()>=1 THEN
rem         LET stk_arr[1].marker="debug_marker"
rem       END IF
rem     ON ACTION accept
rem       IF g_state<>ST_RUNNING THEN
rem         LET g_frame_no=0
rem         EXIT DISPLAY
rem       END IF
rem       CALL clear_frame_marker()
rem       LET frame_no=stk_arr[arr_curr()].level
rem       LET frame_cmd=sfmt("frame %1",frame_no)
rem       LET tmp_frame_no=g_frame_no
rem       LET tmp_line=g_line_0
rem       LET g_line_0=-1
rem       LET g_frame_no=frame_no+1
rem       LET g_show_output=TRUE
rem       CALL deb_write(frame_cmd)
rem       CALL get_deb_out()
rem       LET g_show_output=FALSE
rem       LET g_line_0=tmp_line
rem       IF check_new_frame(frame_no) THEN
rem         LET g_frame_name=stk_arr[g_frame_no].funcName
rem         --DISPLAY "g_frame_name:",g_frame_name,",g_frame_no:",g_frame_no,",g_file_displayed:",g_file_displayed,",modName:",stk_arr[g_frame_no].modName
rem         IF g_frame_no>1 AND g_file_displayed=stk_arr[g_frame_no].modName THEN
rem           LET lineNumber=stk_arr[g_frame_no].lineNumber
rem           --DISPLAY "lineNumber:",lineNumber,",srcarr.getLength():",src_arr.getLength()
rem           IF lineNumber>1 AND lineNumber<=src_arr.getLength() THEN
rem             LET src_arr[lineNumber].marker=get_marker(lineNumber,-1)
rem             --DISPLAY sfmt("did set src_arr with line '%1'",src_arr[lineNumber].line)
rem           END IF
rem         END IF
rem         CALL update_autovars()
rem         CALL update_watch()
rem       ELSE
rem         IF g_state=ST_RUNNING THEN
rem           LET g_frame_no=tmp_frame_no
rem         END IF
rem       END IF
rem       LET result=1
rem       EXIT DISPLAY
rem   END DISPLAY
rem   CLOSE WINDOW stack
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION check_new_frame(frame_no)
rem   DEFINE frame_no INTEGER
rem   DEFINE frameline,levelStr STRING
rem   DEFINE endpos,newlevel INTEGER
rem   --DISPLAY "check_new_frame:",frame_no,",deb_arr_len:",deb_arr_len
rem   IF deb_arr_len>0 THEN
rem     LET frameline=deb_arr[1]
rem     IF frameline.getCharAt(1)="#" THEN
rem        LET endpos=frameline.getIndexOf(" ",1)-1
rem        LET levelStr=frameline.subString(2,endpos)
rem        LET newlevel=levelStr
rem        IF newlevel=frame_no THEN
rem          RETURN 1
rem        END IF
rem     END IF
rem   END IF
rem   RETURN 0
rem END FUNCTION
rem 
rem --parses the module names from a comma separated list
rem --returns the index of the currently displayed file
rem FUNCTION parse_module_names(srcline)
rem   DEFINE srcline,mod STRING
rem   DEFINE cidx,finish,src_idx,currpos,currIdx INTEGER
rem   LET cidx=1
rem   LET finish=0
rem   LET src_idx=0
rem   LET currpos=1
rem   LET currIdx=1
rem   CALL mod_arr.clear()
rem   WHILE NOT FINISH
rem     LET cidx=srcline.getIndexOf(",",currpos)
rem     IF cidx > 0 THEN
rem       LET mod=srcline.subString(currpos,cidx-1)
rem       IF srcline.getCharAt(cidx+1)=" " THEN
rem          LET currpos=cidx+2
rem       ELSE
rem          ERROR "parse_sources:did not find space char after \"",mod,"\""
rem          LET currpos=cidx+1
rem       END IF
rem     ELSE
rem       LET mod=srcline.subString(currpos,srcline.getLength())
rem       LET finish=1
rem     END IF
rem     LET src_idx=src_idx+1
rem     LET mod_arr[src_idx]=mod
rem     IF mod=g_file_displayed THEN
rem       LET currIdx=src_idx
rem     END IF
rem   END WHILE
rem   --LET len=mod_arr.getLength()
rem   --FOR i=1 TO len
rem   -- DISPLAY "mod_arr[",i,"]=\"",mod_arr[i],"\""
rem   --END FOR
rem   RETURN currIdx
rem END FUNCTION
rem 
rem --invokes an "info line something" command and
rem --either jumps to the specified location or
rem --just leaves the information about file and line of the object
rem --in g_deb_out_fileName,g_deb_out_line
rem 
rem FUNCTION get_info_line(info_line_cmd,jumpTo)
rem   DEFINE info_line_cmd STRING
rem   DEFINE jumpTo Integer
rem   DEFINE ig ,tmp_frame_no Integer
rem   CALL deb_write(info_line_cmd)
rem   --do not change the displayed file here
rem   LET ig = g_deb_out_ignore_linenumber
rem   LET g_deb_out_ignore_linenumber= NOT jumpTo
rem   --do not change current line,current module
rem   LET tmp_frame_no=g_frame_no
rem   LET g_frame_no=0
rem   --ok, call the magic function
rem   CALL get_deb_out()
rem   --restore the globals
rem   LET g_deb_out_ignore_linenumber= ig
rem   LET g_frame_no=tmp_frame_no
rem END FUNCTION
rem 
rem --gets the full qualified name of a module
rem --returns the empty string in case of error
rem FUNCTION get_full_module_name(srcName)
rem   DEFINE srcName,fullName String
rem   --DEFINE tmp_frame_no Integer
rem   CALL get_info_line(sfmt("info line %1:1",srcName),0)
rem   IF deb_arr.getLength()<3 THEN
rem     --CALL fgl_winmessage("Debugger","No lines in \""||srcName||"\" found","error")
rem     RETURN ""
rem   END IF
rem   LET fullName=g_deb_out_filename
rem   RETURN fullName
rem END FUNCTION
rem 
rem FUNCTION get_function_info(funcName,jumpToFunction)
rem   DEFINE funcName String
rem   DEFINE jumpToFunction Integer
rem   --DEFINE tmp_frame_no Integer
rem   --DEFINE fileName STRING
rem   CALL get_info_line(sfmt("info line %1",funcName),jumpToFunction)
rem   IF deb_arr.getLength()<3 THEN
rem     --CALL fgl_winmessage("Debugger","No info for \""||funcName||"\" found","error")
rem     RETURN "",0
rem   END IF
rem   RETURN g_deb_out_filename,g_deb_out_line
rem END FUNCTION
rem 
rem FUNCTION get_function_info_short(funcName,jumpToFunction)
rem   DEFINE funcName String
rem   DEFINE jumpToFunction Integer
rem   DEFINE file String
rem   DEFINE line Integer
rem   CALL get_function_info(funcName,jumpToFunction) RETURNING file,line
rem   LET file= get_short_filename(file)
rem   RETURN file,line
rem END FUNCTION
rem 
rem FUNCTION jump_to_breakpoint(breakNum)
rem   DEFINE breakNum,jumpidx INTEGER
rem   DEFINE cmd STRING
rem   LET jumpidx=get_breakpoint_index(breakNum)
rem   IF jumpidx<>0 THEN
rem     LET cmd=sfmt("info line %1:%2",break_arr[jumpidx].modName,
rem                                  break_arr[jumpidx].lineNumber)
rem     CALL get_info_line(cmd,1)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION input_full_path(srcName)
rem   DEFINE srcName,path,fname String
rem   OPEN WINDOW input_path WITH FORM "fgldeb_input_path"
rem   LET path=g_src_path
rem   INPUT BY NAME path ATTRIBUTES(UNBUFFERED)
rem     BEFORE INPUT
rem       DISPLAY srcName TO srcName
rem     ON ACTION accept
rem       IF path.getCharAt(path.getLength())="/" THEN
rem         LET fname=path||srcName
rem       ELSE
rem         LET fname=path||"/"||srcName
rem       END IF
rem       IF NOT file_exists(fname) THEN
rem         CALL fgl_winmessage("Debugger","Can't find \""||srcName||"\" in \""||path||"\"!","error")
rem       ELSE
rem         LET g_src_path=path
rem         RETURN path
rem       END IF
rem   END INPUT
rem   CLOSE WINDOW input_path
rem   RETURN ""
rem END FUNCTION
rem 
rem --still to implement fully
rem --someone can take a day for this
rem FUNCTION browse_full_path(srcName,defaultdir)
rem   DEFINE srcName, defaultdir,linestr ,program String
rem   DEFINE find_arr DYNAMIC ARRAY OF String
rem   DEFINE ch base.Channel
rem   DEFINE idx,result Integer
rem   OPEN WINDOW dirlist WITH FORM "fgldeb_dirlist"
rem   LET ch=base.channel.create()
rem   LET program="find "||defaultdir||" -type d -maxdepth 1"
rem   CALL ch.openpipe(program,"r")
rem   CALL ch.setDelimiter("")
rem   WHILE 1
rem     LET result=ch.read(linestr)
rem     IF result= 0 THEN
rem        --DISPLAY "find ready"
rem        EXIT WHILE
rem     END IF
rem     IF linestr="." THEN
rem       LET linestr=".."
rem     END IF
rem     IF linestr.getIndexOf("./",1)=1 THEN
rem       LET linestr=linestr.subString(3,linestr.getLength()-2)
rem     END IF
rem     --DISPLAY "fgldeb:",linestr
rem 
rem     LET idx=idx+1
rem     LET find_arr[idx]=linestr
rem   END WHILE
rem   CALL ch.close()
rem   DISPLAY ARRAY find_arr TO dirlist.* ATTRIBUTES(UNBUFFERED)
rem     ON ACTION accept
rem       LET idx=arr_curr()
rem   END DISPLAY
rem   CLOSE WINDOW dirlist
rem   RETURN ""
rem END FUNCTION
rem 
rem FUNCTION show_modules()
rem   DEFINE len,modline,currIdx Integer
rem   DEFINE srcline String
rem   CALL deb_write("info sources")
rem   CALL get_deb_out()
rem   LET len=deb_arr.getLength()
rem   IF len<3 THEN
rem     ERROR "wrong line count ",len," from debugger"
rem     RETURN
rem   END IF
rem   IF deb_arr[1]<>"Source files for which symbols have been read in:" THEN
rem     ERROR "got wrong answer from debugger:",deb_arr[1]
rem     RETURN
rem   END IF
rem   LET srcline=deb_arr[3]
rem   LET currIdx=parse_module_names(srcline)
rem   OPEN WINDOW modules WITH FORM "fgldeb_modules"
rem   MESSAGE "Choose a module"
rem   LET modline=0
rem   CALL set_count(mod_arr.getLength())
rem   DISPLAY ARRAY mod_arr TO src.*
rem     BEFORE DISPLAY
rem       CALL fgl_set_arr_curr(currIdx)
rem     ON ACTION find
rem       CALL do_find("modules","module names")
rem     ON KEY(Interrupt)
rem       EXIT DISPLAY
rem     AFTER DISPLAY
rem       LET modline = arr_curr()
rem   END DISPLAY
rem   CLOSE WINDOW modules
rem   IF modline<>0 THEN
rem     CALL read_in_source(mod_arr[modline],NULL,1)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION show_functions(jumpToFunction)
rem   DEFINE jumpToFunction Integer
rem   DEFINE funcLine Integer
rem   DEFINE funcName,file,lineStr String
rem   CALL get_function_names()
rem   OPEN WINDOW functions WITH FORM "fgldeb_functions"
rem   MESSAGE "Choose a function"
rem   CALL set_count(g_func_arr.getLength())
rem   DISPLAY ARRAY g_func_arr TO functions.*
rem     {
rem     BEFORE DISPLAY
rem       IF g_state=ST_RUNNING THEN
rem         --jump to the currently active function
rem         LET len=g_func_arr.getLength()
rem         FOR i=1 TO len
rem           IF g_func_arr[i]=g_frame_name THEN
rem             CALL fgl_set_arr_curr(i)
rem             EXIT FOR
rem           END IF
rem         END FOR
rem       END IF
rem     }
rem     BEFORE ROW
rem       --DISPLAY informations about the function
rem       LET funcName=g_func_arr[arr_curr()]
rem       CALL get_function_info(funcName,0) RETURNING file,lineStr
rem       DISPLAY get_short_filename(file) TO modName
rem       DISPLAY file TO fileName
rem       DISPLAY lineStr TO lineNumber
rem     ON ACTION find
rem       CALL do_find("functions","function names")
rem     ON KEY(Interrupt)
rem       EXIT DISPLAY
rem     AFTER DISPLAY
rem       LET funcLine = arr_curr()
rem   END DISPLAY
rem   CLOSE WINDOW functions
rem   IF funcLine<>0 THEN
rem     LET funcName=g_func_arr[funcline]
rem     CALL get_function_info(funcName,jumpToFunction) RETURNING file,lineStr
rem   ELSE
rem     LET funcName=NULL
rem   END IF
rem   RETURN funcName
rem END FUNCTION
rem 
rem --shows a dialog to manage breakpoints, enable/disable/delete/add/jump to
rem FUNCTION show_breakpoints()
rem   DEFINE i,len,breakNum,curr,idx,jumpidx Integer
rem   DEFINE cmd,restartinput,enabled String
rem   DEFINE do_restore ,add_count,cmd_count Integer
rem   DEFINE add_arr DYNAMIC ARRAY OF INTEGER
rem   DEFINE cmd_arr DYNAMIC ARRAY OF STRING
rem   DEFINE b2 DYNAMIC ARRAY OF RECORD
rem     enabled String, breakNum Integer, breakType String, funcName String, lineNumber Integer, modName String, hits Integer, line String, isFunction Integer
rem   END RECORD
rem   CALL update_breakpoints()
rem   OPEN WINDOW break WITH FORM "fgldeb_break"
rem   MESSAGE "Enable/Disable/Add/Delete Breakpoints"
rem   LET curr=1
rem   --look if we invoked the breakpoint window from an actual breakpoint location
rem   LET len=break_arr.getLength()
rem   FOR i=1 TO len
rem     IF break_arr[i].lineNumber=g_line AND
rem        break_arr[i].modName =g_file_displayed THEN
rem       LET curr=i
rem       EXIT FOR
rem     END IF
rem   END FOR
rem 
rem   LET cmd_count=1
rem   LET add_count=1
rem   FOR i=1 TO len
rem     LET b2[i].*=break_arr[i].*
rem   END FOR
rem   LET restartinput=1
rem   WHILE restartinput
rem     LET restartinput=0
rem     LET idx=0
rem     CALL set_count(b2.getLength())
rem     INPUT ARRAY b2 WITHOUT DEFAULTS FROM brk.* ATTRIBUTES(UNBUFFERED,INSERT ROW=0,APPEND ROW=0)
rem       BEFORE INPUT
rem         CALL fgl_set_arr_curr(curr)
rem       ON ACTION addbreak
rem         LET breakNum=do_add_break()
rem         LET idx=get_breakpoint_index(breakNum)
rem         IF breakNum<>0 AND idx<>0 THEN
rem           LET add_arr[add_count]=breakNum
rem           LET add_count=add_count+1
rem           LET restartinput=1
rem           EXIT INPUT
rem         END IF
rem       ON ACTION delete
rem         LET breakNum=b2[arr_curr()].breakNum
rem         IF breakNum IS NULL THEN
rem           CONTINUE INPUT
rem         END IF
rem         LET cmd_arr[cmd_count]=sfmt("delete %1",breakNum)
rem         LET cmd_count=cmd_count+1
rem         IF arr_curr()=b2.getLength() THEN
rem           CALL fgl_set_arr_curr(arr_curr()-1)
rem         END IF
rem         CALL b2.deleteElement(arr_curr())
rem       ON CHANGE enable
rem         LET breakNum=b2[arr_curr()].breakNum
rem         IF breakNum IS NULL THEN
rem           CONTINUE INPUT
rem         END IF
rem         LET enabled=b2[arr_curr()].enabled
rem         IF enabled="y" THEN
rem           LET cmd_arr[cmd_count]=sfmt("enable %1",breakNum)
rem         ELSE
rem           LET cmd_arr[cmd_count]=sfmt("disable %1",breakNum)
rem         END IF
rem         LET cmd_count=cmd_count+1
rem       ON ACTION deleteAll
rem         LET len=b2.getLength()
rem         FOR i=1 TO len
rem           LET cmd_arr[cmd_count]=sfmt("delete %1",break_arr[i].breakNum)
rem           LET cmd_count=cmd_count+1
rem         END FOR
rem         CALL b2.clear()
rem         LET curr=1
rem         LET restartinput=1
rem         EXIT INPUT
rem       ON ACTION jumpto
rem         LET breakNum=b2[arr_curr()].breakNum
rem         IF breakNum IS NULL THEN
rem           CONTINUE INPUT
rem         END IF
rem         --DISPLAY "jump to breakpoint no:",breakNum
rem         LET jumpidx=get_breakpoint_index(breakNum)
rem         EXIT INPUT
rem       ON ACTION cancel
rem         -- throw away all changes
rem         LET do_restore=1
rem         EXIT INPUT
rem     END INPUT
rem     IF restartinput THEN
rem       IF idx<>0 THEN
rem         --adding a record here because inside the input this
rem         --is not possible
rem         IF b2.getLength()=0 THEN
rem           LET curr=1
rem         ELSE
rem           IF b2[b2.getLength()].breakNum IS NULL THEN
rem             LET curr=b2.getLength()
rem           ELSE
rem             LET curr=b2.getLength()+1
rem           END IF
rem         END IF
rem         LET b2[curr].*=break_arr[idx].*
rem       END IF
rem     END IF
rem   END WHILE
rem   IF do_restore THEN
rem     --delete the additional breakpoints
rem     LET len=add_arr.getLength()
rem     FOR i=1 TO len
rem       LET cmd=sfmt("delete %1",add_arr[i])
rem       CALL deb_write(cmd)
rem       CALL get_deb_out()
rem     END FOR
rem   ELSE
rem     --perform the accumulated commands
rem     LET len=cmd_arr.getLength()
rem     FOR i=1 TO len
rem       LET cmd=cmd_arr[i]
rem       CALL deb_write(cmd)
rem       CALL get_deb_out()
rem     END FOR
rem   END IF
rem   --finally update the breakpoints
rem   CALL update_breakpoints()
rem   IF jumpidx<>0 THEN
rem     CALL jump_to_breakpoint(breakNum)
rem   END IF
rem   CLOSE WINDOW break
rem END FUNCTION
rem 
rem FUNCTION do_add_break()
rem   DEFINE complete_name,answer STRING
rem   DEFINE breakNumStart, breakNumEnd,breakNum,idxhist,i,len INTEGER
rem   DEFINE breakNumStr,file,lineStr,browsefunc STRING
rem   OPEN WINDOW addbreak WITH FORM "fgldeb_addbreak"
rem   MESSAGE "Adds a breakpoint in a function"
rem   INPUT BY NAME g_funcName WITHOUT DEFAULTS ATTRIBUTES(UNBUFFERED)
rem     --<BEGIN_HISTORY>
rem     ON ACTION history_up 
rem       IF INFIELD(g_funcName) THEN 
rem         CALL history_up(func_hist_arr,idxhist,g_funcName) RETURNING g_funcName,idxhist 
rem       END IF 
rem     ON ACTION history_down 
rem       IF INFIELD(g_funcName) THEN 
rem         CALL history_down(func_hist_arr,idxhist,g_funcName) RETURNING g_funcName,idxhist 
rem       END IF 
rem     ON ACTION history_show 
rem       IF INFIELD(g_funcName) THEN 
rem         CALL history_show(func_hist_arr,idxhist,g_funcName) RETURNING g_funcName,idxhist
rem       END IF
rem     --<END_HISTORY>
rem     ON ACTION browsefunctions
rem       LET browsefunc=show_functions(0)
rem       IF browsefunc.getLength()<>0 THEN
rem         LET g_funcName=browsefunc
rem       END IF
rem     ON ACTION lookup
rem     --ON KEY(Tab)
rem       --DISPLAY ">>>> KEY TAB !!!"
rem       IF g_funcName.getLength()>0 THEN
rem         LET complete_name=complete_function(g_funcName)
rem         IF complete_name.getLength()>0 THEN
rem           LET g_funcName=complete_name
rem         ELSE
rem           ERROR "Don't find a function beginning with \""||g_funcName||"\""
rem           LET g_funcName=""
rem         END IF
rem       END IF
rem     ON ACTION accept
rem       IF g_funcName.getLength()=0 THEN
rem         CONTINUE INPUT
rem       END IF
rem       CALL get_function_info_short(g_funcName,0) RETURNING file,lineStr
rem       IF file IS NOT NULL THEN
rem         CALL deb_write(sfmt("break %1:%2",file,lineStr))
rem         CALL get_deb_out()
rem         IF deb_arr.getLength()>0 THEN
rem           LET answer=deb_arr[1]
rem           IF answer.getIndexOf("Breakpoint",1)<>1 THEN
rem             ERROR answer
rem             CONTINUE INPUT
rem           ELSE
rem             LET breakNumStart=length("Breakpoint")+2
rem             LET breakNumEnd=answer.getIndexOf(" ",breakNumStart)
rem             LET breakNumStr=answer.subString(breakNumStart,breakNumEnd-1)
rem             LET breakNum=breakNumStr
rem             CALL history_insert(func_hist_arr,g_funcName)
rem             CALL update_breakpoints()
rem             LET len=break_arr.getLength()
rem             FOR i=1 TO len
rem               IF break_arr[i].breakNum=breakNum THEN
rem                 LET break_arr[i].line="FUNCTION "||g_funcName
rem                 LET break_arr[i].isFunction=1
rem                 EXIT FOR
rem               END IF
rem             END FOR
rem             EXIT INPUT
rem           END IF
rem         END IF
rem       END IF
rem   END INPUT
rem   CLOSE WINDOW addbreak
rem   RETURN breakNum
rem END FUNCTION
rem 
rem FUNCTION cant_find ()
rem     ERROR "Cannot find the string \"",srch_search,"\""
rem     CALL fgl_winMessage("Debugger", "Cannot find the string \""||srch_search||"\" !", "info")
rem END FUNCTION
rem 
rem 
rem FUNCTION do_find(kind,title)
rem   DEFINE kind STRING
rem   DEFINE title STRING
rem   DEFINE found,currRow,idxhist,idxfound Integer
rem   OPEN WINDOW search WITH FORM "fgldeb_search"
rem   --please english natives , search for or search in ?
rem   CALL fgl_settitle(sfmt("Search in %1",title))
rem   IF srch_updown IS NULL OR srch_updown.getLength()=0 THEN
rem     LET srch_updown="Down"
rem   END IF
rem   -- use unbuffered, otherwise the searchstring is still not yet available in accept
rem   INPUT BY NAME srch_search, srch_wholeword, srch_matchcase, srch_useMATCHES,srch_updown WITHOUT DEFAULTS ATTRIBUTES(UNBUFFERED)
rem     --<BEGIN_HISTORY>
rem     ON ACTION history_up 
rem       IF INFIELD(srch_search) THEN 
rem         CALL history_up(search_hist_arr,idxhist,srch_search) RETURNING srch_search,idxhist 
rem       END IF 
rem     ON ACTION history_down 
rem       IF INFIELD(srch_search) THEN 
rem         CALL history_down(search_hist_arr,idxhist,srch_search) RETURNING srch_search,idxhist 
rem       END IF 
rem     ON ACTION history_show 
rem       IF INFIELD(srch_search) THEN 
rem         CALL history_show(search_hist_arr,idxhist,srch_search) RETURNING srch_search,idxhist
rem       END IF
rem     --<END_HISTORY>
rem     BEFORE INPUT
rem       IF kind="help" THEN
rem         LET srch_updown="Down"
rem         LET srch_useMATCHES=0
rem         CALL dialog.setFieldActive("srch_wholeword",0)
rem         CALL dialog.setFieldActive("srch_usematches",0)
rem         CALL dialog.setFieldActive("srch_updown",0)
rem       END IF
rem     ON ACTION accept
rem       IF kind="help" THEN
rem         CALL help_search(FALSE) RETURNING found,idxfound
rem       ELSE
rem         CALL int_search(kind,FALSE) RETURNING found, currRow
rem       END IF
rem       IF found=0 THEN
rem         CONTINUE INPUT
rem       ELSE
rem         CALL history_insert(search_hist_arr,srch_search)
rem         EXIT INPUT
rem       END IF
rem   END INPUT
rem   CLOSE WINDOW search
rem   IF found THEN
rem     IF kind="help" THEN
rem       CALL fgl_dialog_setcursor(idxfound)
rem     ELSE
rem       CALL fgl_set_arr_curr(currRow)
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION do_findnext(kind)
rem   DEFINE kind STRING
rem   DEFINE found, idxfound, currRow Integer
rem   IF srch_updown IS NULL OR srch_updown.getLength()=0 THEN
rem     LET srch_updown="Down"
rem   END IF
rem   IF kind="help" THEN
rem     CALL help_search(TRUE) RETURNING found,idxfound
rem   ELSE
rem     CALL int_search(kind,TRUE) RETURNING found, currRow
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION subtract_newlines(str,pos)
rem   DEFINE str STRING
rem   DEFINE pos INTEGER
rem   DEFINE i,len,numnl,newpos INTEGER
rem   LET len=str.getLength()
rem   IF len<pos THEN
rem     LET pos=len
rem   END IF
rem   FOR i=1 TO pos
rem     IF str.getCharAt(i)="\n" THEN
rem       LET numnl=numnl+1
rem     END IF
rem   END FOR
rem   LET newpos=pos-numnl
rem   RETURN newpos
rem END FUNCTION
rem 
rem FUNCTION remove_newlines(strnl)
rem   DEFINE strnl STRING
rem   DEFINE str STRING
rem   DEFINE idx,old INTEGER
rem   LET old=1
rem   WHILE (idx:=strnl.getIndexOf("\n",old))<>0
rem     LET str=str.append (strnl.subString(old,idx-1))
rem     LET old=idx+1
rem   END WHILE
rem   RETURN str
rem END FUNCTION
rem 
rem FUNCTION help_search(set_cursor)
rem   DEFINE set_cursor Integer
rem   DEFINE found,idxfound,startpos Integer
rem   DEFINE helpstr STRING
rem   --LET startpos=subtract_newlines(g_helpstr,g_helpcursor)
rem   LET startpos=g_helpcursor
rem   LET helpstr=remove_newlines(g_helpstr)
rem   WHILE startpos>0 AND NOT found
rem     IF srch_matchcase THEN
rem       LET idxfound=helpstr.getIndexOf(srch_search,startpos)
rem     ELSE
rem       LET idxfound=getIndexOfI(helpstr,srch_search,startpos)
rem     END IF
rem     LET found=idxfound<>0
rem     IF NOT found THEN
rem       IF startpos>1 THEN
rem         --search from the beginning
rem         LET startpos=1
rem       ELSE IF startpos=1 THEN
rem         --bail out
rem         LET startpos=0
rem       END IF
rem       END IF
rem     END IF
rem   END WHILE
rem   IF NOT found THEN
rem     CALL cant_find()
rem   ELSE
rem     --count the newlines and subtract from the cursor position
rem     --LET idxfound=subtract_newlines(helpstr,idxfound)
rem     --DISPLAY "helpcursor is ",g_helpcursor,",startpos is ",startpos," idxfound is ",idxfound
rem     IF set_cursor THEN
rem       CALL fgl_dialog_setcursor(idxfound)
rem     END IF
rem   END IF
rem   RETURN found,idxfound
rem END FUNCTION
rem 
rem 
rem FUNCTION int_search(kind,set_arr_curr)
rem   DEFINE kind STRING
rem   DEFINE set_arr_curr INTEGER
rem   DEFINE line ,leftChar , rightChar,mess String
rem   DEFINE i , len , found , currRow , inc , idx INTEGER
rem   LET currRow= arr_curr()
rem   -- at this place having virtual function calls would be really nice...
rem   CASE kind
rem     WHEN "src"
rem       LET len = src_arr.getLength()
rem     WHEN "functions"
rem       LET len = g_func_arr.getLength()
rem     WHEN "modules"
rem       LET len = mod_arr.getLength()
rem     WHEN "global"
rem       LET len = global_var_arr.getLength()
rem     WHEN "local"
rem       LET len = local_var_arr.getLength()
rem     OTHERWISE
rem       LET len = 0
rem   END CASE
rem   -- start search one row later or earlier
rem   IF srch_updown="Down" THEN
rem     LET inc=1
rem   ELSE
rem     LET inc=-1
rem   END IF
rem   LET found = FALSE
rem   --DISPLAY "srch_updown:",srch_updown,",currRow:",currRow,",len:",len
rem   FOR i=1 TO len
rem     -- I spent half an hour for the following f... line
rem     -- It comes not immediately to the mind of a C-programmer :-)
rem     LET idx=((len+currRow+i*inc-1) MOD len)+1
rem     -- again,
rem     -- at this place having virtual function calls would be really nice...
rem     IF kind="src" THEN
rem       LET line = src_arr[idx].line
rem     ELSE IF kind="functions" THEN
rem       LET line = g_func_arr[idx]
rem     ELSE IF kind="modules" THEN
rem       LET line = mod_arr[idx]
rem     ELSE IF kind="global" THEN
rem       LET line = global_var_arr[idx].varname
rem     ELSE IF kind="local" THEN
rem       LET line = local_var_arr[idx].varname
rem     ELSE
rem       DISPLAY "ERROR:can't get line in int_search, wrong kind:",kind
rem     END IF
rem     END IF
rem     END IF
rem     END IF
rem     END IF
rem     --DISPLAY "idx is ",idx,"line is \"",line,"\"line"
rem     IF srch_matchcase THEN
rem       IF srch_useMATCHES THEN
rem         LET found= line MATCHES srch_search
rem       ELSE
rem         LET found = line.getIndexOf(srch_search, 1)
rem       END IF
rem     ELSE
rem       LET line = line.toLowerCase()
rem       IF srch_useMATCHES THEN
rem         LET found = line MATCHES srch_search.toLowerCase()
rem       ELSE
rem         LET found = line.getIndexOf(srch_search.toLowerCase(),1)
rem       END IF
rem     END IF
rem     IF found AND srch_wholeword THEN
rem       --try to find out if the left side has whitespace or
rem       IF found > 1 THEN
rem         LET leftchar=line.getCharAt(found-1)
rem         IF NOT isDelimiterChar(leftChar) THEN
rem           LET found=0
rem         END IF -- not isDelimiterChar()
rem       END IF -- found > 1
rem       IF found > 1 AND found<line.getLength() THEN
rem         LET rightChar=line.getCharAt(found+srch_search.getLength())
rem         IF NOT isDelimiterChar(rightChar) THEN
rem           LET found=0
rem         END IF -- not isDelimiterChar()
rem       END IF -- found > 1
rem     END IF -- found AND srch_wholeword
rem     IF found THEN
rem       EXIT FOR
rem     ELSE
rem       LET mess=""
rem       IF idx=len AND srch_updown="Down" THEN
rem         LET mess="Passed the end of the file"
rem         MESSAGE mess
rem       ELSE IF idx=0 AND srch_updown="Up" THEN
rem         LET mess="Passed the begin of the file"
rem         MESSAGE mess
rem       END IF
rem       END IF
rem     END IF -- found=0
rem   END FOR
rem   IF found=0 THEN
rem     CALL cant_find()
rem   ELSE
rem     -- found the item
rem     IF set_arr_curr THEN
rem       CALL fgl_set_arr_curr(idx)
rem     END IF
rem   END IF
rem   RETURN found,idx
rem END FUNCTION
rem 
rem FUNCTION isDelimiterChar(ch)
rem   DEFINE ch,delimiters String
rem   DEFINE idx Integer
rem   --DISPLAY "ch is \"",ch,"\""
rem   LET delimiters=" \t()[]{}:,;.?!\"'-+/*=&%$^:#~|@"
rem   LET idx = delimiters.getIndexOf(ch,1)
rem   RETURN idx<>0
rem END FUNCTION
rem 
rem FUNCTION isWhiteSpaceChar(ch)
rem   DEFINE ch STRING
rem   IF ch IS NOT NULL THEN
rem     IF ch=" " OR ch="\t" THEN
rem       RETURN 1
rem     END IF
rem   END IF
rem   RETURN 0
rem END FUNCTION
rem 
rem FUNCTION isNumberChar(ch)
rem   DEFINE ch,numbers STRING
rem   DEFINE idx Integer
rem   LET numbers="0123456789"
rem   LET idx = numbers.getIndexOf(ch,1)
rem   RETURN idx<>0
rem END FUNCTION
rem 
rem FUNCTION isNumber(str)
rem   DEFINE str STRING
rem   DEFINE i,len INTEGER
rem   LET len=str.getLength()
rem   FOR i=1 TO len
rem     IF NOT isNumberChar(str.getCharAt(i)) THEN
rem       RETURN 0
rem     END IF
rem   END FOR
rem   RETURN 1
rem END FUNCTION
rem 
rem --this pretty fuzzy function checks if a given string is a valid
rem --variable name in 4GL or C
rem FUNCTION isVarName(varname)
rem   DEFINE varname STRING
rem   DEFINE i,len,openbrackets,closebrackets,containsbrackets INTEGER
rem   DEFINE containspointer INTEGER
rem   DEFINE c,chars,firstchar STRING
rem   LET len=varname.getLength()
rem   LET chars=" \t0123456789.[,]->_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
rem   IF len=0 THEN
rem     RETURN 0
rem   END IF
rem   LET firstchar= varname.getCharAt(1)
rem   --first character is a number or a delimiter ?
rem   IF isNumberChar(firstchar) OR isDelimiterChar(firstchar) THEN
rem      RETURN 0
rem   END IF
rem   LET containsbrackets= (varname.getIndexOf("[",1)<>0) AND
rem                         (varname.getIndexOf("]",1)<>0)
rem   LET containspointer=g_isgdb AND (varname.getIndexOf("->",1)<>0)
rem   FOR i=2 TO len
rem     LET c= varname.getCharAt(i)
rem     IF chars.getIndexOf(c,1)=0 THEN
rem       RETURN 0
rem     END IF
rem     IF c="-" THEN
rem       IF g_isgdb AND i<len THEN
rem         IF varname.getCharAt(i+1)=">" THEN
rem           LET i=i+1
rem           CONTINUE FOR
rem         END IF
rem       END IF
rem       RETURN 0
rem     ELSE
rem       CASE c
rem         WHEN ">"
rem           RETURN 0
rem         WHEN " "
rem           IF NOT containsbrackets AND NOT containspointer THEN
rem             RETURN 0
rem           END IF
rem         WHEN "["
rem           IF closebrackets>openbrackets THEN
rem             RETURN 0
rem           END IF
rem           LET openbrackets=openbrackets+1
rem         WHEN "]"
rem           LET closebrackets=closebrackets+1
rem           IF closebrackets>openbrackets THEN
rem             RETURN 0
rem           END IF
rem         WHEN ","
rem           --no comma separator in C
rem           IF g_isgdb THEN
rem             RETURN 0
rem           END IF
rem           --must be between 2 brackets in 4gl
rem           IF openbrackets=closebrackets THEN
rem             RETURN 0
rem           END IF
rem       END CASE
rem     END IF
rem   END FOR
rem   RETURN 1
rem END FUNCTION
rem 
rem FUNCTION isCommon_keyword(name)
rem   DEFINE name STRING
rem   DEFINE i,len INTEGER
rem   DEFINE arr DYNAMIC ARRAY OF STRING
rem   --this list does not need to be complete
rem   --it just tries to match common cases
rem   --you can add further keywords here
rem   --if they disturb autodetecting variables
rem   --in g_state<>ST_RUNNING
rem   LET arr[1]="let"
rem   LET arr[2]="if"
rem   LET arr[3]="then"
rem   LET arr[4]="else"
rem   LET arr[5]="for"
rem   LET arr[6]="return"
rem   LET arr[7]="define"
rem   LET arr[8]="case"
rem   LET arr[9]="while"
rem   IF NOT g_isgdb THEN
rem     LET arr[10]="declare"
rem     LET arr[11]="run"
rem     LET arr[12]="returning"
rem     LET arr[13]="call"
rem     LET arr[14]="function"
rem     LET arr[15]="end"
rem     LET arr[16]="and"
rem     LET arr[17]="or"
rem     LET arr[18]="when"
rem   END IF
rem   LET len=arr.getLength()
rem   LET name=name.toLowerCase()
rem   FOR i=1 TO len
rem     IF arr[i]=name THEN
rem       RETURN 1
rem     END IF
rem   END FOR
rem   RETURN 0
rem END FUNCTION
rem 
rem FUNCTION file_exists(f)
rem   DEFINE f STRING
rem   DEFINE c base.Channel
rem   DEFINE result Integer
rem   LET c=base.channel.create()
rem   --DISPLAY "CALL file_exists ",f," ?"
rem   WHENEVER ERROR CONTINUE
rem   CALL c.openFile(f,"r")
rem   IF status <> 0 THEN
rem     LET result=0
rem   ELSE
rem     LET result=1
rem     CALL c.close()
rem   END IF
rem   WHENEVER ERROR STOP
rem   RETURN result
rem {
rem -- DEFINE f,l_cmd,f1 String
rem -- DEFINE l_status,i Integer
rem -- FOR i=1 TO f.getLength()
rem -- IF f.getCharAt(i)="\\" THEN
rem -- LET f1=f1.append("/")
rem -- ELSE
rem -- LET f1=f1.append(f.getCharAt(i))
rem -- END IF
rem -- END FOR
rem -- LET l_cmd= "ls ",f1," >/dev/null 2>/dev/null"
rem -- RUN l_cmd RETURNING l_status
rem -- IF l_status THEN
rem -- --DISPLAY "command \"",l_cmd,"\" failed!!!!"
rem -- RETURN 0
rem -- ELSE
rem -- RETURN 1
rem -- END IF
rem }
rem END FUNCTION
rem 
rem FUNCTION _getClientName()
rem   DEFINE fename String
rem   CALL ui.Interface.frontcall("standard","feinfo", ["fename"],[fename])
rem   IF fename="Genero Desktop Client" THEN
rem     LET fename="GDC"
rem   END IF
rem   RETURN fename
rem END FUNCTION
rem 
rem FUNCTION _setActiveWindow(w)
rem   DEFINE w String
rem   DEFINE prevName string
rem   CALL ui.Interface.frontcall("debugger","setactivewindow", [w],[prevName])
rem   RETURN prevName
rem END FUNCTION
rem 
rem FUNCTION _getActiveWindow()
rem   DEFINE name string
rem   CALL ui.Interface.frontcall("debugger","getactivewindow", [],[name])
rem   RETURN name
rem END FUNCTION
rem 
rem FUNCTION _getDebuggerWindow()
rem   DEFINE name string
rem   CALL ui.Interface.frontcall("debugger","getcurrentwindow", [],[name])
rem   RETURN name
rem END FUNCTION
rem 
rem FUNCTION raise_debugger(location)
rem   DEFINE location,prevWindow,version String
rem   --RETURN
rem   LET version=ui.interface.getFrontEndVersion()
rem   --DISPLAY "raise_debugger ",location,",Version",Version
rem   IF _getClientName() = "GDC" AND version>="1.21.1c-261" AND g_debugger_raised=0 THEN
rem     --DISPLAY ">>>_setActiveWindow current"
rem     LET g_debugger_raised=1
rem     LET prevWindow = _setActiveWindow("current")
rem     --DISPLAY "prevWindow:",prevWindow,", debuggerWindow:",_getDebuggerWindow()
rem     IF prevWindow.getLength()>0 AND prevWindow<>_getDebuggerWindow() THEN
rem       --store this as application window
rem       --DISPLAY "set g_debuggee_widget TO ",prevWindow
rem       LET g_debuggee_widget = prevWindow
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION raise_debuggee(location)
rem   DEFINE location String
rem   DEFINE dummy,version String
rem   --RETURN
rem   LET version=ui.interface.getFrontEndVersion()
rem   --DISPLAY "raise_debuggeeeee ",location,",Version",Version
rem   IF _getClientName() = "GDC" AND version>="1.21.1c-261" AND g_debuggee_widget.getLength()>0 THEN
rem     --DISPLAY ">>>_setActiveWindow ",g_debuggee_widget
rem     LET g_debuggee_raised=1
rem     LET dummy = _setActiveWindow(g_debuggee_widget)
rem   END IF
rem   LET g_debugger_raised=0
rem END FUNCTION
rem 
rem FUNCTION do_about()
rem   DEFINE mycomment String
rem   LET mycomment="fgldeb\t: a Front end for \"fglrun -d\"\n\nVersion\t: " || g_version_str || "\n\nBuild\t: " || sfmt("%1",BUILD_NUMBER)
rem   MENU "About fgldeb" ATTRIBUTES(style="dialog", comment=mycomment ,image="debug_logo")
rem     COMMAND "OK"
rem       EXIT MENU
rem   END MENU
rem END FUNCTION
rem 
rem --this function decides whats next if a global action was
rem --pressed in a (modal) dialog
rem FUNCTION check_dlg_action(action,da_state)
rem   DEFINE action STRING
rem   DEFINE da_state,new_state STRING
rem   DEFINE do_return INTEGER
rem   LET new_state=da_state
rem   CASE action
rem     WHEN "stepinto"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL do_stepinto()
rem     WHEN "stepover"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL do_stepover()
rem     WHEN "run"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL do_run()
rem     WHEN "rerun"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL do_rerun()
rem     WHEN "stepout"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL do_stepout()
rem     WHEN "run2cursor"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem       CALL do_run2cursor()
rem     WHEN "viewlocals"
rem       LET new_state="local_variables"
rem       LET do_return=1
rem     WHEN "viewglobals"
rem       LET new_state="global_variables"
rem       LET do_return=1
rem     WHEN "inspectvariable"
rem       LET new_state="inspectvariable"
rem       LET do_return=1
rem     WHEN "viewstack"
rem       CALL update_stack()
rem       IF show_stack()=1 THEN
rem           RETURN 1,da_state
rem       END IF
rem   END CASE
rem   IF new_state=da_state THEN
rem     LET do_return=0
rem   END IF
rem   RETURN do_return,new_state
rem END FUNCTION
rem 
rem FUNCTION get_variable_names (local_or_global,var_arr,set_values)
rem   DEFINE local_or_global String
rem   DEFINE var_arr DYNAMIC ARRAY OF RECORD
rem     varname String,
rem     value String,
rem     modname String
rem   END RECORD
rem   DEFINE set_values Integer
rem   DEFINE i,j,len,eqidx,maxidx,success Integer
rem   DEFINE str,modname,result STRING
rem   CALL var_arr.clear()
rem   IF (local_or_global="local") THEN
rem     CALL deb_write("info locals")
rem     CALL get_deb_out()
rem     IF deb_arr.getLength()=1 THEN
rem       IF deb_arr[1]="No frame selected." THEN
rem          RETURN
rem       END IF
rem     END IF
rem     FOR i=1 TO deb_arr_len
rem       LET str=deb_arr[i]
rem       LET eqidx=str.getIndexOf(" =",1)
rem       LET var_arr[i].varname=str.subString(1,eqidx-1)
rem       IF set_values THEN
rem         LET maxidx=str.getLength()
rem         IF (maxidx>eqidx+403) THEN
rem           LET maxidx=eqidx+403
rem         END IF
rem         LET var_arr[i].value=str.subString(eqidx+3,maxidx)
rem       END IF
rem     END FOR
rem   ELSE --global
rem     CALL deb_write("info variables")
rem     CALL get_deb_out()
rem     FOR i=1 TO deb_arr_len
rem       LET str=deb_arr[i]
rem       IF str.getLength()=0 THEN
rem         CONTINUE FOR
rem       END IF
rem       IF str.getCharAt(str.getLength())=":" THEN
rem         IF str.getIndexOf("File ",1)=1 THEN
rem           LET modname=str.subString(6,str.getLength()-1)
rem         ELSE
rem           LET modname=str.subString(1,str.getLength()-1)
rem           -- module name
rem         END IF
rem         CONTINUE FOR
rem       END IF
rem       LET j=j+1
rem       LET eqidx=str.getIndexOf(" ",1)
rem       LET var_arr[j].varname=str.subString(1,eqidx-1)
rem       LET var_arr[j].modname=modname
rem     END FOR
rem     IF set_values THEN
rem       LET len=var_arr.getLength()
rem       FOR i=1 TO len
rem         CALL get_print_variable(var_arr[i].varname) RETURNING success,result
rem         LET result=extract_gdb_variable_value(result)
rem         LET var_arr[i].value=result
rem       END FOR
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION get_print_variable(varname)
rem   DEFINE varname STRING
rem   DEFINE cmd,result STRING
rem   DEFINE success INTEGER
rem   LET cmd=sfmt("print %1",varname)
rem   CALL deb_write(cmd)
rem   CALL get_deb_out()
rem   CALL check_printresult() RETURNING success,result
rem   RETURN success,result
rem END FUNCTION
rem 
rem FUNCTION get_function_names ()
rem   DEFINE i,j,eqidx Integer
rem   DEFINE str,func STRING
rem   IF g_function_names_called>0 THEN
rem     LET g_function_names_called=g_function_names_called+1
rem     RETURN
rem   END IF
rem   CALL g_func_arr.clear()
rem   CALL deb_write("info functions")
rem   CALL get_deb_out()
rem   IF deb_arr.getLength()=1 THEN
rem     IF deb_arr[1]="No frame selected." THEN
rem        RETURN
rem     END IF
rem   END IF
rem   LET j=1
rem   FOR i=1 TO deb_arr_len
rem     LET str=deb_arr[i]
rem     LET eqidx=str.getIndexOf("()",1)
rem     LET func=str.subString(1,eqidx-1)
rem     --exclude some cases
rem     IF func.getLength()=0 THEN
rem       CONTINUE FOR
rem     END IF
rem     IF func="<initializer>" THEN
rem       CONTINUE FOR
rem     END IF
rem     IF func.getIndexOf("native ",1)=1 THEN
rem       CONTINUE FOR
rem     END IF
rem     LET g_func_arr[j]=func
rem     LET j=j+1
rem   END FOR
rem   LET g_function_names_called=1
rem END FUNCTION
rem 
rem FUNCTION display_variables(title,local_or_global,var_arr)
rem   DEFINE title STRING
rem   DEFINE local_or_global STRING
rem   DEFINE var_arr DYNAMIC ARRAY OF RECORD
rem     varname String,
rem     value String,
rem     modname String
rem   END RECORD
rem   DEFINE action STRING
rem   CALL fgl_settitle(title)
rem   LET action="noaction"
rem   DISPLAY ARRAY var_arr TO variables.* ATTRIBUTES(UNBUFFERED)
rem     --<BEGIN_STD_ACTIONS>
rem     ON ACTION stepinto 
rem       LET action="stepinto" EXIT DISPLAY 
rem     ON ACTION stepover 
rem       LET action="stepover" EXIT DISPLAY 
rem     ON ACTION stepout 
rem       LET action="stepout" EXIT DISPLAY 
rem     ON ACTION run 
rem       LET action="run" EXIT DISPLAY 
rem     ON ACTION rerun 
rem       LET action="rerun" EXIT DISPLAY 
rem     ON ACTION run2cursor 
rem       LET action="run2cursor" EXIT DISPLAY
rem     --<END_STD_ACTIONS>
rem     ON ACTION accept
rem         LET action="inspectvariable"
rem         LET g_inspectvariable_name=var_arr[arr_curr()].varname
rem         EXIT DISPLAY
rem     ON ACTION viewlocals
rem         IF local_or_global="global" THEN
rem           LET action="viewlocals"
rem           EXIT DISPLAY
rem         END IF
rem     ON ACTION viewglobals
rem         IF local_or_global="local" THEN
rem           LET action="viewglobals"
rem           EXIT DISPLAY
rem         END IF
rem     ON ACTION viewstack
rem         LET action="viewstack"
rem         EXIT DISPLAY
rem     ON ACTION find
rem         IF local_or_global="local" THEN
rem           CALL do_find("local","local variables")
rem         ELSE
rem           CALL do_find("global","global variables")
rem         END IF
rem     ON ACTION findnext
rem         IF local_or_global="local" THEN
rem           CALL do_findnext("local")
rem         ELSE
rem           CALL do_findnext("global")
rem         END IF
rem     ON ACTION close
rem       EXIT DISPLAY
rem   END DISPLAY
rem   RETURN action
rem END FUNCTION
rem 
rem FUNCTION showvariables (local_or_global)
rem   DEFINE local_or_global String
rem   DEFINE title String
rem   DEFINE da_state,action String
rem   DEFINE do_return Integer
rem   IF (local_or_global="local") THEN
rem     LET title=sfmt("Local Variables of %1",g_frame_name)
rem     CALL get_variable_names("local",local_var_arr,1)
rem     --<BEGIN_OPEN_WIN>
rem     IF NOT windowExist("local_variables") THEN 
rem       OPEN WINDOW local_variables WITH FORM "fgldeb_variables" 
rem     ELSE 
rem       CURRENT WINDOW IS local_variables 
rem     END IF 
rem     CALL set_current_dialog("local_variables")
rem     --<END_OPEN_WIN>
rem     CALL set_count(local_var_arr.getLength())
rem     LET action=display_variables(title,local_or_global,local_var_arr)
rem   ELSE
rem     LET title="Global Variables"
rem     CALL get_variable_names("global",global_var_arr,1)
rem     --<BEGIN_OPEN_WIN>
rem     IF NOT windowExist("global_variables") THEN 
rem       OPEN WINDOW global_variables WITH FORM "fgldeb_variables" 
rem     ELSE 
rem       CURRENT WINDOW IS global_variables 
rem     END IF 
rem     CALL set_current_dialog("global_variables")
rem     --<END_OPEN_WIN>
rem     CALL set_count(local_var_arr.getLength())
rem     LET action=display_variables(title,local_or_global,global_var_arr)
rem   END IF
rem   LET da_state=local_or_global||"_variables"
rem   CALL check_dlg_action(action,da_state)
rem          RETURNING do_return,da_state
rem   --DISPLAY "check_dlg_state in showvar returned ",do_return," ",da_state
rem   IF do_return THEN
rem     RETURN da_state
rem   END IF
rem   IF action = "noaction" THEN
rem     IF local_or_global="local" THEN
rem       CLOSE WINDOW local_variables CALL remove_dialog_name("local_variables")
rem     ELSE
rem       CLOSE WINDOW global_variables CALL remove_dialog_name("global_variables")
rem     END IF
rem     --DISPLAY "close end of showvariables,current window is ", get_current_dialog()
rem     --DISPLAY "stack is \"", get_current_window_stack() , "\""
rem     --LET da_state="fgldeb"
rem     LET da_state=get_current_dialog()
rem   END IF
rem   --DISPLAY "showvariables:",local_or_global," action is ",action," da_state is ",da_state
rem   RETURN da_state
rem END FUNCTION
rem 
rem -- this function tries to detect, if the variable contains an array range
rem -- for example foo[1:20] or foo[8:4].bar
rem -- returns either the range in from, to or -1,-1
rem FUNCTION parse_range(variable)
rem   DEFINE variable STRING
rem   DEFINE rangestr,oldstate,state,tostr,fromstr,c,newvar,arrayname STRING
rem   DEFINE i, len, from , to ,arrleft,arrright INTEGER
rem   LET arrleft = variable.getIndexOf("[",1)
rem   LET arrright = variable.getIndexOf("]",1)
rem   IF arrleft=0 OR arrright=0 OR arrleft>arrright THEN
rem     RETURN -1,-1,"",""
rem   END IF
rem   LET arrayname=variable.subString(1,arrleft-1)
rem 
rem   FOR i=arrleft+1 TO arrright-1
rem     LET c=variable.getCharAt(i)
rem     IF c<>" " THEN
rem       LET rangestr = rangestr.append(c)
rem     END IF
rem   END FOR
rem   --DISPLAY "rangestr=",rangestr
rem   LET state="from"
rem   LET len=rangestr.getLength()
rem   FOR i=1 TO len
rem     LET c=rangestr.getCharAt(i)
rem     LET oldstate=state
rem     IF isNumberChar(c) THEN
rem       CASE state
rem         WHEN "from"
rem           LET fromstr=fromstr.append(c)
rem         WHEN "to"
rem           LET tostr=tostr.append(c)
rem         WHEN "colon"
rem           LET state="to"
rem           LET tostr=tostr.append(c)
rem       END CASE
rem     ELSE IF c=":" THEN
rem       IF state="from" THEN
rem         LET from = fromstr
rem       ELSE
rem         --DISPLAY "wrong state :",state
rem         RETURN -1,-1,"",arrayname
rem       END IF
rem       LET state="colon"
rem     ELSE
rem       --DISPLAY "found wrong character \"",c,"\" , no range"
rem       RETURN -1,-1,"",""
rem     END IF
rem     END IF
rem     --DISPLAY "character \"",c,"\" old:",oldstate," new:",state
rem   END FOR
rem   IF state="from" THEN
rem     --normal array index without colon
rem     LET from = fromstr
rem     IF from=0 THEN
rem       LET from=1
rem     END IF
rem     RETURN from,from,"",arrayname
rem   END IF
rem   IF state<>"to" THEN
rem     --DISPLAY "wrong endstate \"",state,"\" must be \"to\""
rem     RETURN -1,-1,"",arrayname
rem   END IF
rem   LET to = tostr
rem   IF from = 0 THEN
rem     LET from=1
rem   END IF
rem   IF to = 0 THEN
rem     LET to=1
rem   END IF
rem   IF from=to THEN
rem     RETURN from,from,sfmt("%1[%2]",arrayname,from),arrayname
rem   END IF
rem   LET newvar = variable.subString(1,arrleft)
rem   LET newvar = newvar.append("%1")
rem   LET newvar = newvar.append(variable.subString(arrright,variable.getLength()))
rem   --DISPLAY "got from:",from," to:",to," newvar:",newvar
rem   RETURN from,to,newvar,arrayname
rem END FUNCTION
rem 
rem {
rem FUNCTION fillstep(rangevar,i)
rem   DEFINE rangevar,istr STRING
rem   DEFINE i INTEGER
rem   LET idx=rangevar.getIndexOf("@",1)
rem   LET stepvar=sfmt(rangevar,i)
rem   LET istr=i
rem END FUNCTION
rem }
rem 
rem FUNCTION complete_variable(varname)
rem   DEFINE varname,v,result STRING
rem   DEFINE var_arr DYNAMIC ARRAY OF RECORD
rem     varname String,
rem     value String,
rem     modname String
rem   END RECORD
rem   DEFINE result_arr DYNAMIC ARRAY OF RECORD
rem     varname String,
rem     global Integer
rem   END RECORD
rem   DEFINE i,g,k,len Integer
rem   LET varname=varname.toLowerCase()
rem   --DISPLAY "varname is ",varname
rem   FOR g=0 TO 1
rem     IF g=0 THEN
rem       CALL get_variable_names ("local",var_arr,0)
rem     ELSE
rem       CALL get_variable_names ("global",var_arr,0)
rem     END IF
rem     LET len=var_arr.getLength()
rem     --DISPLAY "var_arr len is ",len
rem     FOR i=1 TO len
rem       LET v=var_arr[i].varname
rem       --DISPLAY "v[",i,"] is ",v
rem       LET v=v.toLowerCase()
rem       IF v.getIndexOf(varname,1) = 1 THEN
rem         LET k=k+1
rem         --DISPLAY "add variable \"",v,"\" at ",k
rem         LET result_arr[k].varname=v
rem         LET result_arr[k].global =g
rem       END IF
rem     END FOR
rem   END FOR
rem   --DISPLAY "k is ",k
rem   CASE k
rem     WHEN 0
rem       LET result=""
rem     WHEN 1
rem       LET result=result_arr[1].varname
rem     OTHERWISE
rem       OPEN WINDOW complete_variable WITH FORM "fgldeb_complete_variable"
rem       CALL set_count(k)
rem       DISPLAY ARRAY result_arr TO complete_variable.* ATTRIBUTES(UNBUFFERED)
rem         ON ACTION accept
rem           LET result=result_arr[arr_curr()].varname
rem           EXIT DISPLAY
rem       END DISPLAY
rem       CLOSE WINDOW complete_variable
rem   END CASE
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION complete_function(funcName)
rem   DEFINE funcName,v,result STRING
rem   DEFINE result_arr DYNAMIC ARRAY OF RECORD
rem     funcName String
rem   END RECORD
rem   DEFINE i,k,len Integer
rem   LET funcName=funcName.toLowerCase()
rem   --DISPLAY "funcName is ",funcName
rem   CALL get_function_names ()
rem   LET len=g_func_arr.getLength()
rem   --DISPLAY "g_func_arr len is ",len
rem   FOR i=1 TO len
rem     LET v=g_func_arr[i]
rem     --DISPLAY "v[",i,"] is ",str
rem     LET v=v.toLowerCase()
rem     IF v.getIndexOf(funcName,1) = 1 THEN
rem       LET k=k+1
rem       --DISPLAY "add variable \"",v,"\" at ",k
rem       LET result_arr[k].funcName=v
rem     END IF
rem   END FOR
rem   --DISPLAY "k is ",k
rem   CASE k
rem     WHEN 0
rem       LET result=""
rem     WHEN 1
rem       LET result=result_arr[1].funcName
rem     OTHERWISE
rem       OPEN WINDOW complete_function WITH FORM "fgldeb_complete_function"
rem       CALL set_count(k)
rem       DISPLAY ARRAY result_arr TO complete_function.* ATTRIBUTES(UNBUFFERED)
rem         ON ACTION accept
rem           LET result=result_arr[arr_curr()].funcName
rem           EXIT DISPLAY
rem       END DISPLAY
rem       CLOSE WINDOW complete_function
rem   END CASE
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION check_printresult()
rem   DEFINE result,line STRING
rem   DEFINE success INTEGER
rem   IF deb_arr.getLength()<1 THEN
rem     RETURN success,result
rem   END IF
rem   LET line=deb_arr[1]
rem   IF line.getIndexOf("No symbol \"",1)=1 THEN
rem     LET result=line
rem   ELSE IF line.getIndexOf("Symbol \"",1)=1 THEN
rem     LET result=line
rem   ELSE IF line.getIndexOf("An execution error in expression:",1)=1 THEN
rem     LET result="ERROR"
rem     LET result=result.append(":")
rem     LET result=result.append(deb_arr[2])
rem     IF deb_arr[2].getIndexOf("An array variable has been referenced",1)<> 0 THEN
rem        CALL get_variable_names("global",global_var_arr,0)
rem        IF global_var_arr.getLength()>0 THEN
rem          CALL deb_write(sfmt("print %1",global_var_arr[1].varname))
rem          CALL get_deb_out()
rem        END IF
rem     END IF
rem   ELSE IF line.getIndexOf("A parse error in expression",1)=1 THEN
rem     LET result=line
rem   ELSE
rem     LET success=1
rem     LET result=line
rem   END IF
rem   END IF
rem   END IF
rem   END IF
rem   RETURN success,result
rem END FUNCTION
rem 
rem 
rem FUNCTION get_variable_substring_intern(varname,result,from,to)
rem   DEFINE varname,result,strvalue,func STRING
rem   DEFINE from,to INTEGER
rem   LET result=extract_gdb_variable_value(result)
rem   IF result.getCharAt(1)<>"\"" THEN
rem     --this is not a string
rem     RETURN ""
rem   END IF
rem   LET strvalue=result.subString(2,result.getLength()-1)
rem   LET strvalue=strvalue.subString(from,to)
rem   IF from=to THEN
rem     LET func=sfmt("getCharAt(%1)",from)
rem   ELSE
rem     LET func=sfmt("subString(%1,%2)",from,to)
rem   END IF
rem   LET strvalue=sfmt("%1.%2 = \"%3\"",varname,func,strvalue)
rem   RETURN strvalue
rem END FUNCTION
rem 
rem FUNCTION get_variable_substring(varname,result,from,to)
rem   DEFINE varname,result,oldResult STRING
rem   DEFINE from,to,success INTEGER
rem   LET oldResult=result
rem   --we tried perhaps to get the nth character of a string
rem   CALL get_print_variable(varname) RETURNING success, result
rem   IF success THEN
rem     LET result=get_variable_substring_intern(varname,result,from,to)
rem     IF result IS NULL THEN
rem       LET result=oldResult
rem     END IF
rem   ELSE
rem     LET result=oldResult
rem   END IF
rem   RETURN success,result
rem END FUNCTION
rem 
rem --opens up a dialog for inspecting variables, adding and deleting them
rem --from the watch list
rem FUNCTION inspectvariable(update_immediate)
rem   DEFINE update_immediate Integer
rem   DEFINE result,action,singleres STRING
rem   DEFINE complete_name,da_state STRING
rem   DEFINE i,len,go_out,idxhist,insert_in_history Integer
rem   DEFINE success,numerrors,do_update_watch Integer
rem   DEFINE var_arr DYNAMIC ARRAY OF STRING
rem   DEFINE do_return Integer
rem   --<BEGIN_OPEN_WIN>
rem   IF NOT windowExist("inspectvariable") THEN 
rem     OPEN WINDOW inspectvariable WITH FORM "fgldeb_inspectvariable" 
rem   ELSE 
rem     CURRENT WINDOW IS inspectvariable 
rem   END IF 
rem   CALL set_current_dialog("inspectvariable")
rem   --<END_OPEN_WIN>
rem   WHILE NOT go_out
rem     LET action="noaction"
rem     LET do_update_watch=0
rem     IF NOT update_immediate=1 THEN
rem       INPUT BY NAME g_inspectvariable_name,g_inspectvariable_value
rem         WITHOUT defaults
rem         HELP 2
rem         ATTRIBUTES(UNBUFFERED)
rem         BEFORE INPUT
rem           CALL DIALOG.setActionHidden("help",0)
rem           CALL update_watch()
rem         --<BEGIN_HISTORY>
rem         ON ACTION history_up 
rem           IF INFIELD(g_inspectvariable_name) THEN 
rem             CALL history_up(inspectvar_hist_arr,idxhist,g_inspectvariable_name) RETURNING g_inspectvariable_name,idxhist 
rem           END IF 
rem         ON ACTION history_down 
rem           IF INFIELD(g_inspectvariable_name) THEN 
rem             CALL history_down(inspectvar_hist_arr,idxhist,g_inspectvariable_name) RETURNING g_inspectvariable_name,idxhist 
rem           END IF 
rem         ON ACTION history_show 
rem           IF INFIELD(g_inspectvariable_name) THEN 
rem             CALL history_show(inspectvar_hist_arr,idxhist,g_inspectvariable_name) RETURNING g_inspectvariable_name,idxhist
rem           END IF
rem         --<END_HISTORY>
rem         --<BEGIN_STD_ACTIONS>
rem         ON ACTION stepinto 
rem           LET action="stepinto" EXIT INPUT 
rem         ON ACTION stepover 
rem           LET action="stepover" EXIT INPUT 
rem         ON ACTION stepout 
rem           LET action="stepout" EXIT INPUT 
rem         ON ACTION run 
rem           LET action="run" EXIT INPUT 
rem         ON ACTION rerun 
rem           LET action="rerun" EXIT INPUT 
rem         ON ACTION run2cursor 
rem           LET action="run2cursor" EXIT INPUT
rem         --<END_STD_ACTIONS>
rem         ON KEY(Interrupt)
rem           LET go_out=1
rem           LET g_inspectvariable_name=""
rem           EXIT INPUT
rem         ON ACTION grab
rem           CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem           --LET foundvar=tryfindvar_on_currline()
rem           LET da_state=do_grab_variables_from("inspectvariable")
rem           CURRENT WINDOW IS inspectvariable CALL set_current_dialog("inspectvariable")
rem           IF g_inspectvariable_name IS NOT NULL THEN
rem             EXIT INPUT
rem           ELSE
rem             DISPLAY "didn't find a variable on the current line"
rem           END IF
rem         ON ACTION viewlocals
rem           LET action="viewlocals"
rem           EXIT INPUT
rem         ON ACTION viewglobals
rem           LET action="viewglobals"
rem           EXIT INPUT
rem         --ON KEY(Tab)
rem         ON ACTION lookup
rem           --DISPLAY ">>>> KEY TAB !!!"
rem           IF g_inspectvariable_name.getLength()>0 THEN
rem             LET complete_name=complete_variable(g_inspectvariable_name)
rem             IF complete_name.getLength()>0 THEN
rem               LET g_inspectvariable_name=complete_name
rem               EXIT INPUT
rem             ELSE
rem               ERROR "Don't find a variable beginning with \""||g_inspectvariable_name||"\""
rem               LET g_inspectvariable_name=""
rem             END IF
rem           END IF
rem         ON ACTION addwatch
rem           IF length(g_inspectvariable_name) <> 0 THEN
rem             CALL split_vars(g_inspectvariable_name,var_arr)
rem             LET len=var_arr.getLength()
rem             FOR i=1 TO len
rem               CALL add_watch(var_arr[i])
rem             END FOR
rem             LET do_update_watch=1
rem             EXIT INPUT
rem           END IF
rem         ON ACTION delwatch
rem           IF length(g_inspectvariable_name) <> 0 THEN
rem             CALL split_vars(g_inspectvariable_name,var_arr)
rem             LET len=var_arr.getLength()
rem             FOR i=1 TO len
rem               CALL delete_watch(var_arr[i])
rem             END FOR
rem             LET do_update_watch=1
rem             EXIT INPUT
rem           END IF
rem         ON ACTION viewwatchlist
rem           LET da_state=do_view_watches_from("inspectvariable")
rem         --ON ACTION help
rem           --CALL help_dialog(INSPECT_HELP)
rem       END INPUT
rem       --LET prevWin=get_current_dialog()
rem       CALL check_dlg_action(action,"inspectvariable")
rem          RETURNING do_return,da_state
rem       IF do_return THEN
rem         RETURN da_state
rem       END IF
rem     --DISPLAY "g_inspectvariable_name is ",g_inspectvariable_name
rem     END IF
rem     LET update_immediate=0
rem     LET numerrors=0
rem     IF length(g_inspectvariable_name) <> 0 THEN
rem       IF do_update_watch THEN
rem         CALL update_watch()
rem       END IF
rem       CALL split_vars(g_inspectvariable_name,var_arr)
rem       LET result=""
rem       LET len=var_arr.getLength()
rem       FOR i=1 TO len
rem         CALL parse_variable(var_arr[i]) RETURNING success,singleres
rem         IF NOT success THEN
rem           LET numerrors=numerrors+1
rem         END IF
rem         LET result=result.append(singleres)
rem       END FOR
rem       IF numerrors=var_arr.getLength() THEN
rem         LET insert_in_history=0
rem       ELSE
rem         LET insert_in_history=1
rem       END IF
rem       {
rem       IF g_state=ST_INITIAL OR g_state=ST_STOPPED THEN
rem         LET result="Program is not running"
rem       END IF
rem       }
rem       IF insert_in_history THEN
rem         CALL history_insert(inspectvar_hist_arr,g_inspectvariable_name)
rem       END IF
rem       CURRENT WINDOW IS inspectvariable CALL set_current_dialog("inspectvariable")
rem       LET g_inspectvariable_value=result
rem       DISPLAY result TO g_inspectvariable_value
rem     END IF
rem     IF action<>"noaction" THEN
rem        --CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem        RETURN "inspectvariable"
rem     END IF
rem   END WHILE
rem   CLOSE WINDOW inspectvariable CALL remove_dialog_name("inspectvariable")
rem   --DISPLAY "end of inspectvariable ,current dialog is ", get_current_dialog()
rem   --DISPLAY "stack is \"", get_current_window_stack() , "\""
rem   --RETURN "fgldeb"
rem   RETURN get_current_dialog()
rem END FUNCTION
rem 
rem --heavyweight func to figure out the variable
rem FUNCTION parse_variable(varname)
rem   DEFINE varname STRING
rem   DEFINE result,rangevar,stepresult,stepvar,arrayname STRING
rem   DEFINE success,success2,prefix Integer
rem   DEFINE tmp String
rem   DEFINE i,insert_in_history,from,to,step Integer
rem 
rem   CALL parse_range(varname) RETURNING from,to,rangevar,arrayname
rem   LET insert_in_history=0
rem   LET result=""
rem   IF from=-1 OR to=-1 OR from=to THEN
rem     --retrieve the variable value(s)
rem     IF rangevar IS NOT NULL THEN
rem       CALL get_print_variable(rangevar) RETURNING success,result
rem     ELSE
rem       CALL get_print_variable(varname) RETURNING success, result
rem     END IF
rem     IF success THEN
rem       --DISPLAY "deb_arr[1]=",deb_arr[1]
rem       LET result=extract_gdb_variable_value(result)
rem       --DISPLAY "result=",result
rem       LET result=parse_gdb_variable(varname,result)
rem     ELSE
rem       --debugger reported an error
rem       LET prefix=1
rem       IF result.getIndexOf("is not an array",1)<>0 AND
rem           arrayname IS NOT NULL AND from>0 THEN
rem         CALL get_variable_substring(arrayname,result,from,to)
rem           RETURNING success2,result
rem         IF success2 THEN
rem           LET prefix=0
rem         END IF
rem       END IF
rem     END IF
rem   ELSE
rem     IF to<from THEN
rem       LET step=-1
rem     ELSE
rem       LET step= 1
rem     END IF
rem     FOR i=from TO to STEP step
rem       LET stepvar=sfmt(rangevar,i)
rem       CALL get_print_variable(stepvar) RETURNING success, stepresult
rem       IF NOT success THEN
rem         LET prefix=1
rem         IF stepresult.getIndexOf("is not an array",1)<>0 AND
rem           arrayname IS NOT NULL AND from>0 THEN
rem           CALL get_variable_substring(arrayname,stepresult,from,to) RETURNING
rem               success2,result
rem           IF success2 THEN
rem             LET success=success2
rem             LET prefix=0
rem           END IF
rem         ELSE
rem           LET result=stepresult
rem         END IF
rem         EXIT FOR
rem       ELSE
rem         LET stepresult=extract_gdb_variable_value(stepresult)
rem         --DISPLAY "result=",stepresult
rem         LET stepresult=parse_gdb_variable(stepvar,stepresult)
rem       END IF
rem       LET result=result.append(stepresult)
rem     END FOR
rem   END IF
rem   IF prefix THEN
rem     LET tmp=result
rem     LET result=sfmt("%1 :%2",varname,tmp)
rem   END IF
rem   RETURN success,result
rem END FUNCTION
rem 
rem --splits a string separated by semicolon or white space into
rem --the given array
rem FUNCTION split_vars(str,var_arr)
rem   DEFINE str STRING
rem   DEFINE var_arr DYNAMIC ARRAY OF STRING
rem   DEFINE var_count,i,len,check_newvar INTEGER
rem   DEFINE singlevar,state,c STRING
rem   CALL var_arr.clear()
rem   LET var_count=1
rem   LET singlevar=""
rem   LET state="startvar"
rem   LET len=str.getLength()
rem   FOR i=1 TO len
rem     LET c=str.getCharAt(i)
rem     LET check_newvar=0
rem     CASE c
rem       WHEN " "
rem         LET check_newvar=1
rem       WHEN ";"
rem         LET check_newvar=1
rem       OTHERWISE
rem         LET singlevar=singlevar.append(c)
rem         LET state="invar"
rem     END CASE
rem     IF check_newvar AND state="invar" AND singlevar.getLength()>0 THEN
rem         LET var_arr[var_count]=singlevar
rem         LET var_count=var_count+1
rem         LET singlevar=""
rem         LET state="startvar"
rem     END IF
rem   END FOR
rem   IF state="invar" AND singlevar.getLength()>0 THEN
rem       LET var_arr[var_count]=singlevar
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION windowExist(name)
rem   DEFINE name String
rem   DEFINE rootNode,ch om.DomNode
rem   LET rootNode=ui.Interface.getRootNode()
rem   LET ch= rootNode.getFirstChild()
rem   WHILE ch IS NOT NULL
rem     IF ch.getTagName()="Window" AND ch.getAttribute("name")=name THEN
rem       RETURN 1
rem     END IF
rem     LET ch=ch.getNext()
rem   END WHILE
rem   RETURN 0
rem END FUNCTION
rem 
rem 
rem --case insensitive version of string.getIndexOf
rem FUNCTION getIndexOfI(src,pattern,idx)
rem   DEFINE src,pattern STRING
rem   DEFINE idx INTEGER
rem   LET src=src.toLowerCase()
rem   LET pattern=pattern.toLowerCase()
rem   RETURN src.getIndexOf(pattern,idx)
rem END FUNCTION
rem 
rem --adds a variable found on a source code line to the
rem --given array of variable names by removing spaces in
rem --the variable name and testing for duplicates
rem FUNCTION append_autodetect_var(var_arr,varname)
rem   DEFINE var_arr DYNAMIC ARRAY OF STRING
rem   DEFINE varname STRING
rem   DEFINE found INTEGER
rem   LET varname=remove_spaces(varname)
rem   LET found=find_var_name(varname,var_arr,var_arr.getLength())
rem   --comment these lines if you are interested in
rem   --autodetecting variables with the same same like
rem   --keywords
rem   IF g_state<>ST_RUNNING THEN
rem     IF found=0 THEN
rem       IF isCommon_keyword(varname) THEN
rem         LET found=1
rem       END IF
rem     END IF
rem   END IF
rem   IF found=0 THEN
rem     LET var_arr[var_arr.getLength()+1]=varname
rem   END IF
rem END FUNCTION
rem 
rem --this bloody function tries to find ALL variables on a source line
rem --it splits the line into identifiers,
rem --feeds them in "print" statements to the debugger and looks if the
rem --identifiers were actually variables ...
rem --the result is left in input_arr
rem FUNCTION grab_variables(input_arr)
rem   DEFINE input_arr DYNAMIC ARRAY OF STRING
rem   DEFINE line,c String
rem   DEFINE var_arr DYNAMIC ARRAY OF String
rem   DEFINE startbrackets DYNAMIC ARRAY OF INTEGER
rem   DEFINE varname,insidevar,quote_value,nextchars,result STRING
rem   DEFINE i,bracketcount,len,bs_state,quote_state,var_append INTEGER
rem   DEFINE startidx,dot_seen,success INTEGER
rem   LET len=input_arr.getLength()
rem   FOR i=1 TO len
rem     LET var_arr[i]=input_arr[i]
rem   END FOR
rem   CALL input_arr.clear()
rem   LET line=src_arr[g_line].line
rem   --it uses btw the same kind of statemachine like in parse_gdb_variable
rem   LET len=line.getLength()
rem   FOR i=1 TO len
rem     LET c=line.getCharAt(i)
rem     IF bs_state THEN
rem       IF quote_state THEN
rem         LET quote_value=quote_value.append(c)
rem       ELSE
rem         --DISPLAY c," sign after backslash misplaced"
rem       END IF
rem       LET bs_state=0
rem       CONTINUE FOR
rem     END IF
rem     LET var_append=0
rem     CASE c
rem       WHEN "\""
rem         IF NOT quote_state THEN
rem           LET quote_state = 1
rem           LET quote_value=""
rem           LET var_append=1
rem         ELSE
rem           LET quote_state=0
rem           --DISPLAY "quoted string was: \"",quote_value,"\""
rem         END IF
rem       WHEN "\\"
rem         IF quote_state THEN
rem           IF NOT bs_state THEN
rem             LET bs_state = 1
rem           ELSE
rem             LET bs_state = 0
rem           END IF
rem           LET quote_value=quote_value.append("\\")
rem         ELSE
rem           LET var_append=1
rem         END IF
rem       WHEN "-"
rem         IF g_isgdb AND i+1<=len THEN
rem           IF line.getCharAt(i+1)=">" THEN
rem             LET i=i+1
rem             CONTINUE FOR
rem           END IF
rem         END IF
rem         LET var_append=1
rem       WHEN "."
rem         IF quote_state THEN
rem           LET quote_value=quote_value.append(c)
rem         ELSE
rem           IF i+1<=len AND line.getCharAt(i+1)=="*" THEN
rem               LET i=i+1
rem           ELSE
rem             LET dot_seen=1
rem             LET varname=varname.append(c)
rem           END IF
rem         END IF
rem       WHEN "\t"
rem         GOTO :space
rem       WHEN " "
rem         LABEL space:
rem         IF quote_state THEN
rem           LET quote_value=quote_value.append(c)
rem         ELSE
rem           LET nextChars=line.subString(i+1,line.getLength())
rem           LET nextChars=remove_leading_spaces(nextChars)
rem           IF bracketcount>0 OR dot_seen OR
rem               (bracketcount=0 AND
rem                 (nextChars.getIndexOf("[",1)=1 ) OR
rem                 (nextChars.getIndexOf(".",1)=1 ) OR
rem                 (g_isgdb AND nextChars.getIndexOf("->",1)=1)) THEN
rem             {
rem             WHILE i+1 <= len
rem               IF isWhiteSpaceChar(line.getCharAt(i+1)) THEN
rem                 LET i=i+1
rem                 IF varname.getLength()>0 THEN
rem                   LET varname=varname.append(c)
rem                 END IF
rem                 IF bracketcount>0 THEN
rem                   LET startbrackets[bracketcount]=
rem                       startbrackets[bracketcount]-1
rem                 END IF
rem               ELSE
rem                 EXIT WHILE
rem               END IF
rem             END WHILE
rem             }
rem             CONTINUE FOR
rem           ELSE
rem             LET var_append=1
rem           END IF
rem         END IF
rem       WHEN "["
rem         IF quote_state THEN
rem           LET quote_value=quote_value.append(c)
rem         ELSE
rem           LET bracketcount=bracketcount+1
rem 
rem           --IF dot_seen AND varname.getLength()>0 THEN
rem           --DISPLAY "varname is \"",varname,"\",startidx=",startidx
rem           -- LET startbrackets[bracketcount]=i-varname.getLength()
rem           --ELSE
rem           LET startbrackets[bracketcount]=startidx
rem           --END IF
rem           LET dot_seen=0
rem           LET varname=""
rem         END IF
rem       WHEN "]"
rem         IF quote_state THEN
rem           LET quote_value=quote_value.append(c)
rem         ELSE
rem           LET dot_seen=0
rem           IF bracketcount>0 and bracketcount<=startbrackets.getLength() THEN
rem             IF isVarName(varname) THEN
rem               CALL append_autodetect_var(var_arr,varname)
rem             END IF
rem             LET insidevar=line.subString(startbrackets[bracketcount],i)
rem             IF isVarName(insidevar) THEN
rem               --DISPLAY "insidevar IS ",insidevar
rem               IF bracketcount=1 AND i+1<=len THEN
rem                 --do nothing
rem                 LET varname=insidevar
rem                 LET startidx=startbrackets[bracketcount]
rem               ELSE
rem                 CALL append_autodetect_var(var_arr,insidevar)
rem               END IF
rem             END IF
rem           END IF
rem           IF bracketcount>0 THEN
rem             CALL startbrackets.deleteElement(bracketcount)
rem             LET bracketcount=bracketcount-1
rem           END IF
rem         END IF
rem       WHEN "("
rem         --function call
rem         IF quote_state THEN
rem           LET quote_value=quote_value.append(c)
rem         ELSE
rem           IF g_state<>ST_RUNNING THEN
rem             LET varname=""
rem             LET dot_seen=0
rem           ELSE
rem             LET var_append=1
rem           END IF
rem         END IF
rem       WHEN "{" LET var_append=1
rem       WHEN "}" LET var_append=1
rem       WHEN "/" LET var_append=1
rem       WHEN "*" LET var_append=1
rem       WHEN "<" LET var_append=1
rem       WHEN ">" LET var_append=1
rem       WHEN "=" LET var_append=1
rem       WHEN "+" LET var_append=1
rem       WHEN ")" LET var_append=1
rem       WHEN ";" LET var_append=1
rem       WHEN "," LET var_append=1
rem       OTHERWISE
rem         IF quote_state THEN
rem           LET quote_value=quote_value.append(c)
rem         ELSE
rem           LET dot_seen=0
rem           LET varname=varname.append(c)
rem           IF varname.getLength()=1 THEN
rem             LET startidx=i
rem           END IF
rem         END IF
rem     END CASE
rem     IF var_append THEN
rem       IF quote_state THEN
rem         LET quote_value=quote_value.append(c)
rem       ELSE
rem         LET dot_seen=0
rem         IF isVarName(varname) THEN
rem           CALL append_autodetect_var(var_arr,varname)
rem         END IF
rem         LET varname=""
rem       END IF
rem     END IF
rem     --DISPLAY "i:",i," c:",c," varname:",varname
rem   END FOR
rem   IF isVarName(varname) THEN
rem     CALL append_autodetect_var(var_arr,varname)
rem   END IF
rem   LET len=var_arr.getLength()
rem   IF g_state=ST_RUNNING THEN
rem     FOR i=1 TO len
rem       CALL get_print_variable(var_arr[i]) RETURNING success,result
rem       IF success THEN
rem         LET input_arr[input_arr.getLength()+1]=var_arr[i]
rem       END IF
rem     END FOR
rem   ELSE
rem     FOR i=1 TO len
rem       LET input_arr[input_arr.getLength()+1]=var_arr[i]
rem     END FOR
rem   END IF
rem   LET len=input_arr.getLength()
rem   --FOR i=1 TO len
rem   -- DISPLAY "var [",i,"]=",input_arr[i]
rem   --END FOR
rem END FUNCTION
rem 
rem FUNCTION tryfindvar_on_currline()
rem   RETURN 0
rem END FUNCTION
rem 
rem --this even more bloody function extracts the record information
rem --from gdb formatted print statements
rem FUNCTION parse_gdb_variable(variable,line)
rem   DEFINE variable,line String
rem   DEFINE c CHAR
rem   DEFINE levelstart DYNAMIC ARRAY OF INTEGER
rem   DEFINE countarr DYNAMIC ARRAY OF INTEGER
rem   DEFINE levelhasvarname DYNAMIC ARRAY OF INTEGER
rem   DEFINE varnames DYNAMIC ARRAY OF STRING
rem   DEFINE level,i Integer
rem   DEFINE maxlevel Integer
rem   DEFINE levelstr,varname,value String
rem   DEFINE bs_state ,quote_state,len Integer
rem   DEFINE res,result String
rem 
rem   --LET level=1
rem   --LET count_arr[level]=0
rem   LET len=line.getLength()
rem   FOR i=1 TO len
rem    LET c=line.getCharAt(i)
rem    IF bs_state THEN
rem      IF quote_state THEN
rem        LET value=value.append(c)
rem      ELSE
rem        DISPLAY c," sign after backslash misplaced"
rem      END IF
rem      LET bs_state=0
rem      CONTINUE FOR
rem    END IF
rem    CASE c
rem      WHEN "{"
rem        IF quote_state THEN
rem          LET value=value.append(c)
rem        ELSE
rem          IF varname IS NOT NULL THEN
rem            LET levelhasvarname[level]=1
rem          END IF
rem          LET level=level+1
rem          IF level>maxlevel THEN
rem            LET maxlevel=1
rem          END IF
rem          LET levelstart[level]=i
rem          LET countarr[level]=0
rem          LET levelhasvarname[level]=0
rem        END IF
rem      WHEN "}"
rem        IF quote_state THEN
rem          LET value=value.append(c)
rem        ELSE
rem          LET levelstr=line.subString(levelstart[level],i)
rem          --DISPLAY "string for level ",level," is \"",levelstr,"\""
rem          IF varname IS NOT NULL THEN
rem            LET levelhasvarname[level]=1
rem            --DISPLAY "\} recognized varname+value :",varname,"=",value
rem          ELSE
rem            --DISPLAY "\} recognized only value :",value
rem          END IF
rem          IF level=1 AND varname IS NULL AND value IS NOT NULL THEN
rem            LET res=sfmt("%1[%2] = %3\n",variable,countarr[level]+1,value)
rem            LET result=result.append(res)
rem          ELSE IF level=1 AND varname IS NOT NULL AND value IS NOT NULL THEN
rem            LET res=sfmt("%1.%2 = %3\n",variable,varname,value)
rem            LET result=result.append(res)
rem          ELSE IF level=2 THEN
rem            IF levelhasvarname[level-1]=0 THEN
rem              LET res=sfmt("%1[%2] = %3\n",variable,countarr[level-1]+1,levelstr)
rem              LET result=result.append(res)
rem            ELSE
rem              LET res=sfmt("%1.%2 = %3\n",variable,varnames[level-1],levelstr)
rem              LET result=result.append(res)
rem            END IF
rem          END IF
rem          END IF
rem          END IF
rem          LET countarr[level]=countarr[level]+1
rem          LET level=level-1
rem          LET varname=""
rem          LET value=""
rem        END IF
rem      WHEN "\""
rem        IF NOT quote_state THEN
rem          LET quote_state = 1
rem        ELSE
rem          LET quote_state=0
rem        END IF
rem        LET value=value.append(c)
rem      WHEN "\\"
rem        IF quote_state THEN
rem          IF NOT bs_state THEN
rem            LET bs_state = 1
rem          ELSE
rem            LET bs_state = 0
rem          END IF
rem          LET value=value.append("\\")
rem        ELSE
rem          DISPLAY "illegal backslash"
rem        END IF
rem      WHEN "="
rem        IF quote_state THEN
rem          LET value=value.append(c)
rem        ELSE
rem          LET varname=value
rem          LET value=""
rem          LET i=i+1
rem          LET varnames[level]=varname
rem          --LET levelhasnames[level]=1
rem        END IF
rem      WHEN " "
rem        IF quote_state THEN
rem          LET value=value.append(c)
rem        END IF
rem      WHEN "\t"
rem        IF quote_state THEN
rem          LET value=value.append(c)
rem        END IF
rem      WHEN ","
rem        IF quote_state THEN
rem          LET value=value.append(c)
rem        ELSE
rem          IF varname IS NOT NULL THEN
rem            --DISPLAY "recognized varname+value :",varname,"=",value
rem          ELSE
rem            --DISPLAY "recognized only value :",value
rem          END IF
rem          --CALL printlevelresult(variable,level,varname,countarr[level])
rem          IF level=1 AND varname IS NULL AND value IS NOT NULL THEN
rem            LET res=sfmt("%1[%2] = %3\n",variable,countarr[level]+1,value)
rem            LET result=result.append(res)
rem          ELSE IF level=1 AND varname IS NOT NULL AND value IS NOT NULL THEN
rem            LET res=sfmt("%1.%2 = %3\n",variable,varname,value)
rem            LET result=result.append(res)
rem          END IF
rem          END IF
rem          LET varname=""
rem          LET value=""
rem          IF level<1 OR level>countarr.getLength() THEN
rem            --something went wrong here
rem            RETURN ""
rem          END IF
rem          LET countarr[level]=countarr[level]+1
rem        END IF
rem      OTHERWISE
rem        LET value=value.append(c)
rem    END CASE
rem    --DISPLAY "i:",i," c:",c," bs:",bs_state," quote:",quote_state," value:",value
rem   END FOR
rem   IF maxlevel=0 OR line="{}" THEN
rem     LET res=sfmt("%1 = %2\n",variable,line)
rem     LET result=result.append(res)
rem   END IF
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION extract_gdb_variable_value(line)
rem   DEFINE line,line2 String
rem   DEFINE eqidx Integer
rem   LET eqidx = line.getIndexOf("=",1)
rem   --DISPLAY "extract_gdc_variable_value:eqidx:",eqidx,",len:",line.getLength()
rem   IF eqidx = 0 THEN
rem     RETURN line
rem   END IF
rem   LET line2= line.subString(eqidx+2,line.getLength())
rem   --DISPLAY "line2=",line2
rem   RETURN line2
rem END FUNCTION
rem 
rem FUNCTION get_state_filename(program)
rem   DEFINE program STRING
rem   DEFINE fname STRING
rem   LET fname=get_short_filename(program)
rem   IF fname.getIndexOf(".42",1)>0 THEN
rem     LET fname=fname.subString(1,fname.getIndexOf(".42",1)-1)
rem   END IF
rem   LET fname=fname.append(".fgldeb")
rem   RETURN fname
rem END FUNCTION
rem 
rem 
rem FUNCTION save_state ()
rem   DEFINE cfile,currentwin String
rem   DEFINE doc om.DomDocument
rem   DEFINE root,breakpoints,b,histlists,h,hentry,windows,w om.DomNode
rem   DEFINE i,len INTEGER
rem   LET cfile=get_state_filename(g_program)
rem   IF cfile IS NULL THEN
rem     ERROR "can't get config file name"
rem     RETURN
rem   END IF
rem   LET currentwin = om_get_current_window_name()
rem   CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem   LET doc=om.DomDocument.create("FglDebugger")
rem   LET root=doc.getDocumentElement()
rem   LET breakpoints=root.createChild("Breakpoints")
rem   LET len=break_arr.getLength()
rem   FOR i=1 TO len
rem     LET b=breakpoints.createChild("Breakpoint")
rem     CALL b.setAttribute("lineNumber",break_arr[i].lineNumber)
rem     CALL b.setAttribute("funcName" ,break_arr[i].funcName )
rem     CALL b.setAttribute("modName" ,break_arr[i].modName )
rem     CALL b.setAttribute("breakType" ,break_arr[i].breakType )
rem     CALL b.setAttribute("enabled" ,break_arr[i].enabled )
rem     CALL b.setAttribute("isFunction",break_arr[i].isFunction)
rem     IF break_arr[i].line IS NOT NULL THEN
rem       CALL b.setAttribute("line" ,break_arr[i].line )
rem     END IF
rem   END FOR
rem   --save all histories 
rem   LET histlists=root.createChild("HistoryLists")
rem 
rem   LET h=histlists.createChild("search") 
rem   LET len= search_hist_arr.getLength() 
rem   FOR i=1 TO len 
rem     LET hentry=h.createChild("Item") 
rem     IF search_hist_arr[i].getLength() <> 0 THEN 
rem       CALL hentry.setAttribute("value",search_hist_arr[i]) 
rem     END IF 
rem   END FOR
rem 
rem   LET h=histlists.createChild("inspectvariable") 
rem   LET len= inspectvar_hist_arr.getLength() 
rem   FOR i=1 TO len 
rem     LET hentry=h.createChild("Item") 
rem     IF inspectvar_hist_arr[i].getLength() <> 0 
rem       THEN CALL hentry.setAttribute("value",inspectvar_hist_arr[i]) 
rem     END IF 
rem   END FOR
rem 
rem   LET h=histlists.createChild("fdbcommand") 
rem   LET len= fdb_hist_arr.getLength() 
rem   FOR i=1 TO len 
rem     LET hentry=h.createChild("Item") 
rem     IF fdb_hist_arr[i].getLength() <> 0 THEN 
rem       CALL hentry.setAttribute("value",fdb_hist_arr[i]) 
rem     END IF
rem   END FOR
rem 
rem   LET h=histlists.createChild("functions") 
rem   LET len= func_hist_arr.getLength() 
rem   FOR i=1 TO len 
rem     LET hentry=h.createChild("Item") 
rem     IF func_hist_arr[i].getLength() <> 0 THEN 
rem       CALL hentry.setAttribute("value",func_hist_arr[i]) 
rem     END IF 
rem   END FOR
rem 
rem   LET h=histlists.createChild("watches") 
rem   LET len= watch_arr.getLength() 
rem   FOR i=1 TO len 
rem     LET hentry=h.createChild("Item") 
rem     IF watch_arr[i].getLength() <> 0 THEN 
rem       CALL hentry.setAttribute("value",watch_arr[i]) 
rem     END IF 
rem   END FOR
rem 
rem   LET windows=root.createChild("Windows")
rem   LET w=windows.createChild("auto_group")
rem   CALL w.setAttribute("hidden",_deb_getGroupHidden("auto_group"))
rem   LET w=windows.createChild("watch_group")
rem   CALL w.setAttribute("hidden",_deb_getGroupHidden("watch_group"))
rem   WHENEVER ERROR CONTINUE
rem   CALL root.writeXml(cfile)
rem   DISPLAY "status:",status
rem   WHENEVER ERROR STOP
rem   CALL raise_window(currentwin)
rem END FUNCTION
rem 
rem FUNCTION get_state_fileroot()
rem   DEFINE cfile String
rem   DEFINE doc om.DomDocument
rem   DEFINE root om.DomNode
rem   LET cfile=get_state_filename(g_program)
rem   IF cfile IS NULL THEN
rem     ERROR "can't get config file name"
rem     RETURN NULL
rem   END IF
rem   LET doc=om.DomDocument.createFromXmlFile(cfile)
rem   IF doc IS NULL THEN
rem     MESSAGE "can't file config file"
rem     RETURN NULL
rem   END IF
rem   LET root=doc.getDocumentElement()
rem   RETURN root
rem END FUNCTION
rem 
rem FUNCTION restore_state()
rem   DEFINE nlist om.NodeList
rem   DEFINE root,history_list,windows om.DomNode
rem   LET root=get_state_fileroot()
rem   IF root IS NULL THEN
rem     RETURN
rem   END IF
rem   IF g_restore_breakpoints THEN
rem     CALL restore_breakpoints_fromstatefile(root)
rem   END IF
rem   -- now read in the history nodes
rem   LET nlist=root.selectByPath("//HistoryLists")
rem   IF nlist.getLength()=1 THEN
rem     LET history_list=nlist.item(1)
rem     CALL restore_history(history_list,search_hist_arr ,"search" )
rem     CALL restore_history(history_list,fdb_hist_arr ,"fdbcommand")
rem     CALL restore_history(history_list,inspectvar_hist_arr,"inspectvariable")
rem     CALL restore_history(history_list,func_hist_arr ,"functions")
rem     CALL restore_history(history_list,watch_arr ,"watches")
rem   END IF
rem   LET nlist=root.selectByPath("//Windows")
rem   IF nlist.getLength()=1 THEN
rem     LET windows=nlist.item(1)
rem     CALL restore_windows(windows)
rem   END IF
rem END FUNCTION
rem 
rem --stand alone function to restore exclusively the breakpoints
rem --in the middle of the program
rem FUNCTION restore_breakpoints()
rem   DEFINE root om.DomNode
rem   LET root=get_state_fileroot()
rem   IF root IS NOT NULL THEN
rem     CALL restore_breakpoints_fromstatefile(root)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION restore_breakpoints_fromstatefile(root)
rem   DEFINE root,breakpoints om.DomNode
rem   DEFINE nlist om.NodeList
rem   -- read in the breakpoints
rem   LET nlist=root.selectByPath("//Breakpoints")
rem   IF nlist.getLength()=1 THEN
rem     LET breakpoints=nlist.item(1)
rem     CALL restore_breakpoints_fromnl(breakpoints)
rem     MESSAGE "restored breakpoints"
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION restore_breakpoints_fromnl(breakpoints)
rem   DEFINE breakpoints,b om.DomNode
rem   DEFINE i INTEGER
rem   DEFINE modName,funcName,line,breakcmd,breakType,file,lineStr STRING
rem   DEFINE addlinebreak,lineNumber,enabled,isFunction INTEGER
rem   DEFINE bsrc_arr DYNAMIC ARRAY OF STRING
rem   LET g_lastmod=" "
rem   FOR i=1 TO breakpoints.getChildCount()
rem     LET b=breakpoints.getChildByIndex(i)
rem     LET modName = b.getAttribute("modName")
rem     LET funcName = b.getAttribute("funcName")
rem     LET enabled = b.getAttribute("enabled")
rem     LET lineNumber = b.getAttribute("lineNumber")
rem     LET line = b.getAttribute("line")
rem     LET breakType = b.getAttribute("breakType")
rem     LET isFunction = b.getAttribute("isFunction")
rem     LET breakcmd=""
rem     DISPLAY "i:",i,",modName:",modName,",lineNumber:",lineNumber,",line:",line
rem     --we ignore temporary breakpoints
rem     IF breakType="del" THEN
rem       CONTINUE FOR
rem     END IF
rem     IF line IS NOT NULL THEN
rem       --lookup in the source file, if the corresponding line
rem       --is at the right place
rem       IF g_lastmod <> modName THEN
rem         CALL read_in_source(modName,bsrc_arr,0)
rem         IF g_read_in_source_error THEN
rem           --ignore this breakpoint
rem           CONTINUE FOR
rem         END IF
rem         LET g_lastmod=modName
rem       END IF
rem       CALL find_line_in_srcarr(line,lineNumber,funcName,bsrc_arr)
rem           RETURNING addlinebreak,lineNumber
rem       IF addlinebreak THEN
rem         LET breakcmd=sfmt("break %1:%2",modName,lineNumber)
rem       END IF
rem     ELSE IF isFunction THEN
rem       CALL get_function_info_short(funcName,0) RETURNING file,lineStr
rem       IF file IS NOT NULL THEN
rem         LET lineNumber=lineStr
rem         LET breakcmd=sfmt("break %1:%2",file,lineStr)
rem       END IF
rem     ELSE
rem       LET breakcmd=sfmt("break %1:%2",modName,lineNumber)
rem     END IF
rem     END IF
rem     DISPLAY "breakcmd:",breakcmd
rem     IF breakcmd IS NOT NULL THEN
rem       CALL deb_write(breakcmd)
rem       CALL get_deb_out()
rem       IF line IS NOT NULL THEN
rem         CALL check_break_line(lineNumber,0,modName,bsrc_arr)
rem       END IF
rem     END IF
rem   END FOR
rem   CALL update_breakpoints()
rem 
rem END FUNCTION
rem 
rem FUNCTION restore_history(history_list,arr,name)
rem   DEFINE history_list om.DomNode
rem   DEFINE arr DYNAMIC ARRAY OF STRING
rem   DEFINE name,value STRING
rem   DEFINE nlist om.NodeList
rem   DEFINE histnode,child om.DomNode
rem   DEFINE i INTEGER
rem   LET nlist=history_list.selectByPath("//"||name)
rem   IF nlist.getLength()=1 THEN
rem     LET histnode=nlist.item(1)
rem     CALL arr.clear()
rem     LET i=1
rem     LET child= histnode.getFirstChild()
rem     WHILE child IS NOT NULL
rem       IF child.getTagName()="Item" THEN
rem         LET value=child.getAttribute("value")
rem         IF value.getLength()<> 0 THEN
rem           LET arr[i]=value
rem           LET i=i+1
rem         END IF
rem       END IF
rem       LET child=child.getNext()
rem     END WHILE
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION restore_windows(windows)
rem   DEFINE windows,w om.DomNode
rem   DEFINE i INTEGER
rem   DEFINE tagName,hidden STRING
rem   FOR i=1 TO windows.getChildCount()
rem     LET w=windows.getChildByIndex(i)
rem     LET tagName=w.getTagName()
rem     LET hidden=w.getAttribute("hidden")
rem     --DISPLAY "tagName:",tagName,",hidden",hidden
rem     CASE tagName
rem       WHEN "auto_group"
rem         CALL do_hide_group_int("auto_group","togglehideauto","&Auto",hidden)
rem       WHEN "watch_group"
rem         CALL do_hide_group_int("watch_group","togglehidewatch","&Watch",hidden)
rem     END CASE
rem   END FOR
rem END FUNCTION
rem 
rem FUNCTION remove_leading_spaces(line)
rem   DEFINE line,c STRING
rem   DEFINE i,len INTEGER
rem   LET len=line.getLength()
rem   FOR i=1 TO len
rem     LET c=line.getCharAt(i)
rem     IF c=" " OR c="\t" THEN
rem       CONTINUE FOR
rem     ELSE
rem       LET line=line.subString(i,line.getLength())
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   RETURN line
rem END FUNCTION
rem 
rem FUNCTION remove_spaces(line)
rem   DEFINE line STRING
rem   DEFINE line2,c STRING
rem   DEFINE i,len INTEGER
rem   LET len=line.getLength()
rem   FOR i=1 TO len
rem     LET c=line.getCharAt(i)
rem     IF c=" " OR c="\t" THEN
rem       CONTINUE FOR
rem     ELSE
rem       LET line2=line2.append(c)
rem     END IF
rem   END FOR
rem   RETURN line2
rem END FUNCTION
rem 
rem --this function checks for
rem --"FUNCTION foo (" , "MAIN" on a line or
rem --"END FUNCTION", "END MAIN"
rem --if it finds the definition,
rem --it returns : "function",<funcName> ,
rem --in the end case : "end" ,"function"
rem --if not find at all : "" ,""
rem FUNCTION check_function_line(line)
rem   DEFINE line STRING
rem   DEFINE i,len INTEGER
rem   DEFINE ident,c STRING
rem   LET line=remove_leading_spaces(line)
rem   LET line=line.toLowerCase()
rem   IF line.getIndexOf("end",1)=1 THEN
rem     LET line=line.subString(length("end")+1,line.getLength())
rem     LET line=remove_leading_spaces(line)
rem     IF line.getIndexOf("function",1)=1 OR line.getIndexOf("main",1)=1 THEN
rem       RETURN "end","function"
rem     END IF
rem   ELSE IF line.getIndexOf("function",1)=1 THEN
rem     LET line=line.subString(length("function")+1,line.getLength())
rem     LET line=remove_leading_spaces(line)
rem     LEt len=line.getLength()
rem     FOR i=1 TO len
rem       LET c=line.getCharAt(i)
rem       IF c=" " OR c="\t" OR c="(" THEN
rem         EXIT FOR
rem       ELSE
rem         LET ident=ident.append(c)
rem       END IF
rem     END FOR
rem     RETURN "function",ident
rem   ELSE IF line.getIndexOf("main",1)=1 THEN
rem     RETURN "function","main"
rem   END IF
rem   END IF
rem   END IF
rem   RETURN "",""
rem END FUNCTION
rem 
rem --tries to locate a source code line in an array read from a source
rem FUNCTION find_line_in_srcarr(line,lineNumber,funcName,arr)
rem   DEFINE line STRING
rem   DEFINE lineNumber INTEGER
rem   DEFINE funcName STRING
rem   DEFINE arr DYNAMIC ARRAY OF STRING
rem   DEFINE i,found,len INTEGER
rem   DEFINE srcline,kind,func STRING
rem 
rem   --normalize the search line and remove trailing blanks
rem   --DISPLAY "find source line \"",line,"\" in func ",funcName," ,lineno ",lineNumber
rem   LET funcName=funcName.toLowercase()
rem   LET line=remove_leading_spaces(line)
rem   --search forward
rem   LET len=arr.getLength()
rem   FOR i=lineNumber TO len
rem     LET srcline=arr[i]
rem     --DISPLAY sfmt("line%1:%2",i,srcline)
rem     IF srcline.getIndexOf(line,1)<> 0 THEN
rem       --DISPLAY "found at ",i
rem       RETURN 1,i
rem     END IF
rem     CALL check_function_line(srcline) RETURNING kind,func
rem     IF kind IS NULL THEN
rem       -- no function stuff detected
rem       CONTINUE FOR
rem     END IF
rem     IF kind="end" THEN
rem       --DISPLAY "end function found at ",i
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   IF lineNumber-1>arr.getLength() THEN
rem     LET lineNumber=arr.getLength()+1
rem   END IF
rem   FOR i=lineNumber-1 TO 1 STEP -1
rem     LET srcline=arr[i]
rem     --DISPLAY sfmt("line%1:%2",i,srcline)
rem     IF srcline.getIndexOf(line,1)<> 0 THEN
rem       --DISPLAY "found at ",i
rem       RETURN 1,i
rem     END IF
rem     CALL check_function_line(srcline) RETURNING kind,func
rem     IF kind IS NULL THEN
rem       -- no function stuff detected
rem       CONTINUE FOR
rem     END IF
rem     IF kind="function" THEN
rem       --DISPLAY "function start found at ",i
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   --finally, search the whole document, look for the right
rem   --function and try to find the line within there
rem   FOR i=1 TO len
rem     LET srcline=arr[i]
rem     CALL check_function_line(srcline) RETURNING kind,func
rem     CASE kind
rem       WHEN "function"
rem         IF func=funcName THEN
rem           --DISPLAY "found function start of ",funcName," at ",i
rem           LET found=1
rem         END IF
rem       WHEN "end"
rem         IF found THEN
rem           --DISPLAY "found function end,go out"
rem           EXIT FOR
rem         END IF
rem       OTHERWISE
rem         IF found AND srcline.getIndexOf(line,1)<> 0 THEN
rem           --DISPLAY "finally found the line at ",i
rem           RETURN 1,i
rem         END IF
rem     END CASE
rem   END FOR
rem   RETURN 0,1
rem END FUNCTION
rem 
rem FUNCTION set_debug_logo()
rem   DEFINE root om.DomNode
rem   LET root = ui.Interface.getRootNode()
rem   CALL root.setAttribute("image","debug_logo")
rem END FUNCTION
rem 
rem --adds a variable to the global watch array
rem --the watch array is inspected/printed after each step instruction
rem FUNCTION add_watch(varname)
rem   DEFINE varname STRING
rem   DEFINE i,found,len INTEGER
rem   LET len=watch_arr.getLength()
rem   FOR i=1 TO len
rem     IF watch_arr[i]=varname THEN
rem       LET found=1
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   IF NOT found THEN
rem     LET watch_arr[watch_arr.getLength()+1]=varname
rem   END IF
rem END FUNCTION
rem 
rem --deletes a variable from the watch array
rem FUNCTION delete_watch(varname)
rem   DEFINE varname STRING
rem   DEFINE i,len INTEGER
rem   LET len=watch_arr.getLength()
rem   FOR i=1 TO len
rem     IF watch_arr[i].getIndexOf(varname,1)=1 THEN
rem       CALL watch_arr.deleteElement(i)
rem       EXIT FOR
rem     END IF
rem   END FOR
rem END FUNCTION
rem 
rem --goes through the list of variables, gets their values and
rem --gives back a single result string
rem FUNCTION format_var_arr_print(var_arr,limit_one_line)
rem   DEFINE var_arr DYNAMIC ARRAY OF STRING
rem   DEFINE limit_one_line INTEGER
rem   DEFINE result,singleres,tmp STRING
rem   DEFINE i,success,len,firstnl INTEGER
rem   DEFINE sb base.StringBuffer
rem   LET sb=base.StringBuffer.create()
rem   LET len=var_arr.getLength()
rem   FOR i=1 TO len
rem     CALL parse_variable(var_arr[i]) RETURNING success,singleres
rem     IF limit_one_line THEN
rem       --replace \n by space
rem       IF singleres.getCharAt(singleres.getLength())=="\n" THEN
rem         LET singleres=singleres.subString(1,singleres.getLength()-1)
rem       END IF
rem       CALL sb.clear()
rem       CALL sb.append(singleres)
rem       CALL sb.replace("\n"," ",0)
rem       LET singleres=sb.toString()
rem     END IF
rem     LET result=result.append(singleres)
rem     IF result.getLength()>0 THEN
rem       IF result.getCharAt(result.getLength()) <> "\n" THEN
rem         LET result=result.append("\n")
rem       END IF
rem     END IF
rem   END FOR
rem   RETURN result
rem END FUNCTION
rem 
rem --goes through the list of watched variables and
rem --gets the current values from the debugger
rem FUNCTION update_watch()
rem   DEFINE result,currentwin STRING
rem   DEFINE hidden INTEGER
rem   IF NOT windowExist("fgldeb") THEN
rem     RETURN
rem   END IF
rem   --save the current window
rem   LET currentwin = om_get_current_window_name()
rem   CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem   LET hidden=_deb_getGroupHidden("watch_group")
rem   IF hidden=0 THEN
rem     LET result=format_var_arr_print(watch_arr,0)
rem     DISPLAY result to g_watch
rem   END IF
rem   CALL raise_window(currentwin)
rem END FUNCTION
rem 
rem FUNCTION update_autovars()
rem   DEFINE currentwin,result,frame_name STRING
rem   DEFINE i,len INTEGER
rem   DEFINE hidden INTEGER
rem   --RETURN
rem   IF NOT windowExist("fgldeb") THEN
rem     RETURN
rem   END IF
rem   LET currentwin = om_get_current_window_name()
rem   LET hidden=_deb_getGroupHidden("auto_group")
rem   CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem   CALL raise_window(currentwin)
rem   IF hidden THEN
rem     RETURN
rem   END IF
rem   IF g_state=ST_RUNNING THEN
rem     LET frame_name=g_frame_name
rem   ELSE
rem     LET frame_name="__INIT__"
rem   END IF
rem   LET len=auto_arr.getLength()
rem   FOR i=1 TO len
rem     IF auto_arr[i].frame_name=frame_name THEN
rem       LET result=do_auto_add(auto_arr[i].var_arr)
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   --save the current window
rem   LET currentwin = om_get_current_window_name()
rem   CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem   DISPLAY result to g_auto
rem   CALL raise_window(currentwin)
rem END FUNCTION
rem 
rem 
rem 
rem FUNCTION find_var_name(varname,var_arr,len)
rem   DEFINE varname STRING
rem   DEFINE var_arr DYNAMIC ARRAY OF STRING
rem   DEFINE len,i INTEGER
rem   DEFINE varnameL STRING
rem   LET varnameL=varname.toLowerCase()
rem   FOR i=1 TO len
rem     IF var_arr[i].toLowerCase()=varnameL THEN
rem       RETURN i
rem     END IF
rem   END FOR
rem   RETURN 0
rem END FUNCTION
rem 
rem FUNCTION do_auto_add(var_arr)
rem   DEFINE var_arr, grab_arr, new_arr ,found_arr, res_arr DYNAMIC ARRAY OF STRING
rem   DEFINE var_arr_len,grab_arr_len,new_arr_len,found_arr_len,res_arr_len INTEGER
rem   DEFINE i,found,foundall INTEGER
rem   DEFINE result,varname STRING
rem   LET var_arr_len=var_arr.getLength()
rem   CALL grab_variables(grab_arr)
rem   --first check the newly found variables
rem   LET i=1
rem   LET grab_arr_len=grab_arr.getLength()
rem   FOR i=1 TO grab_arr_len
rem     LET found=0
rem     LET found=find_var_name(grab_arr[i],var_arr,var_arr_len)
rem     IF found <> 0 THEN
rem       --this variable was already inside var_arr
rem       LET found_arr[found_arr.getLength()+1]=var_arr[found]
rem     ELSE
rem       --this one newly appeared
rem       LET new_arr[new_arr.getLength()+1]=grab_arr[i]
rem     END IF
rem   END FOR
rem   --CALL print_arr("var_arr",var_arr)
rem   --CALL print_arr("grab_arr",grab_arr)
rem   --CALL print_arr("new_arr",new_arr)
rem   --CALL print_arr("found_arr",found_arr)
rem 
rem   --now the new detected variables are in new_arr, the already
rem   --known in found_arr
rem   --first add new_arr at the end
rem   --then found_arr before , then the rest from var_arr
rem   LET i=1
rem   LET new_arr_len=new_arr.getLength()
rem   LET res_arr_len=res_arr.getLength()
rem   WHILE res_arr_len<MAXAUTO AND i<=new_arr_len
rem     LET res_arr[res_arr_len+1]=new_arr[i]
rem     LET res_arr_len=res_arr_len+1
rem     LET i=i+1
rem   END WHILE
rem   --CALL print_arr("res_arr",res_arr)
rem 
rem   LET i=1
rem   LET found_arr_len=found_arr.getLength()
rem   WHILE res_arr_len<MAXAUTO AND i<=found_arr_len
rem     CALL res_arr.insertElement(i)
rem     LET res_arr[i]=found_arr[i]
rem     LET res_arr_len=res_arr_len+1
rem     LET i=i+1
rem   END WHILE
rem 
rem   --CALL print_arr("res_arr",res_arr)
rem   --go through var_arr and add the rest of the variables
rem   --which were not detected in _grab_variables
rem   LET i=var_arr_len
rem   WHILE res_arr_len<MAXAUTO AND i>=1
rem     LET varname=var_arr[i]
rem     LET found=0
rem     LET found=find_var_name(varname,found_arr,found_arr_len)
rem     IF found=0 THEN
rem       --DISPLAY "did not find ",varname," in found_arr"
rem       LET found=find_var_name(varname,new_arr,new_arr_len)
rem       IF found=0 THEN
rem         --DISPLAY "did not find ",varname," in new_arr"
rem         CALL res_arr.insertElement(1)
rem         LET res_arr[1]=var_arr[i]
rem         LET res_arr_len=res_arr_len+1
rem       END IF
rem     END IF
rem     LET i=i-1
rem   END WHILE
rem   --CALL print_arr("res_arr",res_arr)
rem 
rem   --finally check if the original var_arr names are completely contained
rem   --in res_arr, then we append only the newly arrived variable names
rem   LET foundall=1
rem   FOR i=1 TO var_arr_len
rem     LET found=0
rem     LET found=find_var_name(var_arr[i],res_arr,res_arr_len)
rem     IF found=0 THEN
rem       LET foundall=0
rem       EXIT FOR
rem     END IF
rem   END FOR
rem   IF foundall THEN
rem     IF res_arr_len>var_arr_len THEN
rem       --add the odd ones out to the end of var_arr
rem       LET i=1
rem       WHILE var_arr_len<MAXAUTO AND i<=res_arr_len
rem         LET found=find_var_name(res_arr[i],var_arr,var_arr_len)
rem         IF found=0 THEN
rem           LET var_arr[var_arr_len+1]=res_arr[i]
rem           LET var_arr_len=var_arr_len+1
rem         END IF
rem         LET i=i+1
rem       END WHILE
rem     END IF
rem     --CALL print_arr("var_arr",res_arr)
rem     LET result=format_var_arr_print(var_arr,1)
rem   ELSE
rem     LET result=format_var_arr_print(res_arr,1)
rem     CALL var_arr.clear()
rem     FOR i=1 TO res_arr_len
rem       LET var_arr[i]=res_arr[i]
rem     END FOR
rem   END IF
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION print_arr(name,var_arr)
rem   DEFINE name STRING
rem   DEFINE var_arr DYNAMIC ARRAY OF STRING
rem   --DEFINE str STRING
rem   --DEFINE i INTEGER
rem   RETURN
rem   --FOR i=1 TO var_arr.getLength()
rem   -- LET str=str.append(sfmt("%1 ",var_arr[i]))
rem   --END FOR
rem   --DISPLAY "Array ",name,"{ ",str,"}"
rem END FUNCTION
rem 
rem --shows the watched variables and allows to delete them
rem FUNCTION do_view_watches_from(where)
rem   DEFINE where STRING
rem   DEFINE i,len,do_inspect INTEGER
rem   DEFINE tmp_arr DYNAMIC ARRAY OF STRING
rem   IF NOT windowExist("edit_watch") THEN OPEN WINDOW edit_watch WITH FORM "fgldeb_edit_watch" ELSE CURRENT WINDOW IS edit_watch END IF CALL set_current_dialog("edit_watch")
rem   LET len=watch_arr.getLength()
rem   FOR i=1 TO len
rem     LET tmp_arr[i]=watch_arr[i]
rem   END FOR
rem   DISPLAY ARRAY watch_arr TO edit_watch.*
rem     ON ACTION delete
rem       CALL watch_arr.deleteElement(arr_curr())
rem     ON ACTION deleteall
rem       CALL watch_arr.clear()
rem     ON ACTION addwatch
rem       LET do_inspect=1
rem       EXIT DISPLAY
rem     ON ACTION cancel
rem       LET len=tmp_arr.getLength()
rem       FOR i=1 TO len
rem         LET watch_arr[i]=tmp_arr[i]
rem       END FOR
rem       EXIT DISPLAY
rem   END DISPLAY
rem   CLOSE WINDOW edit_watch CALL remove_dialog_name("edit_watch")
rem   CALL update_watch()
rem   IF do_inspect THEN
rem     IF where="fgldeb" THEN
rem       RETURN inspectvariable(0)
rem     ELSE
rem       RETURN "inspectvariable"
rem     END IF
rem   ELSE
rem     RETURN where
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION do_hide_group_int(tagName,actionName,buttontitle,hidden)
rem   DEFINE tagName,actionName,buttontitle,hidden STRING
rem   IF hidden IS NOT NULL THEN
rem     IF hidden="1" THEN
rem       CALL _deb_setGroupHidden(tagName,"1")
rem       CALL _deb_setButtonText (actionName,sfmt("Show %1",buttontitle))
rem     ELSE
rem       CALL _deb_setGroupHidden(tagName,"0")
rem       CALL _deb_setButtonText (actionName,sfmt("Hide %1",buttontitle))
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION toggle_hide_group(tagName,actionName,buttontitle)
rem   DEFINE tagName,actionName,buttontitle STRING
rem   DEFINE hidden STRING
rem   LET hidden=_deb_getGroupHidden(tagName)
rem   IF hidden IS NOT NULL THEN
rem     --toggle the visibility
rem     IF hidden="0" THEN
rem       LET hidden="1"
rem     ELSE
rem       LET hidden="0"
rem     END IF
rem     CALL do_hide_group_int(tagName,actionName,buttontitle,hidden)
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION add_splitter()
rem   DEFINE node om.DomNode
rem   DEFINE v INT
rem   LET v = fgl_getversion()
rem   IF v<=1169 THEN
rem     RETURN
rem   END IF
rem   LET node=_deb_getOmNodeByTag("VBox","main_vbox")
rem   IF node IS NOT NULL THEN
rem     CALL node.setAttribute("splitter","1")
rem     LET node=_deb_getOmNodeByTag("TextEdit","textedit_auto")
rem     IF node IS NOT NULL THEN
rem       CALL node.setAttribute("stretch","both")
rem     END IF
rem     LET node=_deb_getOmNodeByTag("TextEdit","textedit_watch")
rem     IF node IS NOT NULL THEN
rem       CALL node.setAttribute("stretch","both")
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem --lengthy function to raise the right window,
rem --may be this is easier with dom
rem FUNCTION raise_window(window_name)
rem   DEFINE window_name STRING
rem   CASE window_name
rem     WHEN "fgldeb"
rem       CURRENT WINDOW IS fgldeb CALL set_current_dialog("fgldeb")
rem     WHEN "finish"
rem       CURRENT WINDOW IS finish CALL set_current_dialog("finish")
rem     WHEN "fdbcommand"
rem       CURRENT WINDOW IS fdbcommand CALL set_current_dialog("fdbcommand")
rem     WHEN "fdbhistory"
rem       CURRENT WINDOW IS fdbhistory CALL set_current_dialog("fdbhistory")
rem     WHEN "fdbcommandlist"
rem       CURRENT WINDOW IS fdbcommandlist CALL set_current_dialog("fdbcommandlist")
rem     WHEN "stack"
rem       CURRENT WINDOW IS stack CALL set_current_dialog("stack")
rem     WHEN "input_path"
rem       CURRENT WINDOW IS input_path CALL set_current_dialog("input_path")
rem     WHEN "dirlist"
rem       CURRENT WINDOW IS dirlist CALL set_current_dialog("dirlist")
rem     WHEN "modules"
rem       CURRENT WINDOW IS modules CALL set_current_dialog("modules")
rem     WHEN "functions"
rem       CURRENT WINDOW IS functions CALL set_current_dialog("functions")
rem     WHEN "break"
rem       CURRENT WINDOW IS break CALL set_current_dialog("break")
rem     WHEN "addbreak"
rem       CURRENT WINDOW IS addbreak CALL set_current_dialog("addbreak")
rem     WHEN "search"
rem       CURRENT WINDOW IS search CALL set_current_dialog("search")
rem     WHEN "variables"
rem       CURRENT WINDOW IS local_variables CALL set_current_dialog("local_variables")
rem     WHEN "variables"
rem       CURRENT WINDOW IS global_variables CALL set_current_dialog("global_variables")
rem     WHEN "complete_variable"
rem       CURRENT WINDOW IS complete_variable CALL set_current_dialog("complete_variable")
rem     WHEN "complete_function"
rem       CURRENT WINDOW IS complete_function CALL set_current_dialog("complete_function")
rem     WHEN "inspectvariable"
rem       CURRENT WINDOW IS inspectvariable CALL set_current_dialog("inspectvariable")
rem   END CASE
rem END FUNCTION
rem 
rem FUNCTION update_status(refresh,where)
rem   DEFINE refresh INTEGER
rem   DEFINE where STRING
rem   IF om_get_current_window_name()=="fgldeb" THEN
rem     MESSAGE sfmt("Current function:%1 Status:%2 Line:%3",
rem                   g_frame_name,g_state,g_status_line_no)
rem     DISPLAY g_frame_name TO currFunc
rem     DISPLAY g_status_line_no TO cLine 
rem     IF g_show_output AND refresh THEN
rem       --DISPLAY "status ",where,g_status_line_no,",refresh:",refresh," RED"
rem       DISPLAY g_state TO cStatus ATTRIBUTES(REVERSE,RED)
rem     ELSE
rem       IF g_state=ST_RUNNING THEN
rem         --DISPLAY "status ",where,g_status_line_no,",refresh:",refresh," GREEN"
rem         DISPLAY g_state TO cStatus ATTRIBUTES(REVERSE,GREEN)
rem       ELSE
rem         --DISPLAY "status ",where,g_status_line_no,",refresh:",refresh," normal"
rem         DISPLAY g_state TO cStatus 
rem       END IF
rem     END IF
rem 
rem     IF refresh THEN
rem       CALL fgl_refresh()
rem     END IF
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION help_dialog(str)
rem   DEFINE str STRING
rem   --DEFINE helpstr STRING
rem   DEFINE i,iold,len INTEGER
rem   --DEFINE node om.DomNode
rem   OPEN WINDOW help WITH FORM "fgldeb_help" 
rem   LET i=1
rem   LET len=str.getLength()
rem   LET g_helpstr=""
rem   --go through and replace \\\n with real new lines
rem   WHILE i<len
rem     LET iold=i
rem     LET i=str.getIndexOf("\\n",iold)
rem     IF i<>0 THEN
rem       LET g_helpstr=g_helpstr.append(str.subString(iold,i-1))
rem       LET g_helpstr=g_helpstr.append("\n")
rem       LET i=i+2
rem     ELSE
rem       LET g_helpstr=g_helpstr.append(str.subString(iold,len))
rem       EXIT WHILE
rem     END IF
rem   END WHILE
rem   INPUT BY NAME g_helpstr WITHOUT DEFAULTS
rem     ON ACTION close
rem       EXIT INPUT
rem     ON ACTION find
rem       LET g_helpcursor=fgl_dialog_getcursor()
rem       --LET helpstr=remove_newlines(g_helpstr)
rem       --DISPLAY "at char ",helpstr.getCharAt(g_helpcursor)
rem       CALL do_find("help","Help items")
rem     ON ACTION findnext
rem       LET g_helpcursor=fgl_dialog_getcursor()+1
rem       --LET helpstr=remove_newlines(g_helpstr)
rem       --DISPLAY "at char ",helpstr.getCharAt(g_helpcursor)
rem       CALL do_findnext("help")
rem     ON ACTION backspace
rem       --DISPLAY "backspace"
rem     ON ACTION del
rem       --DISPLAY "del"
rem     ON ACTION editcut
rem       --DISPLAY "editcut"
rem     ON ACTION editpaste
rem       --DISPLAY "editpaste"
rem   END INPUT
rem   {
rem   DISPLAY g_helpstr TO helpstr
rem   MENU "tmp"
rem     COMMAND "Close"
rem       EXIT MENU
rem   END MENU
rem   }
rem   CLOSE WINDOW help
rem END FUNCTION
rem 
rem FUNCTION file_get_home_dir()
rem   DEFINE home STRING
rem   IF file_on_windows() THEN
rem     LET home=fgl_getenv("HOMEDRIVE"),fgl_getenv("HOMEPATH")
rem   ELSE
rem     LET home=fgl_getenv("HOME")
rem   END IF
rem   RETURN home
rem END FUNCTION
rem 
rem FUNCTION file_join(part1,part2)
rem   DEFINE part1,part2,result STRING
rem   IF file_on_windows() THEN
rem     LET result=part1,"\\",part2
rem   ELSE
rem     LET result=part1,"/",part2
rem   END IF
rem   RETURN result
rem END FUNCTION
rem 
rem FUNCTION file_on_windows()
rem   IF fgl_getenv("WINDIR") IS NULL THEN
rem     RETURN 0
rem   ELSE
rem     RETURN 1
rem   END IF
rem END FUNCTION
rem 
rem {
rem FUNCTION get_config_filename()
rem   DEFINE home,cfgfile STRING
rem   LET home=file_get_home_dir()
rem   LET cfgfile=file_join(home,".fgldeb")
rem   RETURN cfgfile
rem END FUNCTION
rem 
rem FUNCTION write_config_file()
rem   DEFINE root,simpleopts om.DomNode
rem   DEFINE doc om.DomDocument
rem   DEFINE cfile STRING
rem   LET cfile=get_config_filename()
rem   IF cfile IS NULL THEN
rem     ERROR "can't get config file name"
rem     RETURN
rem   END IF
rem   LET doc=om.DomDocument.create("FglDebuggerOptions")
rem   LET root=doc.getDocumentElement()
rem   LET simpleopts=root.createChild("SimpleOptions")
rem   CALL write_simple_opts(simpleopts)
rem   CALL root.writeXml(cfile)
rem END FUNCTION
rem 
rem FUNCTION read_config_file()
rem   DEFINE cfile STRING
rem   DEFINE nlist om.NodeList
rem   DEFINE root,simpleopts om.DomNode
rem   DEFINE doc om.DomDocument
rem   LET cfile=get_config_filename()
rem   IF cfile IS NULL THEN
rem     ERROR "can't get config file name"
rem     RETURN
rem   END IF
rem   LET doc=om.DomDocument.createFromXmlFile(cfile)
rem   IF doc IS NULL THEN
rem     MESSAGE "can't file config file"
rem     RETURN
rem   END IF
rem   LET root=doc.getDocumentElement()
rem   LET nlist=root.selectByPath("//SimpleOptions")
rem   IF nlist.getLength()=1 THEN
rem     LET simpleopts=nlist.item(1)
rem     CALL read_simple_opts(simpleopts)
rem   END IF
rem END FUNCTION
rem 
rem --this simple function checks if a node has a specified attribute
rem FUNCTION attrExists(node,name)
rem   DEFINE node om.DomNode
rem   DEFINE name STRING
rem   DEFINE i,len INTEGER
rem   LET len=node.getAttributesCount()
rem   FOR i=1 TO len
rem     IF node.getAttributeName(i)=name THEN
rem       RETURN 1
rem     END IF
rem   END FOR
rem   RETURN 0
rem END FUNCTION
rem 
rem FUNCTION read_simple_opts(simpleopts)
rem   DEFINE simpleopts om.DomNode
rem   IF attrExists(simpleopts,"restoreBreakpoints") THEN
rem     LET g_cfg_restoreBreak=simpleopts.getAttribute("restoreBreakpoints")
rem   END IF
rem   IF attrExists(simpleopts,"restoreHistory") THEN
rem     LET g_cfg_restoreHistory=simpleopts.getAttribute("restoreHistory")
rem   END IF
rem   IF attrExists(simpleopts,"showAuto") THEN
rem     LET g_cfg_showAuto=simpleopts.getAttribute("showAuto")
rem   END IF
rem   IF attrExists(simpleopts,"showWatch") THEN
rem     LET g_cfg_showAuto=simpleopts.getAttribute("showWatch")
rem   END IF
rem END FUNCTION
rem 
rem FUNCTION write_simple_opts(simpleopts)
rem   DEFINE simpleopts om.DomNode
rem   CALL simpleopts.setAttribute("restoreBreakpoints",g_cfg_restoreBreak)
rem   CALL simpleopts.setAttribute("restoreHistory" ,g_cfg_restoreHistory)
rem   CALL simpleopts.setAttribute("showAuto" ,g_cfg_showAuto)
rem   CALL simpleopts.setAttribute("showWatch" ,g_cfg_showWatch)
rem END FUNCTION
rem }
rem 
rem 
rem --FUNCTION dialog_general_options()
rem --  OPEN WINDOW fdeb_options WITH FORM "fgldeb_options" 
rem --  CLOSE WINDOW fdeb_options 
rem --END FUNCTION
rem 
rem --tests for equality of 2 Strings
rem --if NULL_is_EqualEmpty is true then
rem -- equalStringsInt(""," " CLIPPED,true) returns 1
rem FUNCTION equalStringsInt(val1,val2,NULL_is_EqualEmpty)
rem    DEFINE val1,val2 String
rem    DEFINE NULL_is_EqualEmpty,equal Integer
rem    LET equal=0
rem    IF ((val1 IS NULL) AND (val2 IS NOT NULL)) OR
rem       ((val1 IS NOT NULL) AND (val2 IS NULL)) THEN
rem      --one of them is NULL the other not
rem      IF NULL_is_EqualEmpty THEN
rem        --val2 is NULL,val1 empty ?
rem        IF (val1 IS NOT NULL) AND (val1.getLength()=0) THEN
rem          LET equal=1
rem        --val1 is NULL,val2 empty ?
rem        ELSE IF (val2 IS NOT NULL) AND (val2.getLength()=0) THEN
rem          LET equal=1
rem        ELSE
rem          --ok , none of them is empty
rem          LET equal=0
rem        END IF
rem        END IF
rem      ELSE
rem        LET equal=0
rem      END IF
rem    ELSE IF (val1 IS NULL) AND (val2 IS NULL) THEN
rem      LET equal=1
rem    ELSE IF (val1<>val2) OR
rem            (val1.getLength()<>val2.getLength()) THEN
rem      LET equal=0
rem    ELSE IF (val1=val2) AND 
rem            (val1.getLength()==val2.getLength()) THEN
rem      --they must be equal and have the same length
rem      LET equal=1
rem    ELSE
rem      --can't happen exception
rem      DISPLAY "bummer in FUNCTION _qa_equalStringsInt()"
rem    END IF
rem    END IF
rem    END IF
rem    END IF
rem    RETURN equal
rem END FUNCTION
rem 
rem #+ tests 2 strings for real equality and avoids the pitfalls of 4GL in doing that
rem #+ @returnType Integer
rem #+ @return 1 when the 2 Strings are equal,0 otherwise
rem #+ 
rem FUNCTION equalStrings(val1,val2)
rem    define val1,val2 String
rem    RETURN equalStringsInt(val1,val2,0)
rem END FUNCTION
rem 
rem #+ tests 2 strings for equality , but the empty string is treated equal to NULL
rem #+ @returnType Integer
rem #+ @return 1 when the 2 Strings are equal,0 otherwise
rem #+ 
rem FUNCTION equalStringsAndNULLequalsEmpty(val1,val2)
rem    define val1,val2 String
rem    RETURN equalStringsInt(val1,val2,1)
rem END FUNCTION
rem __CAT_EOF_END__
