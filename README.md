Copyright (c) 2026, mnheia

# ptc-tools

Simple Windows PowerShell utilities for PTC Creo and Windchill environments.

## Scripts

### `creo-publisher/Clear-CreoPublisherFiles.ps1`

Find and optionally remove Creo Publisher worker and thumbnail logs, plus cache and temp contents when specified. It refuses to clean while `xtop.exe` or `pvsthumb.exe` is running. Files are only deleted with `-Execute`.

```powershell
.\creo-publisher\Clear-CreoPublisherFiles.ps1 -WorkerDirectory 'D:\ptc\worker' -ThumbnailDirectory 'D:\ptc\thumbnail'
.\creo-publisher\Clear-CreoPublisherFiles.ps1 -WorkerDirectory 'D:\ptc\worker' -ThumbnailDirectory 'D:\ptc\thumbnail' -Execute -WhatIf
```

### `creo-view/Install-CreoViewPreferences.ps1`

Install a user-supplied Creo View `user_prefs.xml` with a backup of any existing file.

```powershell
.\creo-view\Install-CreoViewPreferences.ps1 -Source '.\user_prefs.xml' -WhatIf
```

### `creo-pdf/CreoPDFSaveAsSize.ps1`

Detect the first page size of exported PDF drawings and add an ISO A0-A4 suffix to the filename. Supports portrait and landscape pages, filename-conflict protection, size tolerance, and `-WhatIf` preview. Requires an external `pdfinfo.exe`.

```powershell
.\creo-pdf\CreoPDFSaveAsSize.ps1 -PdfDir 'C:\Creo PDF' -WhatIf
.\creo-pdf\CreoPDFSaveAsSize.ps1 -PdfDir 'C:\Creo PDF'
```

See [creo-pdf/README.md](creo-pdf/README.md) for setup instructions.

## Bugs

Please report issues at https://github.com/mnheia/ptc-tools/issues

## License

GPL-3.0; see `LICENSE`.
