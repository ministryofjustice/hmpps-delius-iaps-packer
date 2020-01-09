$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    ###############################################################
    # Run Installer to install NDelius Interface
    ###############################################################
    Write-Host('Installing NDelius Interface Package')
    Start-Process -Wait -FilePath "C:\Setup\NDelius Interface\latest\setup.exe" -ArgumentList "/quiet /qn" -Verb RunAs

    ###############################################################
    # Remove invalid shortcut
    ###############################################################
    Write-Host('Remove invalid shortcut')
    Remove-Item -Path "C:\Users\Public\Desktop\Migration Utility (Iaps-NDelius IF).lnk"

    Write-Host('Grant local Users group full access recursively to I2N program dir')
    $i2npath = "C:\Program Files (x86)\I2N"
    $acl = (Get-Item $i2npath).GetAccessControl('Access')
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $i2npath $acl

    Write-Host('Remove invalid shortcut')
    if ( Test-Path "C:\Users\Public\Desktop\Migration Utility (Iaps-NDelius IF).lnk") {
        Remove-Item -Path "C:\Users\Public\Desktop\Migration Utility (Iaps-NDelius IF).lnk"
    }
        
    Write-Host('Creating new shortcut for all users')
    $iapsapp = "C:\Program Files (x86)\I2N\IapsNDeliusInterface\PCMSIfConsole.exe"
    $iapsshortcut = "C:\Users\Public\Desktop\PCMSIfConsole.lnk"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$iapsshortcut")
    $Shortcut.TargetPath = $iapsapp
    $Shortcut.Save()

    Write-Host('Setting RunAs Adminisrator flag on new shortcut')
    $bytes = [System.IO.File]::ReadAllBytes("$iapsshortcut")
    $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
    [System.IO.File]::WriteAllBytes("$iapsshortcut", $bytes)

    ###############################################################
    # Copy Live config files from 
    # C:\Setup\Config Files\Live Config\NDelius IF Live Config\ 
    # to install folder
    ###############################################################
    Write-Host('Copying in Live Config Files')
    Copy-Item -Path "C:\Setup\Config Files\Live Config\NDelius IF Live Config\*.XML" -Destination "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\" -Force
    if( (Get-ChildItem "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\*.XML" | Measure-Object).Count -lt 4)
    {
        echo "Error: Filed to copy all NDelius IF Config files"
        exit 1
    }

    ###############################################################
    # Updating IapsNDeliusInterface\Config\NDELIUSIF.xml
    ###############################################################
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name and application from this instance's environment-name and application tag values
    $environment = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment"
        }
    )

    if($environment.Value -eq 'prod') {
        $CertificateSubject = '*.probation.service.justice.gov.uk'
    }
    else {
        $CertificateSubject = '*.' + $environment.Value + '.probation.service.justice.gov.uk'
    }

    Write-Host('Updating NDelius IF SOAPURL and SMTP Values in NDELIUSIF Config')
    $ndifconfigfile="C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\NDELIUSIF.xml"
    $xml = [xml](get-content $ndifconfigfile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.INTERFACES.INTERFACE
    foreach ($element in $xmlElementToModify)
    {
        if ($element.NAME -eq "PCMS")
        {
            $element.SOAPURL="https://localhost:443/NDeliusIAPS"
            $element.SOAPCERT=$CertificateSubject
            $element.REPLICACERT=""
            $element.SOAPPASSCODED="q8y&gt;&#x7;$&#x11;=d&#x5;&#x1B;&#xC;%h{h"
            $element.REPLICAURL=""
        }
    }
    $xmlElementToModify = $xmlElement.EMAIL
    foreach ($element in $xmlElementToModify)
    {
        if ($element.SMTPURL -eq "tbdominoa.i2ntest.local")
        {
            $element.SMTPURL="smtp"
        }
        if ($element.SMTPUSER -eq "administrator")
        {
            $element.SMTPUSER=""
        }
        if ($element.PASSWORDCODED -eq " &lt;5&quot;:4,;;")
        {
            $element.PASSWORDCODED=""
        }
        if ($element.FROMADDRESS -eq "PCMS1-Interface@i2ntest.co.uk")
        {
            $element.FROMADDRESS="PCMS1-Interface@probation.service.justice.gov.uk"
        }
    }
    $xml.Save($ndifconfigfile)

    ###############################################################
    # Restart IapsNDeliusInterfaceWinService service
    ###############################################################
    $service = Restart-Service -Name IapsNDeliusInterfaceWinService -Force -PassThru
    if ($service.Status -match "Running") {
        Write-Host('Restart of IapsNDeliusInterfaceWinService successful')
    } else {
        Write-Host('Error - Failed to restart IapsNDeliusInterfaceWinService - see logs')
        Exit 1
    }

    # TODO Add dynamic interpolation of env specific config values
    # e.g. pull creds in from SSM and write encrypted if poss - see comments on ticket
    # https://dsdmoj.atlassian.net/browse/DAM-188
}
catch [Exception] {
    Write-Host ('Failed to Install NDelius Interface')
    echo $_.Exception|format-list -force
    exit 1
}