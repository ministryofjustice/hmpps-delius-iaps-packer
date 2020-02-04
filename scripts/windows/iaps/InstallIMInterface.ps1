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

    ################################
    # /iaps/iaps/iaps_im_soapserver_odbc_server
    # /iaps/iaps/iaps_im_soapserver_odbc_database
    # /iaps/iaps/iaps_im_soapserver_odbc_uid
    # /iaps/iaps/iaps_im_soapserver_odbc_password
    ################################
    Write-Host('get ssm param /iaps/iaps/iaps_im_soapserver_odbc_server')
    Write-Host('get ssm param /iaps/iaps/iaps_im_soapserver_odbc_database')
    Write-Host('get ssm param /iaps/iaps/iaps_im_soapserver_odbc_uid')
    Write-Host('get ssm param /iaps/iaps/iaps_im_soapserver_odbc_password')

    $iaps_im_soapserver_odbc_server_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_server"
    $iaps_im_soapserver_odbc_server = Get-SSMParameter -Name $iaps_im_soapserver_odbc_server_SSMPath -WithDecryption $true

    $iaps_im_soapserver_odbc_database_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_database"
    $iaps_im_soapserver_odbc_database = Get-SSMParameter -Name $iaps_im_soapserver_odbc_database_SSMPath -WithDecryption $true

    $iaps_im_soapserver_odbc_uid_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_uid"
    $iaps_im_soapserver_odbc_uid = Get-SSMParameter -Name $iaps_im_soapserver_odbc_uid_SSMPath -WithDecryption $true

    $iaps_im_soapserver_odbc_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_password"
    $iaps_im_soapserver_odbc_password = Get-SSMParameter -Name $iaps_im_soapserver_odbc_password_SSMPath -WithDecryption $true

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
        
        # DSN=IM;Server=imdb01.im.i2ncloud.com;Database=IM-v2;uid=IMApplication;pwd=xxxx 
        $element.DSN='DSN=IM;Server=' + $iaps_im_soapserver_odbc_server.Value + ';Database=' + $iaps_im_soapserver_odbc_database.Value + ';uid=' + $iaps_im_soapserver_odbc_uid.Value + ';pwd=' + $iaps_im_soapserver_odbc_password.Value
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