$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    Write-Host('Installing IM Interface Package')
    Start-Process -Wait -FilePath "C:\Setup\IM Interface\InstallIMIAPSInterfaceV1.2.15\IMIapsInterfaceService\setup.exe" -ArgumentList "/quiet /qn" -Verb RunAs

    Write-Host('Copying in Live Config Files')
    Copy-Item -Path "C:\Setup\Config Files\Live Config\IM Interface Live Config\*.XML" -Destination "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\" -Force
    if( (Get-ChildItem "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\*.XML" | Measure-Object).Count -lt 1)
    {
        echo "Error: Filed to copy IM Config files"
        Exit 1
    }
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
    $xmlElement.SOAPSERVER.RemoveAttribute("PROXYURL")
    $xml.Save($imconfigfile)
}
catch [Exception] {
    Write-Host ('Failed to install IM Interface service')
    echo $_.Exception|format-list -force
    Exit 1
}