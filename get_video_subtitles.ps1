# Usage
# powershell -NoProfile -ExecutionPolicy Bypass -File "<script-path>" "<mkv-path>"

param(
    [string]$FolderPath
)

# Log file
$logFile = Join-Path $FolderPath "video_subtitles.log"

Write-Output "Usage, powershell -NoProfile -ExecutionPolicy Bypass -File <script-path> <mkv-path>"

function Log {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $logFile -Value $Message
}

# Recursively find mkv files
Get-ChildItem -Path $FolderPath -Filter *.mkv -File -Recurse | ForEach-Object {

    $mkv = $_.FullName
    $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $folder = $_.DirectoryName

    Log "Processing: $mkv"

    try {
        # Ask mkvmerge for track info (cleaner than mkvinfo)
        $tracks = & mkvmerge -i $mkv 2>&1

        # Find subtitle track lines
        # Example line: "Track ID 3: subtitles (SubRip/SRT)"
        $subtitleLines = $tracks | Select-String "subtitles"

        if (-not $subtitleLines) {
            Log "  No subtitle tracks found: $mkv"
            return
        }

        foreach ($line in $subtitleLines) {

            # Extract track ID number
            if ($line -match "Track ID (\d+):") {
                $trackID = $matches[1]

                # Detect multiple subtitle tracks so naming is correct
                $multi = ($subtitleLines.Count -gt 1)

                $before = Get-ChildItem $folder
                $trackFile = Join-Path $folder "subtitle${trackID}"

                Log "  Trying ""$mkv"", extract track ""$trackID"" to ""$trackFile"""
                Log "  >> Constructed from: mkv ""$mkv"", base ""$base"", line ""$line"",`n     :: trackID ""$trackID"", trackFile ""$trackFile"""

            & mkvextract tracks $mkv "${trackID}:${trackFile}" 2>&1

                $after = Get-ChildItem $folder

                $newFile = Compare-Object $before $after |
                           Where-Object { $_.SideIndicator -eq "=>" } |
                           Select-Object -ExpandProperty InputObject

                if ($newFile) {
                  foreach ($fn in $newFile) {
                    $ext = $fn.Extension

                    if (-not $ext) {
                      $ext = ".srt"
                      Log "  >> forcing subtitle-file extension to ""$ext"""
                    }

                    # Subtitle re-naming logic:
                    # - One subtitle: filename.ext
                    # - Multiple → filename.trackID.ext
                    if ($multi) {
                        $target = Join-Path $folder "${base}${trackID}${ext}"
                    } else {
                    $target = Join-Path $folder "${base}${ext}"
                    }

                    Log "  Renaming: base ""$base"", fn.FullName ""$($fn.FullName)"" to target ""$target"""
                    Log "  >> Constructed from: base ""$base"", fn ""$fn"", trackID ""$trackID"", ext ""$ext"""

                    Rename-Item -Path $fn.FullName -NewName $target -Force
                  }
                Log "  Extracted: ${target}"
                } else {
                Log "  ERROR: mkvextract didn’t create a detectable file for track ${trackID}, from ${base}.mkv"
                }
            }
        }

    } catch {
        Log "  Exception: $_"
    }
}
