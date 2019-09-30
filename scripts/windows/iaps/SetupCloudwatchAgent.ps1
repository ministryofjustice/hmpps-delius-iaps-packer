$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {
    $config = "C:\Setup\Cloudwatch\config.json"
    Write-Host ('Start the cloudwatch service')
    Start-Process powershell.exe -WorkingDirectory "C:\Program Files\Amazon\AmazonCloudWatchAgent" -Wait -ArgumentList ".\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:$config -s"

}
catch [Exception] {
    Write-Host ('Failed to configure and start aws cloudwatch agent')
    echo $_.Exception|format-list -force
    #exit 1
} 
 
