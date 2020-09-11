 

#DNS Suffix Search List. . . . . . :  eu-west-2.ec2-utilities.amazonaws.com
#  x                                  us-east-1.ec2-utilities.amazonaws.com
#  x                                  ec2-utilities.amazonaws.com
#  x                                  ec2.internal
#  x                                  compute-1.internal
#  x                                  eu-west-2.compute.internal
#  -                                  probation.hmpps.dsd.io
#  -                                  service.justice.gov.uk
#  x                                  delius-prod.internal
#  x                                  prod.delius.probation.hmpps.dsd.io

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"


# Update dns search suffix with 'eu-west-2.ec2-utilities.amazonaws.com'
try {
    $suffix="eu-west-2.ec2-utilities.amazonaws.com"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'us-east-1.ec2-utilities.amazonaws.com'
try {
    $suffix="us-east-1.ec2-utilities.amazonaws.com"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'ec2-utilities.amazonaws.com'
try {
    $suffix="ec2-utilities.amazonaws.coml"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'ec2.internal'
try {
    $suffix="ec2.internal"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'compute-1.internal'
try {
    $suffix="compute-1.internal"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'eu-west-2.compute.internal'
try {
    $suffix="eu-west-2.compute.internal"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'probation.hmpps.dsd.io'
try {
    $suffix="probation.hmpps.dsd.io"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with 'service.justice.gov.uk'
try {
    $suffix="service.justice.gov.uk"
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix $suffix as matching entry exists")
    } else {
        Write-Host("Adding Private Zone $suffix DNS Search Suffix Entry")
        $dnsconfig.SuffixSearchList += $suffix
        Set-DnsClientGlobalSetting -SuffixSearchList $dnsconfig.SuffixSearchList
        Clear-DnsClientCache
    }
}
catch [Exception] {
    Write-Host ("Failed to Update DNS Search Suffix List with $suffix")
    echo $_.Exception|format-list -force
    exit 1
}

# Update dns search suffix with internal domain name (ie. delius-*.internal)
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
        $suffix=$environment.Value + ".internal"

        if ($dnsconfig.SuffixSearchList -match $suffix) {
            Write-Host("Skipping DNS Search Suffix as matching entry exists for private zone $suffix")
        } else {
            Write-Host("Adding Private Zone (internal) DNS Search Suffix Entry $suffix")
            $dnsconfig.SuffixSearchList += $suffix
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

# Update dns search suffix with public domain name (ie. *.delius.probation.hmpps.dsd.io)
try {
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    
    # Get the hostname from this instance's name tag value
    $hostname = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="Name"
        }
    )
    
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
    #if ($environment -match "prod") {
    if ($hostname -eq "Packer Builder") {
        #Write-Host('Prod environment - adding public zone dns search suffix')
        $suffix = 'probation.service.justice.gov.uk'
        Write-Host("This is a Packer Builder Instance - adding public zone dns search suffix $suffix")
    } else {
        $suffix = $environment.Value + '.' + $application.Value + '.probation.hmpps.dsd.io'
        Write-Host("This is a deployed Instance - adding public zone dns search suffix $suffix")
    }
    # Update the search suffix
    $dnsconfig = Get-DnsClientGlobalSetting
    if ($dnsconfig.SuffixSearchList -match $suffix) {
        Write-Host("Skipping DNS Search Suffix as matching entry exists for public zone $suffix")
    } else {
        Write-Host("Adding Public Zone DNS Search Suffix Entry $suffix")
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
