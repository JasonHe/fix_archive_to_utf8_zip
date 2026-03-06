@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "ARCHIVE=%~1"
if "%ARCHIVE%"=="" exit /b
if not exist "%ARCHIVE%" exit /b

set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
if not exist "%SEVENZIP%" exit /b

set "ARCHIVE_CANON=%ARCHIVE%"
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$p=$env:ARCHIVE_CANON; $dir=Split-Path -LiteralPath $p; $name=[IO.Path]::GetFileName($p); if($name -match '^(.*)\.part(\d+)\.rar$'){ $base=$matches[1]; $digits=$matches[2].Length; $first='{0}.part{1}.rar' -f $base, ('1'.PadLeft($digits,'0')); [IO.Path]::Combine($dir,$first) } elseif($name -match '^(.*)\.7z\.(\d+)$'){ $base=$matches[1]; $digits=$matches[2].Length; $first='{0}.7z.{1}' -f $base, ('1'.PadLeft($digits,'0')); [IO.Path]::Combine($dir,$first) } elseif($name -match '^(.*)\.zip\.(\d+)$'){ $base=$matches[1]; $digits=$matches[2].Length; $first='{0}.zip.{1}' -f $base, ('1'.PadLeft($digits,'0')); [IO.Path]::Combine($dir,$first) } elseif($name -match '^(.*)\.r\d\d$'){ [IO.Path]::Combine($dir, ($matches[1] + '.rar')) } elseif($name -match '^(.*)\.z\d\d$'){ [IO.Path]::Combine($dir, ($matches[1] + '.zip')) } else { $p }"`) do set "ARCHIVE_CANON=%%P"

if not exist "%ARCHIVE_CANON%" exit /b

for %%I in ("%ARCHIVE_CANON%") do (
    set "FULLNAME=%%~nxI"
    set "EXT=%%~xI"
    set "INPUTDIR=%%~dpI"
)

