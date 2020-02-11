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
    # /apacheds/apacheds/iaps_user
    ################################
    $IAPSUserSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/apacheds/apacheds/iaps_user"
    $IAPSDeliusUserName = Get-SSMParameter -Name $IAPSUserSSMPath -WithDecryption $true
    
    ################################
    # /apacheds/apacheds/iaps_user_password
    ################################
    $IAPSUserPasswordSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/apacheds/apacheds/iaps_user_password"
    $IAPSDeliusUserPassword = Get-SSMParameter -Name $IAPSUserPasswordSSMPath -WithDecryption $true
    
    ################################
    # /iaps/iaps/iaps_ndelius_soap_password_coded
    ################################
    $IAPSUserPasswordCodedSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_ndelius_soap_password_coded"
    $IAPSDeliusUserPasswordCoded = Get-SSMParameter -Name $IAPSUserPasswordCodedSSMPath -WithDecryption $true
    
    ################################
    # /iaps/iaps/iaps_pcms_oracle_shadow_password_coded
    ################################
    $IAPSPCMSOracleShadowPasswordCodedSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_pcms_oracle_shadow_password_coded"
    $IAPSPCMSOracleShadowPasswordCoded = Get-SSMParameter -Name $IAPSPCMSOracleShadowPasswordCodedSSMPath -WithDecryption $true
    
    # only update if not prod as default is *.probation.service.justice.gov.uk
    if($environment.Value -eq 'prod') {
        $CertificateSubject = '*.probation.service.justice.gov.uk'
    }
    else {
        $CertificateSubject = '*.' + $environment.Value + '.probation.service.justice.gov.uk'        
    }
  
    ################################################################################
    # Edit IapsNDeliusInterface\Config\NDELIUSIF.xml with creds & cert subject for this environment
    ################################################################################
    Write-Host('Updating NDELIUSIF Config with Credentials')
    $configfile="C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\NDELIUSIF.xml"
    $xml = [xml](get-content $configfile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.Interfaces.INTERFACE
    foreach ($element in $xmlElementToModify)
    {
        if ($element.NAME -eq "PCMS")
        {
            $element.SOAPUSER      = $IAPSDeliusUserName.Value
            $element.SOAPPASS      = $IAPSDeliusUserPassword.Value
            $element.SOAPPASSCODED = $IAPSDeliusUserPasswordCoded.Value
            $element.SOAPCERT      = $CertificateSubject
            $element.PASSWORDCODED = $IAPSPCMSOracleShadowPasswordCoded.Value
        }
    }
    $xml.Save($configfile)


    # Note: This script is required as some IAPS passwords have characters that are escaped in XML when the values are updated by UpdateNDeliusIMConfig.ps1
    # This script then updates the values to remove the encoding using RAW text manipulation as the XML parser will explicity encode the chars on writing the file
    Write-Host('---------------------------------------------------------------------')
    Write-Host('Updating NDELIUSIF Config with Credentials - Character Encoding Fix')
    Write-Host('---------------------------------------------------------------------')
    $configfile="C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\NDELIUSIF.xml"

    #SOAPPASSCODED
    $searchtext_SOAPPASSCODED  = [System.Web.HttpUtility]::HtmlEncode($IAPSDeliusUserPasswordCoded.Value)
    $replacetext_SOAPPASSCODED = [Regex]::UnEscape($IAPSDeliusUserPasswordCoded.Value)
    #PASSWORDCODED
    $searchtext_PASSWORDCODED  = [System.Web.HttpUtility]::HtmlEncode($IAPSPCMSOracleShadowPasswordCoded.Value)
    $replacetext_PASSWORDCODED = [Regex]::UnEscape($IAPSPCMSOracleShadowPasswordCoded.Value)

    $content = (Get-Content -path "$configfile" -Raw)

    write-host "Search for '$($searchtext_SOAPPASSCODED)' and replace with '$($replacetext_SOAPPASSCODED)'"
    $content.Replace($searchtext_SOAPPASSCODED, $replacetext_SOAPPASSCODED) | Set-Content -Path $configfile 
    write-host "Search for '$($searchtext_PASSWORDCODED)' and replace with '$($replacetext_PASSWORDCODED)'"
    $content.Replace($searchtext_PASSWORDCODED, $replacetext_PASSWORDCODED) | Out-Null

    ################################################################################
    # Set IapsNDeliusInterfaceWinService service to -StartupType Automatic
    ################################################################################
    Set-Service -Name IapsNDeliusInterfaceWinService -StartupType Automatic
    Get-Service IapsNDeliusInterfaceWinService | Select-Object -Property Name, StartType, Status

    ################################################################################
    # Restart IapsNDeliusInterfaceWinService service
    ################################################################################
    $service = Restart-Service -Name IapsNDeliusInterfaceWinService -Force -PassThru
    if ($service.Status -match "Running") {
        Write-Host('Restart of IapsNDeliusInterfaceWinService successful')
    } else {
        Write-Host('Error - Failed to restart IapsNDeliusInterfaceWinService - see logs')
        Exit 1
    }

}
catch [Exception] {
    Write-Host ('Failed to fetch ssm params')
    echo $_.Exception|format-list -force
    exit 1
} 
