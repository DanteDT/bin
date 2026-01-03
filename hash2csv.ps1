param(
    [string[]]$FolderPaths
)

$rurl = "https://windows10spotlight.com/search"

# Helper function to compute hashes and add to table
# Helper function to retrieve Search URL information
function Get-UrlPage {
    param([string]$Url)
    
    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0"
        "Accept-Language" = "en-US,en;q=0.9"
    }
    
    try {
        return Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing
    }
    catch {
        Write-Host "Failed to fetch $Url => $($_.Exception.Message)"
        return $null
    }
}

# Parse title directly from HTML **first** <div id="postid-\d+" ...> section
# First try to get from <a ... title="Title of Photo">Title of Photo</a>
# Example HTML structures:
# <div id="postid-\d+" ...>
#   <h2>
#     <a href="https://windows10spotlight.com/images/\d+" title="Title of Photo">
#     Title of Photo
#     </a>
#   </h2>
#   ...
#   </div>
# </div>
# Otherwise if title attribute is alphanumeric (no spaces), then fallback to the caption after the <img ...> like:
# <div id="postid-\d+">
#   <h2>
#     <a href="https://windows10spotlight.com/images/\d+" title="::alphanum::">
#     ::alphanum::
#     </a>
#   </h2>
#   <div class="entry clearfix">
#     <a href="https://windows10spotlight.com/images/\d+">
#     <img ...>
#     </a>
#      Title of Photo
#      ::after
#   ...
#   </div>
# </div>

function Get-SpotlightTitleFromHtml {
    param([string]$Html)
    
    if (-not $Html) { return $null }
    
    if ($Html -match '<h2[^>]*>.*?title="([^"]*?)"') {
        $title = $matches[1].Trim()

        # If first H2 Title is alphanumeric only, try to get caption after <img ...>
        if ($title -match '^[a-zA-Z0-9]+$') {
            # If alphanumeric, no spaces, try to get caption after <img ...>
            if ($Html -match '<img[^>]*/>[\s\r\n]*</a>[\s\r\n]*([^<\r\n]+)[\s\r\n]*</div>') {
                $title = $matches[1].Trim()
            }
        }

        return $title
    }

    return $null
}

#
function Get-ImageHashInfo {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    # SHA256 is as reliable as any
    $hash = Get-FileHash -Algorithm SHA256 -Path $Path
    $surl = "$rurl/$($hash.Hash)"
    $info = Get-UrlPage $surl

    $titl = $info.Links | Where-Object title | Select-Object -ExpandProperty title -ErrorAction Ignore
    Write-Host "WSI title, first: $titl ."

    $ttl2 = $null
    if ($info) {
        $ttl2 = Get-SpotlightTitleFromHtml $info.Content
    }    
    Write-Host "WSI title, alt: $ttl2 ."

    return [PSCustomObject]@{
        FullName    = $Path
        Name        = Split-Path $Path -Leaf
        Length      = (Get-Item $Path).Length

        sha256      = $hash.Hash
        sha256_link = "=HYPERLINK(CONCATENATE(""$rurl/"", D2, """"""""),""sha256"")"
        wsi_title   = $titl
        wsi_alttitle= $ttl2
        rename      = "=CONCATENATE(""rename """""", B2, """""" """""", G2, "" - Windows Spotlight.jpg"""""")"

        # SHA256 is as reliable as any
        #sha1        = $sha1.Hash
        #md5         = $md5.Hash
        #sha1_link   = "=HYPERLINK(""https://windows10spotlight.com/search/$($sha1.Hash)"",""sha1"")"
        #md5_link    = "=HYPERLINK(""https://windows10spotlight.com/search/$($md5.Hash)"",""md5"")"
    }
}

# Collect all files
$paths = foreach ($folder in $FolderPaths) {
    Get-ChildItem -Path $folder -Recurse -File | Select-Object -ExpandProperty FullName
}

# Process each file
$allFiles = $paths | ForEach-Object { Get-ImageHashInfo -Path $_ }

# Write out CSV
$logFile = Join-Path $FolderPaths[0] "calculated_hashes.csv"
$allFiles | Export-Csv -Path $logFile -NoTypeInformation -Encoding UTF8
Write-Host "Saved: $logFile"
