# Mini powershell projects

Powershell is outstanding for Win11 automation. I ignored it for too long. Although none of this is complex, the easy automation with right-click folder options is satisfying.

## Installation

I keep these files in a `c:\bin\` folder, a nod to unix/linux. And that path is in my `Path` environment variable (system is my preference).

For trouble-free scripting, ensure that dependencies are in your `Path` environment variable.

Oh, yeah - and don't forget powershell ; )

-----
### CNV_HEIC2JPG

After I transfer HEIC photos from iOS to my Win11 laptop, I convert to JPG and then transfer only select photos back to my devices. I avoid Apple cloud backup, as I avoid all cloud backup. I prefer self-sufficiency, like backup and disaster recovery, and the inherent privacy.

#### What the script does:
+ From selected folder, scan recursively for HEIC files
+ Convert each to JPG in the same folder
+ Move HEIC files to a parallel `.HEIC_backup` folder
+ Leave a log file in the original folder, alongside the new JPGs.

#### Dependency
+ Requires local installation of gold-standard [ImageMagick](https://imagemagick.org/).

#### Assets:
+ [cnv_heic2jpg.ico](cnv_heic2jpg.ico), see [icon_attribution.md](icon_attribution.md).
+ [cnv_heic2jpg.reg](cnv_heic2jpg.reg), to register the right-click folder option in the Win11 registry
  + You can use the same command manually, from a terminal window
+ [cnv_heic2jpg.ps1](cnv_heic2jpg.ps1), the powershell script

-----
### EPUBCHECK_FILES

[The Gutenberg Project](https://www.gutenberg.org/) is an essential cultural project, although all of these epub files benefit from some custom effort, ranging from tweaking to extensive refactoring.
+ [Calibre](https://calibre-ebook.com/) is essential and makes epub edits easy. At least as easy as they're gonna be.

#### What the script does:
+ From selected folder, scan recursively for EPUB files
+ Check validity of each, fail also on WARNING
+ Write a log file in a parallel `.epubcheck` folder

#### Dependencies
+ [Java](https://www.java.com/download/)
+ [EpubCheck java](https://www.w3.org/publishing/epubcheck/) installation is the gold-standard for validating .epub books.

#### Assets:
+ [epubcheck_files.ico](epubcheck_files.ico), see [icon_attribution.md](icon_attribution.md).
+ [epubcheck_files.reg](epubcheck_files.reg), to register the right-click folder option in the Win11 registry
  + You can use the same command manually, from a terminal window
+ [epubcheck_files.ps1](epubcheck_files.ps1), the powershell script

-----
### GET_VIDEO_SUBTITLES

I like to subtitles my photo montages (videos), since that is more informative than memory : ) I containerize the videos and subtitles as MKV files. Then later I realize I want easy access to those logs of montage content. This script extracts them for all MKV files, recursively, in a folder.

#### What the script does:
+ From selected folder, scan recursively for MKV files
+ Use [MKVToolNix](https://mkvtoolnix.download/downloads.html#windows) to check for subtitle tracks
+ Extract and rename each subtitle track to match the name of the video
+ Log steps to `video_subtitles.log`

#### Dependencies
+ [MKVToolNix](https://mkvtoolnix.download/downloads.html#windows)

#### Assets:
+ [get_video_subtitles.ico](get_video_subtitles.ico), see [icon_attribution.md](icon_attribution.md).
+ [get_video_subtitles.reg](get_video_subtitles.reg), to register the right-click folder option in the Win11 registry
  + You can use the same command manually, from a terminal window
+ [get_video_subtitles.ps1](get_video_subtitles.ps1), the powershell script

-----
### HASH2CSV

[Windows Spotlight Images](https://windows10spotlight.com/) publishes beautiful landscape and portrait desktop images, suitable for any device. This script retrieves image metadata based on the SHA256 hash of each (alphanumerically-named) image that I previously downloaded to a folder.

#### What the script does:
+ From selected folder, scan recursively for each file (not only images)
+ Calculate SHA256 hash for each
+ Search [Windows Spotlight Images](https://windows10spotlight.com/) for that hash
+ Retrieve metadata for each file, if available
+ Write out a CSV that makes it easy to rename each (alphanumerically-named) image to something meaningful

#### Dependencies
+ `-none-` unless you count Powershell

#### Assets:
+ [hash2csv.ico](hash2csv.ico), see [icon_attribution.md](icon_attribution.md).
+ [hash2csv.reg](hash2csv.reg), to register the right-click folder option in the Win11 registry
  + You can use the same command manually, from a terminal window
+ [hash2csv.ps1](hash2csv.ps1), the powershell script

-----
### WALLPAPER-INFO

You know that wallpaper picture that rotates onto your desktop? What is that?! Now you can right-click and choose "ℹ️ Learn About Picture"

#### What the script does:
+ Checks Win11 registry and files to find that wallpaper picture (which Windows may Transcoded ... for speed? for obfuscation? who knows)
+ Open a dialog for permission to
  1. Copy path to your clipboard
  1. Open the image location
+ which it will do, if you simply reply "Yes"

#### Dependencies
+ `-none-` unless you count Powershell

#### Assets:
+ [wallpaper-info.reg](wallpaper-info.reg), to register the right-click folder option in the Win11 registry
+ [wallpaper-info-remove.reg](wallpaper-info-remove.reg), to DE-register the right-click folder option in the Win11 registry, so you can try something else
  + You can use the same command manually, from a terminal window
+ [wallpaper-info.ps1](wallpaper-info.ps1), the powershell script

-----
-----
### next one

What this is 

#### What the script does:
+ if anything

#### Dependencies
+ if any

#### Assets:
+ [nextone.ico](nextone.ico), see [icon_attribution.md](icon_attribution.md).
+ [nextone.reg](nextone.reg), to register the right-click folder option in the Win11 registry
  + You can use the same command manually, from a terminal window
+ [nextone.ps1](nextone.ps1), the powershell script

-----
-----
### Icon attribution

I greatly appreciate sites like [Flaticon.com](https://www.flaticon.com/) for my periodic icon needs. So far, I can always find a suitable, aethetically pleasing icon there. See [icon_attribution.md](icon_attribution.md) for details.