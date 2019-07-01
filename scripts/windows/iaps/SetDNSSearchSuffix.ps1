$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Update dns search suffix with internal domain name
try {
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name from this instance's environment-name tag value
    $environment = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment-name"
        }
    )
    # Add the internal hosted zone suffix to the existing list - if tagged correctly, ie not build env
    if (!$environment.Value) {
        Write-Host('Skipping DNS Suffix Update as no environment-tag exists')
        Exit 1
    } else {
        $dnsconfig = Get-DnsClientGlobalSetting
        if ($dnsconfig.SuffixSearchList -match $environment.Value) {
            Write-Host('Skipping DNS Search Suffix as matching entry exists for private zone')
        } else {
            Write-Host('Adding Private Zone (internal) DNS Search Suffix Entry')
            $dnsconfig.SuffixSearchList += $environment.Value + ".internal"
            Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
            Clear-DnsClientCache
        }
    }
}
catch [Exception] {
    Write-Host ('Failed to Update DNS Search Suffix List with Private Zone details')
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with public domain name
try {
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name from this instance's environment-name tag value
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
    if ((!$environment.Value) -or (!$application.Value)) {
        Write-Host('Skipping DNS Suffix Update as no environment exists')
        Exit 1
    }
    # Add the public hosted zone suffix to the existing list - if tagged correctly, ie not build env
    if ($environment -match "prod") {
        Write-Host('Prod environment - adding public zone dns search suffix')
        $suffix = 'probation.service.justice.gov.uk'
    } else {
        $suffix = $environment.Value + '.' + $application.Value + '.probation.hmpps.dsd.io'
    }
    # Update the search suffix
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host('Skipping DNS Search Suffix as matching entry exists for public zone')
    } else {
        Write-Host('Adding Public Zone DNS Search Suffix Entry')
        $dnsconfig.SuffixSearchList += "$suffix"
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }

}
catch [Exception] {
    Write-Host ('Failed to Update DNS Search Suffix List with Public Zone details')
    echo $_.Exception|format-list -force
    exit 1
}