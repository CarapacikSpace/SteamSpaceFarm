[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
Push-Location (Join-Path $repoRoot 'ssf_flutter')
try {
    & dart pub global activate intl_utils
    if ($LASTEXITCODE -ne 0) { throw 'Cannot activate intl_utils.' }
    & dart pub global run intl_utils:generate
    if ($LASTEXITCODE -ne 0) { throw 'Localization generation failed.' }
    $generated = 'lib/src/localization/generated'
    foreach ($file in Get-ChildItem -LiteralPath $generated -Recurse -Filter '*.dart' -File) {
        $lines = Get-Content -LiteralPath $file.FullName | Where-Object { $_ -notmatch '^\s*//' }
        $lines = $lines | ForEach-Object { $_.Replace('package:flutter/material.dart', 'package:material_ui/material_ui.dart') }
        Set-Content -LiteralPath $file.FullName -Value $lines -Encoding utf8
    }
    & dart format $generated
    if ($LASTEXITCODE -ne 0) { throw 'Localization formatting failed.' }
} finally {
    Pop-Location
}
