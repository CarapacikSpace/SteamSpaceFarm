[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Build win-x64 on Windows.' }
$project = Join-Path $repoRoot 'ssf_steam_helper/ssf_steam_helper.csproj'
$destination = Join-Path $repoRoot 'ssf_steam_helper/bin/standalone/win-x64'
& dotnet publish $project -c Release -r win-x64 --self-contained true -warnaserror `
    -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true -p:PublishTrimmed=false -p:PublishAot=false `
    -p:DebugType=None -o $destination
if ($LASTEXITCODE -ne 0) { throw "Steam library helper publish failed ($LASTEXITCODE)." }
$executable = Join-Path $destination 'ssf_steam_helper.exe'
Write-Output "Standalone Steam library helper: $executable"
Write-Output "Size: $((Get-Item -LiteralPath $executable).Length) bytes."
