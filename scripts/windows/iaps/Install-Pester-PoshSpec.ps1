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

    $DirectoryToCreate = 'C:\Setup\Testing'
    if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
        try {
            New-Item -Path DirectoryToCreate -ItemType 'directory' | Out-Null #-Force
        }
        catch {
            Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
        }
        "Successfully created directory '$DirectoryToCreate'."
    }
    else {
        "Directory $DirectoryToCreate already existed"
    }
        
    write-output '-----------------------------------'
    write-output 'Extracting PoshSpec'
    write-output '-----------------------------------'
    Start-Process $env:ProgramFiles\7-Zip\7z.exe "x -o$(DirectoryToCreate) $outfile" -Wait -Verb RunAs
}
catch [Exception] {
    Write-Host ('Failed to extract PoshSpec client setup using 7z')
    echo $_.Exception|format-list -force
    exit 1
}
