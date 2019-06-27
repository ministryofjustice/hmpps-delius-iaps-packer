$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    Write-Host('Extracting sqldeveloper tools')
    Start-Process $env:ProgramFiles\7-Zip\7z.exe 'x -oC:\ "C:\Setup\Source Files\sqldeveloper-4.1.3.20.78-x64.7z"' -Wait -Verb RunAs
    $sqldeveloperfile = 'C:\sqldeveloper-4.1.3.20.78-x64\sqldeveloper\sqldeveloper.exe'
    if (Test-Path -Path $sqldeveloperfile) {
        Write-Host('Creating shortcut for all users')
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\SQLDeveloper.lnk")
        $Shortcut.TargetPath = $sqldeveloperfile
        $Shortcut.Save()
    } else {
        write-host('Error - Failed to find sqldeveloper.exe after extraction: $sqldeveloperfile')
        exit 1
    }
}
catch [Exception]{
    Write-Host('Error extratcing sqldeveloper package')
    echo $_.Exception|format-list -force
    exit 1
}