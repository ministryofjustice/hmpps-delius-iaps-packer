$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    # Get environment domain suffix
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the public zone fqdn suffix from this instance's environment and application tag compound values or set to gov.uk if prod
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
        Write-Host('Error - Nginx setup cannot continue due to missing environment and/or application tags')
        Exit 1
    }
    # Set fqdn suffix for public hosted zones
    if ($environment -match "prod") {
        $suffix = 'probation.service.justice.gov.uk'
    } else {
        $suffix = $environment.Value + '.' + $application.Value + '.probation.hmpps.dsd.io'
    }
    Write-Host('Determined fqdn suffix as: ' + $suffix)

    $dnsservers = Get-DnsClientServerAddress
    foreach ($if in $dnsservers) {
        # IPv4 Interface has Address Family 2, IVv6 is 23
        if (($if.InterfaceAlias -match "Ethernet") -and ($if.AddressFamily -eq 2)){
            $dns = $if.ServerAddresses[0]
        }
    }
    if (!$dns) {
        Write-Host('Error - unable to determine IPv4 DNS resolver to use for nginx')
        Exit 1
    }
    Write-Host('Nginx proxy resolver will use locally configured DNS Server: ' + $dns)

    Write-Host('Updating nginx.conf file with environment specific values')
    $nginxversion = (choco list nginx -lo ~ findstr /R /C:[nginx]).Split('|')[1]
    $nginxdir="C:\nginx\nginx-" + $nginxversion
    Write-Host('Found nginx version: ' + $nginxversion + '. Install dir: ' + $nginxdir)
    $nginxtmpl = "C:\Setup\Nginx\nginx.conf.tmpl"
    $nginxconf = "$nginxdir\conf\nginx.conf"
    Copy-Item -Path $nginxtmpl -Destination $nginxconf -Force
    if (Test-Path -Path $nginxconf) {
        ((Get-Content -path $nginxconf -Raw) -replace '__INTERFACE__',"interface.$suffix") | Set-Content -Path $nginxconf 
        ((Get-Content -path $nginxconf -Raw) -replace '__DNS__',"$dns") | Set-Content -Path $nginxconf 
    } else {
        write-host('Error - could not find nginx conf file: $nginxconf')
        Exit 1
    }

    # Generate ssl cert
    Write-Host('Generating new self signed certificate for localhost nginx proxy...')
    $certcn="localhost"
    # Generate a random string for protecting the cert/key
    $keypassplain=(-join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 32  | % {[char]$_}))
    # Remove previous localhost certs
    $oldcerts = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -match "CN=$certcn" }| Remove-Item
    #Create new self signed cert in local users store
    $newcert=New-SelfSignedCertificate -DnsName $certcn -CertStoreLocation cert:\LocalMachine\My 
    # Read new cert back in from store to verify
    $storedcert=(dir cert:\localmachine\My -recurse | where {$_.Subject -match "CN=" + $certcn})
    if ($newcert.Thumbprint -eq $storedcert.Thumbprint ) { 
        Write-Host('Installed cert to this users local store successfully')
        Write-Host('Exporting Cert for nginx')
        $keypasscipher = ConvertTo-SecureString -String $keypassplain -Force -AsPlainText
        $pfxfile="C:\nginx\nginx-1.17.1\certs\localhost.pfx"
        $pemkeyfile="C:\nginx\nginx-1.17.1\certs\localhost.key"
        $pemcrtfile="C:\nginx\nginx-1.17.1\certs\localhost.crt"
        Export-PfxCertificate -Cert $storedcert -FilePath $pfxfile -Password $keypasscipher
        $pemkey=(openssl pkcs12 -nocerts -nodes -in $pfxfile -out $pemkeyfile --password pass:$keypassplain --passin pass:$keypassplain)
        $pemcrt=(openssl pkcs12 -clcerts -nokeys -nodes -in $pfxfile -out $pemcrtfile --password pass:$keypassplain --passin pass:$keypassplain)
        Import-PfxCertificate -FilePath $pfxfile -Password $keypasscipher -CertStoreLocation cert:\LocalMachine\Root
        
    } 
    else { 
        Write-Host('Failed generating and storing new localhost self signed cert')
        Exit 1
    } 

    # Restart nginx service
    $service = Restart-Service -Name nginx -Force -PassThru
    if ($service.Status -match "Running") {
        Write-Host('Restart of nginx successfull')
    } else {
        Write-Host('Error - Failed to restart nginx - see logs')
        Exit 1
    }

}
catch [Exception] {
    Write-Host ('Failed to configure Nginx')
    echo $_.Exception|format-list -force
    exit 1
}