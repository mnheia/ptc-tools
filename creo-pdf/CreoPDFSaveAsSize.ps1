<#
.SYNOPSIS
    Renames PDF drawings with an ISO A-series page-size suffix.

.DESCRIPTION
    Uses pdfinfo.exe to read the first page of each PDF in a directory.
    Files matching A0-A4 within the specified tolerance are renamed to
    <original-name>-a0.pdf, ... <original-name>-a4.pdf.

    Existing suffixes and destination filename conflicts are skipped.
    Supports -WhatIf and -Confirm.

.NOTES
    Author: Mitja Sovec
    Originally created: 2025-01-20
    Requires Windows PowerShell 5.1 or newer and an external pdfinfo.exe.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$PdfDir = 'C:\Creo PDF',

    [Parameter()]
    [string]$PdfInfoPath,

    [Parameter()]
    [ValidateRange(0.1, 20.0)]
    [double]$ToleranceMm = 3.0
)

$ErrorActionPreference = 'Stop'

# Search for pdfinfo.exe at an explicit path, beside this script, or in PATH.
if (-not [string]::IsNullOrWhiteSpace($PdfInfoPath)) {
    if (-not (Test-Path -LiteralPath $PdfInfoPath -PathType Leaf)) {
        throw "pdfinfo.exe not found: $PdfInfoPath"
    }
    $pdfinfoExe = (Resolve-Path -LiteralPath $PdfInfoPath).ProviderPath
}
else {
    $localExe = Join-Path -Path $PSScriptRoot -ChildPath 'pdfinfo.exe'
    if (Test-Path -LiteralPath $localExe -PathType Leaf) {
        $pdfinfoExe = $localExe
    }
    else {
        $command = Get-Command -Name 'pdfinfo.exe' -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($null -eq $command) {
            throw 'pdfinfo.exe was not found. Put it beside the script, add it to PATH, or specify -PdfInfoPath.'
        }
        $pdfinfoExe = $command.Source
    }
}

if (-not (Test-Path -LiteralPath $PdfDir -PathType Container)) {
    throw "PDF directory does not exist: $PdfDir"
}

# ISO 216 A-series dimensions in millimetres (portrait orientation).
$pageSizes = [ordered]@{
    A0 = @(841.0, 1189.0)
    A1 = @(594.0, 841.0)
    A2 = @(420.0, 594.0)
    A3 = @(297.0, 420.0)
    A4 = @(210.0, 297.0)
}

$scanned = 0
$renamed = 0
$planned = 0
$skipped = 0
$errors = 0

$pdfFiles = @(Get-ChildItem -LiteralPath $PdfDir -Filter '*.pdf' -File)

foreach ($pdfFile in $pdfFiles) {
    $scanned++

    # Idempotency: avoid names such as drawing-a3-a3.pdf.
    if ($pdfFile.BaseName -match '(?i)-a[0-4]$') {
        Write-Host "SKIP (already named): $($pdfFile.Name)"
        $skipped++
        continue
    }

    try {
        # Direct invocation avoids Invoke-Expression and handles paths with spaces.
        $infoOutput = (& $pdfinfoExe -box $pdfFile.FullName 2>&1 | Out-String)
        $infoExitCode = $LASTEXITCODE
        if ($infoExitCode -ne 0) {
            throw "pdfinfo failed with exit code $infoExitCode. $($infoOutput.Trim())"
        }

        # Supports both 'Page size:' and 'Page    1 size:' output formats.
        $match = [regex]::Match(
            $infoOutput,
            '(?im)^\s*Page(?:\s+\d+)?\s+size:\s*(\d+(?:\.\d+)?)\s*x\s*(\d+(?:\.\d+)?)\s+pts\b'
        )

        if (-not $match.Success) {
            Write-Warning "Could not read page dimensions: $($pdfFile.Name)"
            $skipped++
            continue
        }

        $culture = [System.Globalization.CultureInfo]::InvariantCulture
        $widthPt = [double]::Parse($match.Groups[1].Value, $culture)
        $heightPt = [double]::Parse($match.Groups[2].Value, $culture)
        $widthMm = $widthPt * 25.4 / 72.0
        $heightMm = $heightPt * 25.4 / 72.0

        $closestSize = $null
        $closestDistance = [double]::PositiveInfinity

        foreach ($size in $pageSizes.Keys) {
            $reference = $pageSizes[$size]
            foreach ($dimensions in @(@($reference[0], $reference[1]), @($reference[1], $reference[0]))) {
                $wDiff = [math]::Abs($widthMm - $dimensions[0])
                $hDiff = [math]::Abs($heightMm - $dimensions[1])

                # Only accept the intended ISO size, not an arbitrary nearest match.
                if (($wDiff -le $ToleranceMm) -and ($hDiff -le $ToleranceMm)) {
                    $distance = [math]::Sqrt($wDiff * $wDiff + $hDiff * $hDiff)
                    if ($distance -lt $closestDistance) {
                        $closestDistance = $distance
                        $closestSize = $size
                    }
                }
            }
        }

        if ($null -eq $closestSize) {
            Write-Host ("SKIP (nonstandard size {0:N1} x {1:N1} mm): {2}" -f $widthMm, $heightMm, $pdfFile.Name)
            $skipped++
            continue
        }

        $newFileName = '{0}-{1}.pdf' -f $pdfFile.BaseName, $closestSize.ToLowerInvariant()
        $newFilePath = Join-Path -Path $pdfFile.DirectoryName -ChildPath $newFileName

        if (Test-Path -LiteralPath $newFilePath) {
            Write-Warning "Destination already exists, skipping: $newFileName"
            $skipped++
            continue
        }

        if ($PSCmdlet.ShouldProcess($pdfFile.FullName, "Rename to $newFileName")) {
            Rename-Item -LiteralPath $pdfFile.FullName -NewName $newFileName -ErrorAction Stop
            Write-Host "RENAMED: $($pdfFile.Name) -> $newFileName"
            $renamed++
        }
        elseif ($WhatIfPreference) {
            $planned++
        }
        else {
            $skipped++
        }
    }
    catch {
        Write-Warning "ERROR: $($pdfFile.Name): $($_.Exception.Message)"
        $errors++
    }
}

Write-Host "Completed. Scanned: $scanned; Renamed: $renamed; Previewed: $planned; Skipped: $skipped; Errors: $errors"
