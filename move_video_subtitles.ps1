# Usage
# powershell -NoProfile -ExecutionPolicy Bypass -File "<script-path>" "<mkv-path>"

param(
    [string]$FolderPath
)

# Use full paths
$FolderPath = (Resolve-Path $FolderPath).Path

# Log file
$logFile = Join-Path $FolderPath "video_subtitles.log"

Write-Output "Usage, powershell -NoProfile -ExecutionPolicy Bypass -File <script-path> <mkv-path>"

function Log {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $logFile -Value $Message
}

# Clear log file at start
if (Test-Path $logFile) {
    Clear-Content -Path $logFile
}

# If subtitles subfolder does not exist, create it
$subFolder = Join-Path $FolderPath "subtitles"
if (-not (Test-Path $subFolder)) {
    New-Item -ItemType Directory -Path $subFolder
}

# Get the list of subtitles files before extraction to detect new files
$before = Get-ChildItem $subFolder

# Recursively find mkv files
Get-ChildItem -Path $FolderPath -Filter *.mkv -File -Recurse | ForEach-Object {

    $mkv = $_.FullName
    $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    Log "Processing: $mkv"
    Log "  Folder path: $FolderPath"
    Log "  Extracting subtitles to: ""$subFolder"""

    try {
        # Ask mkvmerge for track info (cleaner than mkvinfo)
        $tracks = & mkvmerge -i $mkv 2>&1

        # Find subtitle track lines
        # Example line: "Track ID 3: subtitles (SubRip/SRT)"
        $subtitleLines = $tracks | Select-String "subtitles"

        # Detect multiple subtitle tracks so naming is correct, store subtitles in the subtitles subfolder
        $multi = (@($subtitleLines).Count -gt 1)

        # Report if no subtitle tracks found
        if (-not $subtitleLines) {
            Log "  No subtitle tracks found: $mkv"
            return
        }
        else {
            Log "  Found subtitle tracks: $($subtitleLines.Count)"
        }

        foreach ($line in $subtitleLines) {

            # Extract track ID number
            if ($line -match "Track ID (\d+):") {
                $trackID = $matches[1]

                Log "  Line: ""$line"", for subtitle Track ID $trackID"

                if ($multi) {
                    $trackFile = Join-Path $subfolder "${base}_${trackID}"
                } else {
                $trackFile = Join-Path $subfolder "${base}"
                }

                Log "  Extract ""$mkv"" track ""$trackID"" to ""$trackFile"""

                & mkvextract tracks $mkv "${trackID}:${trackFile}" 2>&1
            }
        }

        # Now get the list of subtitles files after extraction to detect new files
        $after = Get-ChildItem $subFolder

        Log " Before extraction: $($before.Count) files, After extraction: $($after.Count) files"

        # avoid error: "Compare-Object : Cannot bind argument to parameter 'ReferenceObject' because it is null."
        if (-not $before) {
            $before = @()
        } else {
            Log " Before: $($before | ForEach-Object { $_.Name })"
        }

        if (-not $after) {
            $after = @()
        } else {
            Log " After: $($after | ForEach-Object { $_.Name })"
        }

        $newFile = Compare-Object $before $after |
                   Where-Object { $_.SideIndicator -eq "=>" } |
                   Select-Object -ExpandProperty InputObject

        if ($newFile) {
            foreach ($fn in $newFile) {
                $ext = $fn.Extension

                Log "  New suttitles extracted: ""$($fn.FullName)"""

                if (-not $ext){
                    $target = Join-Path $subFolder "$($fn.Name).srt"
                    Log "  >> Renaming to force .srt extension: ""$fn"" to ""$target"""

                    # Rename using fully path to avoid issues.
                    if (Test-Path $target) {
                        Log "  >> Target file already exists, skipping rename: ""$target"""
                    } else {
                        Rename-Item -Path $fn.FullName -NewName $target -Force
                    }
                }
                else {
                    $target = $fn.FullName
                }
            }
        } else {
            Log "  No subtitles extracted: mkvextract didn't create a detectable file for track ${trackID}, from ${base}.mkv"
        }

    } catch {
        Log "  Exception: $_"
    }

    try {
        # If some subtitles tracks were extracted, replace original MKV with subtitle-free version.
        if ($subtitleLines) {
            $output = Join-Path $FolderPath "${base}.nosubs.mkv"
            Log "  Creating new MKV without subtitles: ${output}"
            & mkvmerge -o $output --no-subtitles $mkv 2>&1

            # Check that the new MKV was created successfully and NEW/ORIG size ratio is >0.95 to avoid replacing with a broken file
            $originalSize = (Get-Item $mkv).Length
            $newSize = (Get-Item $output).Length
            $sizeRatio = $newSize / $originalSize

            Log "  Original MKV size: $originalSize bytes, New MKV size: $newSize bytes, Size ratio: $sizeRatio"

            if (Test-Path $output) {

                if ($sizeRatio -lt 9.6) {
                    Remove-Item -Path $mkv -Force
                    Rename-Item -Path $output -NewName $_.Name -Force
                    Log "  Replaced original MKV with new one without subtitles: ${mkv}"
                } else {
                    Log "  WARNING: New MKV size is only ${sizeRatio} size of original. Keeping original: ${mkv}"
                }
            } else {
                Log "  ERROR: Failed to create new MKV without subtitles for ${mkv}"
            }
        }
    } catch {
        Log "  Exception during MKV replacement: $_"
    }
}
