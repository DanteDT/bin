# Wallpaper Info Script
# This script retrieves the current wallpaper information and displays it in a message box. It also offers the option to copy the wallpaper path to the clipboard and open the folder containing the wallpaper.
# Run from desktop context menu, "Learn About Picture"
# Handle Transcoded Wallpaper Paths

Add-Type -AssemblyName PresentationFramework;

$path = (Get-ItemProperty -Path 'HKCU:\\Control Panel\\Desktop').Wallpaper;

if (!$path) { $path = (Get-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Wallpapers').BackgroundHistoryPath0 };

# Handle Transcoded Wallpaper Paths like 
# C:\Users\Dante\AppData\Roaming\Microsoft\Windows\Themes\Transcoded_000
# and
# C:\Users\Dante\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper
if ($path -match 'Transcoded') { $path = (Get-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Wallpapers').BackgroundHistoryPath0 };

$name = Split-Path $path -Leaf;
    
$msg = 'Current Wallpaper: ' + $name + [char]13 + [char]10 + [char]13 + [char]10 + 'Location: ' + $path + [char]13 + [char]10 + [char]13 + [char]10 + 'Open folder and copy path?';
    
$result = [System.Windows.MessageBox]::Show($msg, 'Wallpaper Info', 'YesNo', 'Information');

# If the user clicks "Yes", 
#   copy the path to the clipboard 
#   and open the folder containing the wallpaper
if ($result -eq 'Yes') {
    Set-Clipboard -Value $path;
    Start-Process -FilePath (Split-Path $path -Parent);
}
