$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Update dns search suffix with internal domain name
try {
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name from this instance's environment-name tag value
    $environment = aws ec2 describe-tags --region eu-west-2 --filters "Name=resource-id,Values=$instanceid","Name=key,Values=environment-name" --query 'Tags[0].Value' --output text
    # Add the internal hosted zone suffix to the existing list - if tagged correctly, ie not build env
    if ($environment -like "*none*") {
        Write-Host('Skipping DNS Suffix Update as no environment-tag exists')
    } else {
        $dnsconfig = Get-DnsClientGlobalSetting
        if ($dnsconfig.SuffixSearchList -match $environment) {
            Write-Host('Skipping DNS Search Suffix as matching entry exists')
        } else {
            Write-Host('Adding DNS Search Suffix Entry')
            $dnsconfig.SuffixSearchList += "$environment.internal"
            Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
            Clear-DnsClientCache
        }
    }
}
catch [Exception] {
    Write-Host ('Failed to Update DNS Search Suffix List')
    echo $_.Exception|format-list -force
    exit 1
}