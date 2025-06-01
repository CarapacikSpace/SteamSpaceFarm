@echo off
setlocal EnableDelayedExpansion

set CONFIG=Release
set TEMPDIR=build_temp
set FINALDIR=..\space_farm\process\steam_game
set PROJECT_FILE=..\SteamGame\SteamGame.csproj
set PROJECT_NAME=SteamGame
set RUNTIMES=win-x64 linux-x64 osx-x64

if not exist "!PROJECT_FILE!" (
    echo ERROR: Project file not found at !PROJECT_FILE!
    exit /b 1
)

if not exist "%FINALDIR%" mkdir "%FINALDIR%"

for %%R in (%RUNTIMES%) do (
    echo.
    echo Building for %%R...

    for /f "tokens=1,2 delims=-" %%a in ("%%R") do (
        set "PLATFORM=%%a"
        set "ARCH=%%b"
    )

    set "NAME=!PROJECT_NAME!_!PLATFORM!_!ARCH!"
    set "EXT="
    if "!PLATFORM!"=="win" set "EXT=.exe"

    set "RID=%%R"
    set "TEMPOUT=%TEMPDIR%\%%R"
    if exist "!TEMPOUT!" rmdir /s /q "!TEMPOUT!"
    mkdir "!TEMPOUT!"

    dotnet publish "!PROJECT_FILE!" -c %CONFIG% -r !RID! --self-contained true ^
        -p:PublishSingleFile=true -p:AssemblyName=!NAME! -o "!TEMPOUT!" >nul

    rem --- copy matching steam_api DLL
    if "!PLATFORM!"=="win" (
        copy /Y "..\steamworks\redistributable_bin\win64\steam_api64.dll" "!TEMPOUT!\steam_api64.dll" >nul
    )
    if "!PLATFORM!"=="linux" (
        copy /Y "..\steamworks\redistributable_bin\linux64\libsteam_api.so" "!TEMPOUT!\libsteam_api.so" >nul
    )
    if "!PLATFORM!"=="osx" (
        copy /Y "..\steamworks\redistributable_bin\osx\libsteam_api.dylib" "!TEMPOUT!\libsteam_api.dylib" >nul
    )

    rem --- copy output to final directory
    if exist "!TEMPOUT!\!NAME!!EXT!" (
        copy /Y "!TEMPOUT!\*.*" "!FINALDIR!\" >nul
        echo Output copied to: !FINALDIR!\!NAME!!EXT!
    ) else (
        echo FAILED: Output file not found for !RID!
    )
)

echo.
echo Cleaning up temporary files...
rmdir /s /q "%TEMPDIR%" >nul

echo Done. Final builds are in "%FINALDIR%"
pause
