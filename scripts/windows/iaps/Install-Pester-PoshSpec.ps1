$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {

    write-output '-----------------------------------'
    write-output 'Intalling Pester BDD'
    write-output '-----------------------------------'
    choco install pester -y --force
    dir 'C:\ProgramData\chocolatey\lib\pester\tools'

    write-output '-----------------------------------'
    write-output 'Downloading PoshSpec 2.1.16'
    write-output '-----------------------------------'
    $uri='https://github.com/ticketmaster/poshspec/releases/download/v2.1.16/poshspec.zip'
    $outfile = 'c:\setup\poshspec.zip'
    Invoke-WebRequest -Uri $uri -OutFile $outfile
    dir $outfile

    write-output '-----------------------------------'
    write-output 'Extracting PoshSpec'
    write-output '-----------------------------------'
    New-Item -Path 'C:\Setup\' -Name 'Testing' -ItemType 'directory'
    Start-Process $env:ProgramFiles\7-Zip\7z.exe "x -oC:\Setup\Testing $outfile" -Wait -Verb RunAs
}
catch [Exception] {
    Write-Host ('Failed to extract PoshSpec client setup using 7z')
    echo $_.Exception|format-list -force
    exit 1
}
