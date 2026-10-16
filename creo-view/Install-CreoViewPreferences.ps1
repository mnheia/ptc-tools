<#
.SYNOPSIS
    Copy a Creo View preference file into the current user's profile.

.NOTES
    Author: mnheia
    Copyright: (c) 2026 mnheia
    Repository: https://github.com/mnheia/ptc-tools
    License: GPL-3.0 (see LICENSE)
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Source,
    [string]$DestinationDirectory = (Join-Path $env:APPDATA 'ptc\ProductView')
)
$destination = Join-Path $DestinationDirectory 'user_prefs.xml'
if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "Missing preferences: $Source" }
if ($PSCmdlet.ShouldProcess($destination, "Install $Source")) {
    New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null
    if (Test-Path -LiteralPath $destination) {
        Copy-Item -LiteralPath $destination -Destination "$destination.bak.$(Get-Date -Format yyyyMMddHHmmss)"
    }
    Copy-Item -LiteralPath $Source -Destination $destination -Force -ErrorAction Stop
}
