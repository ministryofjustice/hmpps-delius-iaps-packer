$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    ###############################################################
    # Install IMInterface Package
    ###############################################################
    Write-Host('Installing IM Interface Package')
    Start-Process -Wait -FilePath "C:\Setup\IM Interface\latest\setup.exe" -ArgumentList "/quiet /qn" -Verb RunAs

    ###############################################################
    # Copy Live Config Files
    ###############################################################
    Write-Host('Copying in Live Config Files')
    Copy-Item -Path "C:\Setup\Config Files\Live Config\IM Interface Live Config\*.XML" -Destination "C:\Program Files (x86)\I2N\IapsIMInterface\Config\" -Force
    if( (Get-ChildItem "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\*.XML" | Measure-Object).Count -lt 1)
    {
        echo "Error: Filed to copy IM Config files"
        Exit 1
    }
    ###############################################################
    # Update IapsNDeliusInterface\Config\IMIAPS.xml
    ###############################################################
    Write-Host('Updating DB and URL Values in IM Config')
    $imconfigfile="C:\Program Files (x86)\I2N\IapsIMInterface\Config\IMIAPS.xml"
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

    ###############################################################
    # Restart IMIapsInterfaceWinService service
    ###############################################################
    $service = Restart-Service -Name IMIapsInterfaceWinService -Force -PassThru
    if ($service.Status -match "Running") {
        Write-Host('Restart of IMIapsInterfaceWinService successful')
    } else {
        Write-Host('Error - Failed to restart IMIapsInterfaceWinService - see logs')
        Exit 1
    }

}
catch [Exception] {
    Write-Host ('Failed to install IM Interface service')
    echo $_.Exception|format-list -force
    Exit 1
}