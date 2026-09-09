[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$project = Join-Path $repoRoot 'ssf_game\ssf_game.csproj'
$runtime = 'win-x64'
$publishDir = Join-Path $repoRoot "ssf_game\bin\ssf-publish\$runtime"
$isWindowsHost = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
if (-not $isWindowsHost) { throw 'Build win-x64 on Windows.' }

$sourceCommit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Cannot determine source commit.' }
$sourceDirty = -not [string]::IsNullOrWhiteSpace((& git -C $repoRoot status --porcelain --untracked-files=no | Out-String))

& dotnet publish $project -c Release -r $runtime --self-contained true --disable-build-servers -warnaserror `
    -p:PublishAot=true -p:PublishSingleFile=false -o $publishDir
if ($LASTEXITCODE -ne 0) { throw "NativeAOT publish failed ($LASTEXITCODE)." }

$exeName = 'ssf_game.exe'
$libraryPath = 'win64/steam_api64.dll'
$exePath = Join-Path $publishDir $exeName
$library = Join-Path $repoRoot "redistributable_bin/$libraryPath"
if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) { throw "Missing runner: $exePath" }
if (-not (Test-Path -LiteralPath $library -PathType Leaf)) { throw "Missing Steam redistributable: $library" }

$manifest = [ordered]@{
    protocolVersion = 1
    runtime = $runtime
    sourceCommit = $sourceCommit
    sourceDirty = $sourceDirty
    executable = $exeName
    sha256 = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash
    steamLibrary = [IO.Path]::GetFileName($library)
    steamLibrarySha256 = (Get-FileHash -LiteralPath $library -Algorithm SHA256).Hash
}
$manifestPath = Join-Path $publishDir 'ssf_game.manifest.json'
$manifest | ConvertTo-Json | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Copy-Item -LiteralPath $library -Destination $publishDir -Force
Write-Output "Published $runtime runner: $((Get-Item -LiteralPath $exePath).Length) bytes"
Write-Output "Published in $publishDir"
