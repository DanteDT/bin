# For selected folder, 
# EpubCheck each .epub file, recursively
# Write results to "../.epubcheck/<filename> (epc).xml"

param(
    [string]$FolderPath
)

# Always start with fully qualified path
$FolderPath = (Get-Item -LiteralPath $FolderPath).FullName

# Subfolder for originals and log is ../.epubcheck/
$epubBase = Split-Path -Path $FolderPath -Parent
#$epubLeaf = Split-Path -Path $FolderPath -Leaf
$epubFolder = Join-Path $epubBase ".epubcheck"
$logFile = Join-Path $epubFolder "epubcheck $(get-date -f yyyy-MM-dd).log"

if (-not (Test-Path $epubFolder)) { New-Item -Path $epubFolder -ItemType Directory | Out-Null }

# Helper to write to console and log
function Log {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $logFile -Value $Message -Encoding UTF8
}

# Process epub files
# -LiteralPath to avoid wildcards in Get-ChildItem to prevent issues with special characters
Get-ChildItem -LiteralPath $FolderPath -Recurse -Filter *.epub -File | ForEach-Object {
    # Avoid wild-card expansion.
    $quotedName = "`"$($_.Name)`""

    $xmlPath = [System.IO.Path]::ChangeExtension($_.FullName, "(epc).xml")
    $xmlPath = Split-Path -Path $xmlPath -Leaf
    $xmlPath = Join-Path $epubFolder $xmlPath

    Write-Output "EpubChecking $quotedName, reporting to $xmlPath ."
    
    try {
        # Do not expand wild-cards in Test-Path
        if (Test-Path -LiteralPath $xmlPath) {
            Log "Skipping $quotedName because `"$xmlPath`" already exists."
            return
        }
    } catch {
        Log "Error checking existence of `"$xmlPath`": $_"
    }

    try {
        # Run EpubCheck as a process
        $procArgs = "-jar `"c:\bin\epubcheck\epubcheck.jar`" --warn --failonwarnings `"$($_.FullName)`" --out `"$xmlPath`""
        $proc = Start-Process java $procArgs -Wait -PassThru -WindowStyle Minimized

        # Check exit code and that XML output exists.
        if ($proc.ExitCode -eq 0 -and (Test-Path -LiteralPath $xmlPath)) {
            Log ":: SUCCESS :: EpubCheck of $quotedName.`n"
        } else {
            Log ":: FAIL :: EpubCheck errors ($($proc.ExitCode)) for $quotedName. See `"$xmlPath`".`n"
        }

    } catch {
        Log "Exception checking $quotedName : $_"
    }
}
