[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
Push-Location (Join-Path $repoRoot 'ssf_flutter')
try {
    & flutter gen-l10n
    if ($LASTEXITCODE -ne 0) { throw 'Localization generation failed.' }
} finally {
    Pop-Location
}
