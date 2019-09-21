$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
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
    $IAPSUserSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/apacheds/apacheds/iaps_user"
    $IAPSDeliusUserName = Get-SSMParameter -Name $IAPSUserSSMPath -WithDecryption $true
    $IAPSUserPasswordSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/apacheds/apacheds/iaps_user_password"
    $IAPSDeliusUserPassword = Get-SSMParameter -Name $IAPSUserPasswordSSMPath -WithDecryption $true
    
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
        }
    }
    $xml.Save($configfile)

}
catch [Exception] {
    Write-Host ('Failed to fetch ssm params')
    echo $_.Exception|format-list -force
    exit 1
} 
