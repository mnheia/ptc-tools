# Clean Creo Publisher worker logs and optional caches after the worker is stopped.
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$WorkerDirectory,
    [Parameter(Mandatory)][string]$ThumbnailDirectory,
    [string]$CacheDirectory,
    [string]$TempDirectory,
    [switch]$Execute
)
# Do not terminate Creo processes automatically: the administrator should stop the worker first.
if (Get-Process xtop,pvsthumb -ErrorAction SilentlyContinue) {
    throw 'Stop Creo Publisher and thumbnail processes before cleaning.'
}
$folders = @{
    $WorkerDirectory = @('publish_*.log','monitor_*.log','helper_*.log','worker_*.log',
                         'trail.txt.*','std.out','std.err','exit.trl','*.log.*','*.crc.*','*.lst.*')
    $ThumbnailDirectory = @('batch_*.log','monitor_*.log','helper_*.log','worker_*.log')
}
$items = foreach ($path in $folders.Keys) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Missing folder: $path" }
    foreach ($pattern in $folders[$path]) {
        Get-ChildItem -LiteralPath $path -File -Filter $pattern -ErrorAction Stop
    }
}
# Cache/temp cleaning is restricted to contents of explicitly supplied directories.
foreach ($path in @($CacheDirectory,$TempDirectory) | Where-Object { $_ }) {
    $full = (Resolve-Path -LiteralPath $path -ErrorAction Stop).ProviderPath.TrimEnd('\')
    if ($full -match '^[A-Za-z]:$' -or $full -match '^[A-Za-z]:\\Windows$') {
        throw "Unsafe cache/temp directory: $full"
    }
    $items += Get-ChildItem -LiteralPath $full -Force -ErrorAction Stop
}
$items = $items | Sort-Object FullName -Unique
foreach ($item in $items) {
    if (-not $Execute) { Write-Host "Would delete: $($item.FullName)"; continue }
    if ($PSCmdlet.ShouldProcess($item.FullName, 'Remove publisher file')) {
        Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
    }
}
