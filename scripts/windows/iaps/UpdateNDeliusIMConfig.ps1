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
    
    if($environment.Value -eq 'prod') {
        $CertificateSubject = '*.probation.service.justice.gov.uk'
    }
    else {
        $CertificateSubject = '*.' + $environmentName.Value + '.probation.service.justice.gov.uk'
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
            $element.SOAPUSER=$IAPSDeliusUserName.Value
            $element.SOAPPASS=$IAPSDeliusUserPassword.Value
            $element.SOAPCERT=$CertificateSubject
        }
    }
    $xml.Save($configfile)

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
