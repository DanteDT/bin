# Get the Windows short pathname (8.3 format) for a given path
# Command-line Usage: pwsh.exe -File "c:\bin\get_shortpath.ps1" [path]
# If no path is provided, uses the current directory
# Call from another script as:
#   & "c:\bin\get_shortpath.ps1" [path]
# Example to get short path for Program Files:
#   $shortPath = & "c:\bin\get_shortpath.ps1" "C:\Program Files"
#
param([string]$Path = $PWD.Path)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class ShortPath {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
    public static extern int GetShortPathName(
        [MarshalAs(UnmanagedType.LPTStr)] string path,
        [MarshalAs(UnmanagedType.LPTStr)] StringBuilder shortPath,
        int shortPathLength
    );
}
"@

$sb = New-Object System.Text.StringBuilder 260
[ShortPath]::GetShortPathName($Path, $sb, 260) | Out-Null
$sb.ToString()