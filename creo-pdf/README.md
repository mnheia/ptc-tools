# Creo PDF Size Renamer

Windows PowerShell script for adding A0-A4 paper-size suffixes to PDF filenames. Created for Creo drawing exports, but usable with any PDF.

Examples:

| Original file | Renamed file |
| --- | --- |
| `Drawing_001.pdf` (A3 portrait) | `Drawing_001-a3.pdf` |
| `Assembly.pdf` (A1 landscape) | `Assembly-a1.pdf` |
| `Drawing_002.pdf` (A4 portrait) | `Drawing_002-a4.pdf` |

The PDF itself is not modified. Only the **first page's** dimensions are inspected.

## Requirements

- Windows PowerShell 5.1 (the included batch launcher) or PowerShell 7 on Windows (direct invocation).
- `pdfinfo.exe` from a compatible Poppler or Xpdf Windows distribution.
- A directory containing PDF files (default: `C:\Creo PDF`).

`pdfinfo.exe` is a **separate third-party dependency**, not bundled with this repository. Obtain a compatible distribution from its publisher. You may need to retain associated DLLs.

The script looks for `pdfinfo.exe` in this order:
1. Path provided using `-PdfInfoPath`.
2. In the same directory as the PowerShell script.
3. On the system `PATH`.

## Run

Create the input directory if it does not already exist.

Double-click `CreoPDFSaveAsSize.bat` to use the default folder, or use PowerShell:

```powershell
# Preview without renaming files
.\CreoPDFSaveAsSize.ps1 -PdfDir 'C:\Creo PDF' -WhatIf

# Process another directory
.\CreoPDFSaveAsSize.ps1 -PdfDir 'D:\Drawings'

# Specify the pdfinfo executable
.\CreoPDFSaveAsSize.ps1 -PdfDir 'D:\Drawings' -PdfInfoPath 'D:\Poppler\bin\pdfinfo.exe'

# Adjust paper-size tolerance in mm
.\CreoPDFSaveAsSize.ps1 -PdfDir 'D:\Drawings' -ToleranceMm 5
```

Arguments can also be forwarded through the batch file:

```cmd
CreoPDFSaveAsSize.bat -PdfDir "D:\Drawings" -WhatIf
```

The batch file sets execution policy to `Bypass` for **that PowerShell process only**, not persistently.

## Behaviour

- Scans the selected directory for `*.pdf` (no subdirectories).
- Uses `pdfinfo -box` to read the first page's width and height.
- Converts PDF points to millimetres.
- Recognises A0, A1, A2, A3 and A4 in portrait and landscape.
- Accepts a maximum deviation of 3 mm **per dimension** by default; skips other sizes.
- Appends a lowercase size suffix (`-a0` through `-a4`).
- Skips files already ending with a size suffix and does not overwrite destination files.
- Handles individual-file errors without stopping the batch.
- Supports `-WhatIf` and `-Confirm`.

This is a PDF **filename** utility, not a PDF conversion, merging or printing solution.


## License

GPL-3.0, see the repository's root `LICENSE`. `pdfinfo.exe` is not included and has its own applicable terms.
