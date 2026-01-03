# For selected folder, 
# move HEIC files to ../.HEIC_backup/<folder>/<file>.HEIC
# - create folders as needed
# - skip rather than overwriting destination file
# for each moved HEIC ../.HEIC_backup/<folder>/<file>.HEIC
# - convert to JPEG file <folder>.jpg
# - lowercase jpg extension
# Write log file <folder>/conversion <date>.log

param(
    [string]$FolderPath,
    [double]$ImageQuality = 0.95
)

# Convert 0–1 to 0–100 for ImageMagick
$quality = [math]::Round($ImageQuality * 100)

# Subfolder for originals and log is ../.HEIC_backup/
$heicBase = Split-Path -Path $FolderPath -Parent
$heicLeaf = Split-Path -Path $FolderPath -Leaf
$heicFolder = Join-Path $heicBase ".HEIC_backup" 
$heicFolder = Join-Path $heicFolder $heicLeaf

if (-not (Test-Path $heicFolder)) { New-Item -Path $heicFolder -ItemType Directory | Out-Null }
$logFile = Join-Path $heicFolder "conversion $(get-date -f yyyy-MM-dd).log"

Write-Output "Log file: $logFile"

# Helper to write to console and log
function Log {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $logFile -Value $Message -Encoding UTF8
}

# Process HEIC files
Get-ChildItem -Path $FolderPath -Filter *.heic -File | ForEach-Object {
    $jpgPath = [System.IO.Path]::ChangeExtension($_.FullName, ".jpg")

    if (Test-Path $jpgPath) {
        Log "Skipping $($_.Name) because JPG already exists."
        return
    }

    try {
        # Run ImageMagick as a process
        $procArgs = "`"$($_.FullName)`" -quality $quality `"$jpgPath`""
        $proc = Start-Process magick -ArgumentList $procArgs -Wait -PassThru -WindowStyle Minimized

        # Check exit code and that JPG exists
        if ($proc.ExitCode -eq 0 -and (Test-Path $jpgPath)) {
            Move-Item -Path $_.FullName -Destination $heicFolder
            Log "Converted and moved $($_.Name)."
        } else {
            Log "Conversion FAILED for $($_.Name). HEIC not moved."
        }

    } catch {
        Log "Exception converting $($_.Name): $_"
    }
}
