$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    
    ###############################################################
    # Get creds from ParameterStore for this environment to connect
    ###############################################################
    Write-Host('Fetching IAPS Delius Credentials from SSM Parameter Store')
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name and application from this instance's environment-name and application tag values
    $environmentName = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment-name"
        }
    )
    $application = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="application"
        }
    ) 

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
    # Update IapsIMInterface\Config\IMIAPS.xml
    ###############################################################
    Write-Host('Updating DB and URL Values in IM Config')
    $imconfigfile="C:\Program Files (x86)\I2N\IapsIMInterface\Config\IMIAPS.xml"
    $xml = [xml](get-content $imconfigfile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.SOAPSERVER 
    foreach ($element in $xmlElementToModify)
    {
        $element.DSN='DSN=IM;Server=' + $iaps_im_soapserver_odbc_server.Value + ';Database=' + $iaps_im_soapserver_odbc_database.Value + ';uid=' + $iaps_im_soapserver_odbc_uid.Value + ';pwd=' + $iaps_im_soapserver_odbc_password.Value
    }
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