$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    Write-Host('Installing IM Interface Package')
    Start-Process -Wait -FilePath "C:\Setup\IM Interface\latest\setup.exe" -ArgumentList "/quiet /qn" -Verb RunAs

    Write-Host('Copying in Live Config Files')
    Copy-Item -Path "C:\Setup\Config Files\Live Config\IM Interface Live Config\*.XML" -Destination "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\" -Force
    if( (Get-ChildItem "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\*.XML" | Measure-Object).Count -lt 1)
    {
        echo "Error: Filed to copy IM Config files"
        Exit 1
    }
    Write-Host('Updating DB and URL Values in IM Config')
    $imconfigfile="C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\IMIAPS.xml"
    $xml = [xml](get-content $imconfigfile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.IAPSORACLE
    foreach ($element in $xmlElementToModify)
    {
        if ($element.NAME -eq "IAPSCENTRAL")
        {
            $element.DESCRIPTION="iaps-db"
        }
    }
    $xmlElementToModify = $xmlElement.SOAPSERVER 
    foreach ($element in $xmlElementToModify)
    {
        if ($element.URL -eq "https://data-im.noms.gsi.gov.uk/IMIapsSoap/service.svc")
        {
            $element.URL="https://localhost/IMIapsSoap/service.svc"
        }
    }
    $xmlElement.SOAPSERVER.RemoveAttribute("PROXYURL")
    $xml.Save($imconfigfile)

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
            $element.SOAPCERT="*.probation.service.justice.gov.uk"
            $element.REPLICACERT=""
            $element.SOAPPASSCODED="q8y&gt;&#x7;$&#x11;=d&#x5;&#x1B;&#xC;%h{h"
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
        if ($element.PASSWORDCODED -eq "&lt;5&quot;:4,;;")
        {
            $element.PASSWORDCODED=""
        }
        if ($element.FROMADDRESS -eq "PCMS1-Interface@i2ntest.co.uk")
        {
            $element.FROMADDRESS="PCMS1-Interface@probation.service.justice.gov.uk"
        }
    }
    $xml.Save($ndifconfigfile)
}
catch [Exception] {
    Write-Host ('Failed to install IM Interface service')
    echo $_.Exception|format-list -force
    Exit 1
}