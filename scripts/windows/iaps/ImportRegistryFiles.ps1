$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {
   
    $path = 'C:\\Setup\\Registry'
    
    Write-Output '-----------------------------------'
    Write-Output "path: $path"
    Write-Output '-----------------------------------'

    Get-ChildItem $path -Filter *.reg | % {
        Write-Output "Importing registry file $($_.FullName)"
        Start-Process regedit -ArgumentList "/s `"$($_.FullName)`"" -Wait
    }
   
}
catch [Exception] {
    Write-Host ('Failed importing User Registry Keys for Region')
    echo $_.Exception|format-list -force
    exit 1
}