set "FINAL_BASE="
for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "$name=[IO.Path]::GetFileName($env:ARCHIVE_CANON); if($name -match '^(.*)\.part\d+\.rar$'){ $matches[1] } elseif($name -match '^(.*)\.7z\.\d+$'){ $matches[1] } elseif($name -match '^(.*)\.zip\.\d+$'){ $matches[1] } elseif($name -match '^(.*)\.r\d\d$'){ $matches[1] } elseif($name -match '^(.*)\.z\d\d$'){ $matches[1] } elseif($name -match '^(.*)\.tar\.gz$'){ $matches[1] } elseif($name -match '^(.*)\.tar\.bz2$'){ $matches[1] } elseif($name -match '^(.*)\.tar\.xz$'){ $matches[1] } elseif($name -match '^(.*)\.tgz$'){ $matches[1] } elseif($name -match '^(.*)\.tbz2$'){ $matches[1] } elseif($name -match '^(.*)\.txz$'){ $matches[1] } else { [IO.Path]::GetFileNameWithoutExtension($name) }"`) do set "FINAL_BASE=%%B"

if not defined FINAL_BASE exit /b

set "ARCHIVE_KIND="

if /I "%FULLNAME:~-8%"==".zip.001" set "ARCHIVE_KIND=zip"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-7%"==".7z.001" set "ARCHIVE_KIND=7z"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-7%"==".tar.gz" set "ARCHIVE_KIND=targz"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-4%"==".tgz" set "ARCHIVE_KIND=targz"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-8%"==".tar.bz2" set "ARCHIVE_KIND=tarbz2"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-5%"==".tbz2" set "ARCHIVE_KIND=tarbz2"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-7%"==".tar.xz" set "ARCHIVE_KIND=tarxz"
if not defined ARCHIVE_KIND if /I "%FULLNAME:~-4%"==".txz" set "ARCHIVE_KIND=tarxz"

if not defined ARCHIVE_KIND (
    if /I "%EXT%"==".zip" set "ARCHIVE_KIND=zip"
    if /I "%EXT%"==".rar" set "ARCHIVE_KIND=rar"
    if /I "%EXT%"==".7z"  set "ARCHIVE_KIND=7z"
    if /I "%EXT%"==".tar" set "ARCHIVE_KIND=tar"
    if /I "%EXT%"==".gz"  set "ARCHIVE_KIND=gz"
    if /I "%EXT%"==".bz2" set "ARCHIVE_KIND=bz2"
    if /I "%EXT%"==".xz"  set "ARCHIVE_KIND=xz"
)

if not defined ARCHIVE_KIND exit /b

set "PASSARG="
set "PASSWORD="
set "PS_PASS="

call :detect_encryption
if "%IS_ENCRYPTED%"=="1" (
    call :prompt_password
    if not defined PASSWORD exit /b
    set "PASSARG=-p%PASSWORD%"
)

set "WORKDIR=%TEMP%\fixarc_%RANDOM%_%RANDOM%"
set "STAGE1=%WORKDIR%\stage1"
set "OUTDIR=%WORKDIR%\out"
set "ZIPDEF=%WORKDIR%\zip_default"
set "ZIPGBK=%WORKDIR%\zip_gbk"

mkdir "%STAGE1%" >nul 2>nul
mkdir "%OUTDIR%" >nul 2>nul
mkdir "%ZIPDEF%" >nul 2>nul
mkdir "%ZIPGBK%" >nul 2>nul

if /I "%ARCHIVE_KIND%"=="zip" goto extract_zip_smart
if /I "%ARCHIVE_KIND%"=="rar" goto extract_direct
if /I "%ARCHIVE_KIND%"=="7z"  goto extract_direct
if /I "%ARCHIVE_KIND%"=="tar" goto extract_direct
if /I "%ARCHIVE_KIND%"=="gz"  goto extract_single_stream
if /I "%ARCHIVE_KIND%"=="bz2" goto extract_single_stream
if /I "%ARCHIVE_KIND%"=="xz"  goto extract_single_stream
if /I "%ARCHIVE_KIND%"=="targz"  goto extract_double
if /I "%ARCHIVE_KIND%"=="tarbz2" goto extract_double
if /I "%ARCHIVE_KIND%"=="tarxz"  goto extract_double

goto cleanup

:extract_zip_smart
call :zip_try_default
set "RC_DEF=%ERRORLEVEL%"
call :zip_try_gbk
set "RC_GBK=%ERRORLEVEL%"

if not "%RC_DEF%"=="0" if not "%RC_GBK%"=="0" (
    if not defined PASSARG (
        call :prompt_password
        if not defined PASSWORD goto cleanup
        set "PASSARG=-p%PASSWORD%"
        call :zip_try_default
        set "RC_DEF=%ERRORLEVEL%"
        call :zip_try_gbk
        set "RC_GBK=%ERRORLEVEL%"
    )
)

if "%RC_DEF%"=="0" if not "%RC_GBK%"=="0" (
    set "OUTDIR=%ZIPDEF%"
    goto repack
)

if not "%RC_DEF%"=="0" if "%RC_GBK%"=="0" (
    set "OUTDIR=%ZIPGBK%"
    goto repack
)

if not "%RC_DEF%"=="0" if not "%RC_GBK%"=="0" goto cleanup

set "SCORE_PATH=%ZIPDEF%"
call :score_dir
set "SCORE_DEF=%DIR_SCORE%"

set "SCORE_PATH=%ZIPGBK%"
call :score_dir
set "SCORE_GBK=%DIR_SCORE%"

if %SCORE_GBK% GTR %SCORE_DEF% (
    set "OUTDIR=%ZIPGBK%"
) else (
    set "OUTDIR=%ZIPDEF%"
)
goto repack

:zip_try_default
rd /s /q "%ZIPDEF%" >nul 2>nul
mkdir "%ZIPDEF%" >nul 2>nul
"%SEVENZIP%" x -y -o"%ZIPDEF%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
exit /b %ERRORLEVEL%

:zip_try_gbk
rd /s /q "%ZIPGBK%" >nul 2>nul
mkdir "%ZIPGBK%" >nul 2>nul
"%SEVENZIP%" x -y -mcp=936 -o"%ZIPGBK%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
exit /b %ERRORLEVEL%

:extract_direct
"%SEVENZIP%" x -y -o"%OUTDIR%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
if errorlevel 1 (
    if not defined PASSARG (
        call :prompt_password
        if not defined PASSWORD goto cleanup
        set "PASSARG=-p%PASSWORD%"
        "%SEVENZIP%" x -y -o"%OUTDIR%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
        if errorlevel 1 goto cleanup
    ) else (
        goto cleanup
    )
)
goto repack

:extract_single_stream
"%SEVENZIP%" x -y -o"%STAGE1%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
if errorlevel 1 (
    if not defined PASSARG (
        call :prompt_password
        if not defined PASSWORD goto cleanup
        set "PASSARG=-p%PASSWORD%"
        rd /s /q "%STAGE1%" >nul 2>nul
        mkdir "%STAGE1%" >nul 2>nul
        "%SEVENZIP%" x -y -o"%STAGE1%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
        if errorlevel 1 goto cleanup
    ) else (
        goto cleanup
    )
)

set "INNER_NAME="
for /f "delims=" %%F in ('dir /b /a-d "%STAGE1%" 2^>nul') do set "INNER_NAME=%%F"
if not defined INNER_NAME goto cleanup

if /I "%INNER_NAME:~-4%"==".tar" (
    "%SEVENZIP%" x -y -o"%OUTDIR%" "%STAGE1%\%INNER_NAME%" >nul 2>nul
    if errorlevel 1 goto cleanup
) else (
    copy /y "%STAGE1%\%INNER_NAME%" "%OUTDIR%\" >nul 2>nul
    if errorlevel 1 goto cleanup
)
goto repack

:extract_double
"%SEVENZIP%" x -y -o"%STAGE1%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
if errorlevel 1 (
    if not defined PASSARG (
        call :prompt_password
        if not defined PASSWORD goto cleanup
        set "PASSARG=-p%PASSWORD%"
        rd /s /q "%STAGE1%" >nul 2>nul
        mkdir "%STAGE1%" >nul 2>nul
        "%SEVENZIP%" x -y -o"%STAGE1%" %PASSARG% "%ARCHIVE_CANON%" >nul 2>nul
        if errorlevel 1 goto cleanup
    ) else (
        goto cleanup
    )
)

set "INNER_NAME="
for /f "delims=" %%F in ('dir /b /a-d "%STAGE1%" 2^>nul') do set "INNER_NAME=%%F"
if not defined INNER_NAME goto cleanup

"%SEVENZIP%" x -y -o"%OUTDIR%" "%STAGE1%\%INNER_NAME%" >nul 2>nul
if errorlevel 1 goto cleanup
goto repack

:repack
call :next_output_name
if not defined NEWZIP goto cleanup

pushd "%OUTDIR%" >nul
"%SEVENZIP%" a -y -tzip -mm=Deflate "%NEWZIP%" * >nul 2>nul
popd >nul

:cleanup
rd /s /q "%WORKDIR%" >nul 2>nul
exit /b

:next_output_name
set "NEWZIP=%INPUTDIR%%FINAL_BASE%_fixed.zip"
if not exist "%NEWZIP%" exit /b 0
set /a N=1
:next_output_name_loop
set "NEWZIP=%INPUTDIR%%FINAL_BASE%_fixed_%N%.zip"
if exist "%NEWZIP%" (
    set /a N+=1
    goto next_output_name_loop
)
exit /b 0

:detect_encryption
set "IS_ENCRYPTED=0"
for /f "usebackq delims=" %%E in (`powershell -NoProfile -Command "$p=$env:ARCHIVE_CANON; $exe=$env:SEVENZIP; try { $out = & $exe 'l' '-slt' $p 2>$null; if(($out | Select-String -SimpleMatch 'Encrypted = +').Count -gt 0){ '1' } else { '0' } } catch { '0' }"`) do set "IS_ENCRYPTED=%%E"
exit /b 0

:prompt_password
set "PASSWORD="
for /f "usebackq delims=" %%P in (`powershell -NoProfile -STA -Command "Add-Type -AssemblyName Microsoft.VisualBasic; $p=[Microsoft.VisualBasic.Interaction]::InputBox('Please enter the archive password:','Archive Password',''); Write-Output $p"`) do set "PASSWORD=%%P"
exit /b 0

:score_dir
set "DIR_SCORE=0"
for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command "$p=$env:SCORE_PATH; try { $items = Get-ChildItem -LiteralPath $p -Recurse -Force -Name -ErrorAction Stop; if($null -eq $items){ $items=@() }; $cjk = ($items | Where-Object { $_ -match '[\u4E00-\u9FFF]' }).Count; $bad = ($items | Where-Object { $_ -match '[\u2500-\u257F\u2580-\u259F\uFFFD]' }).Count; $q = ($items | Where-Object { $_ -like '*?*' }).Count; $score = ($cjk * 20) - ($bad * 15) - ($q * 5); Write-Output $score } catch { Write-Output -9999 }"`) do set "DIR_SCORE=%%S"
exit /b 0