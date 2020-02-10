Import-Module -Name C:\Setup\Testing\poshspec -Verbose

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

Write-Output "instanceid:      $instanceid"
Write-Output "environmentName: $($environmentName.Value)"
Write-Output "environment:     $($environment.Value)"
Write-Output "application:     $($application.Value)"


New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
Get-PSDrive


Describe 'Regional Configuration' {
    Describe 'Default_user Regional Configuration' {
            Registry 'HKU:\.DEFAULT\Control Panel\International' 'Locale'      { Should Be '00000809' }
            Registry 'HKU:\.DEFAULT\Control Panel\International' 'LocaleName'  { Should Be 'en-GB' }
            Registry 'HKU:\.DEFAULT\Control Panel\International' 'sCountry'    { Should Be 'United Kingdom' }
            Registry 'HKU:\.DEFAULT\Control Panel\International\Geo' 'Nation'  { Should Be '242' }
    }
}

Describe 'ComputerName is correct' {
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' 'ComputerName' { Should Be 'sim-win-001' }
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputerName' 'ComputerName' { Should Be 'sim-win-001' }
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'Hostname' { Should Be 'sim-win-001' }
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'NV Hostname' { Should Be 'sim-win-001' }
    Registry 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'AltDefaultDomainName' { Should Be 'sim-win-001' }
    Registry 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'DefaultDomainName' { Should Be 'sim-win-001' }
} 

Describe 'AmazonCloudWatchAgent is Running' {
    Service AmazonCloudWatchAgent Status { Should Be Running }
} 

# nDelius Interface Config
Describe 'nDelius Interface Config' {
    File 'C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\NDELIUSIF.XML' { Should -Exist }      
  
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

    $configfile="C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\NDELIUSIF.xml"
    $xml = [xml](get-content $configfile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.Interfaces.INTERFACE

    foreach ($element in $xmlElementToModify)
    {
        if ($element.NAME -eq "PCMS")
        {
            $elementToTest = $element
        }
    }

    Describe 'INTERFACE NAME' {
        $elementToTest.NAME | Should Be 'PCMS'
    }

    Describe 'INTERFACE USER' {
        $elementToTest.USER | Should Be 'shadow'
    }

    Describe 'INTERFACE PASSWORD' {
        $elementToTest.PASSWORD | Should Be ''
    }

    Describe 'INTERFACE PROBEDELAYSECS' {
        $elementToTest.PROBEDELAYSECS | Should Be '30'
    }

    Describe 'INTERFACE ODBC' {
        $elementToTest.ODBC | Should Be 'DSN=PCMSSHADOW;uid=%USER%;pwd=%PASSWORD%'
    }

    Describe 'INTERFACE SOAPURL' {
        $elementToTest.SOAPURL | Should Be 'https://localhost:443/NDeliusIAPS'
    }

    Describe 'INTERFACE SOAPUSER' {
        $elementToTest.SOAPUSER | Should Be 'IAPS-User'
    }

    Describe 'INTERFACE SOAPPASS Is not blank' {
        $elementToTest.SOAPPASS | Should Not Be ''
    }

    Describe 'INTERFACE REPLICAURL Is blank' {
        $elementToTest.REPLICAURL | Should  Be ''
    }

    Describe 'INTERFACE REPLICAPASSWORD Is blank' {
        $elementToTest.REPLICAPASSWORD | Should  Be ''
    }

    Describe 'INTERFACE REPLICAPASSWORDCODED Is not blank' {
        $elementToTest.REPLICAPASSWORDCODED | Should Not Be ''
    }

    Describe 'INTERFACE SOAPCERT' {
        $elementToTest.SOAPCERT | Should  Be $CertificateSubject
    }
    
    Describe 'INTERFACE REPLICACERT Is blank' {
        $elementToTest.REPLICACERT | Should  Be ''
    }

    Describe 'INTERFACE SOAPPASSCODED Is not blank' {
        $elementToTest.SOAPPASSCODED | Should Not Be ''
    }

    Describe 'INTERFACE PASSWORDCODED Is not blank' {
        $elementToTest.PASSWORDCODED | Should Not Be ''
    }



}

# IM Interface Config
Describe 'IM Interface Config' {
    File 'C:\Program Files (x86)\I2N\IapsIMInterface\Config\IMIAPS.XML' { Should -Exist }    

    $iaps_im_soapserver_odbc_server_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_server"
    $iaps_im_soapserver_odbc_server = Get-SSMParameter -Name $iaps_im_soapserver_odbc_server_SSMPath -WithDecryption $true

    $iaps_im_soapserver_odbc_database_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_database"
    $iaps_im_soapserver_odbc_database = Get-SSMParameter -Name $iaps_im_soapserver_odbc_database_SSMPath -WithDecryption $true

    $iaps_im_soapserver_odbc_uid_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_uid"
    $iaps_im_soapserver_odbc_uid = Get-SSMParameter -Name $iaps_im_soapserver_odbc_uid_SSMPath -WithDecryption $true

    $iaps_im_soapserver_odbc_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_password"
    $iaps_im_soapserver_odbc_password = Get-SSMParameter -Name $iaps_im_soapserver_odbc_password_SSMPath -WithDecryption $true

    $expectedODBC ='DSN=IM;Server=' + $iaps_im_soapserver_odbc_server.Value + ';Database=' + $iaps_im_soapserver_odbc_database.Value + ';uid=' + $iaps_im_soapserver_odbc_uid.Value + ';pwd=' + $iaps_im_soapserver_odbc_password.Value

    $imconfigfile="C:\Program Files (x86)\I2N\IapsIMInterface\Config\IMIAPS.xml"
    $xml = [xml](get-content $imconfigfile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToTest = $xmlElement.SOAPSERVER 

         
    Describe 'SOAPSERVER URL' {
        $xmlElementToTest.URL | Should Be 'https://localhost/IMIapsSoap/service.svc'
    }

    Describe 'SOAPSERVER ODBC' {
        $xmlElementToTest.ODBC | Should Be $expectedODBC
    }

    $xmlElementToTest = $xmlElement.IAPSORACLE

    Describe 'IAPSORACLE NAME' {
        $xmlElementToTest.NAME | Should Be 'IAPSCENTRAL'
    }

    Describe 'IAPSORACLE DESCRIPTION' {
        $xmlElementToTest.DESCRIPTION | Should Be 'iaps-db'
    }

    Describe 'IAPSORACLE USER' {
        $xmlElementToTest.USER | Should Be 'nps'
    }

    Describe 'IAPSORACLE PROBEDELAYSECS' {
        $xmlElementToTest.PROBEDELAYSECS | Should Be '600'
    }

    Describe 'IAPSORACLE ODBC' {
        $xmlElementToTest.ODBC | Should Be 'DSN=PCMSIFIAPS;uid=%USER%;pwd=%PASSWORD%'
    }


    Describe 'IAPSORACLE TOIAPS' {
        $xmlElementToTest.TOIAPS | Should Be 'Y'
    }


}

# UserData Re-Enabled
Describe 'UserData Re-Enabled' {

    $result = $true

    $EC2SettingsFile="C:\Program Files\Amazon\Ec2ConfigService\Settings\Config.xml"
    $xml = [xml](get-content $EC2SettingsFile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.Plugins
    
    foreach ($element in $xmlElementToModify.Plugin)
    {
        if ($element.name -eq "Ec2HandleUserData")
        {
            If ($element.State -ne "Enabled") {
                $result = $false
            }
        }
    }
    
    $result | Should Be $True 

}

# nginx config set for IM and nDelius
Describe 'nginx config set for IM and nDelius' {
     File 'C:\nginx\nginx-1.17.6\conf\nginx.conf' { Should -Exist }
}

# nginx listening on 80
Describe 'nginx listening on 80' {
    TcpPort localhost 80 PingSucceeded  { Should Be $true }
    TcpPort localhost 80 TcpTestSucceeded { Should Be $false }
}

# nginx listening on 443
Describe 'nginx listening on 443' {
    TcpPort localhost 443 PingSucceeded  { Should Be $true }
    TcpPort localhost 443 TcpTestSucceeded { Should Be $true }
}

# route53 config
Describe 'Route53 Record Updated for iaps-admin' {
    
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    $LANIP = (Get-EC2Instance -Region $region).Instances | ?{$_.InstanceId -eq $instanceid} | select -ExpandProperty PrivateIpAddress
    if (!$LANIP)  {
        Write-Host('Error - R53 Setup failed to retrieve LAN IP')
        Exit 1
    }

    Set-Location ENV:
    $zoneName =  $env:ExternalDomain + "."
    $hostedZone = Get-R53HostedZones | where Name -eq $zoneName
    $resourceName = "iaps-admin." + $zoneName
    
    Get-R53ResourceRecordSet -HostedZoneId $hostedZone.id

    $dnsrecord = $(Get-R53ResourceRecordSet -HostedZoneId $($hostedZone.Id)).ResourceRecordSets | `
        Where {$_.Type -like '*' -and $_.Name -eq $resourceName} | Select Name,Type,@{Name='Value';Expression={$_.ResourceRecords | `
            Select -ExpandProperty Value}} 

    $typecheck = If ($dnsrecord.Type.Value -eq 'A') {$true} Else {$false} 
    $ipcheck = If ($dnsrecord.Value -eq $LANIP) {$true} Else {$false}

    $typecheck | Should Be $True 
    $ipcheck | Should Be $True 

}

# Local Users Created
Describe 'Default Local Users Created, Enabled and Disabled\' {
        LocalUser 'i2nadmin'      { Should -Not -BeNullOrEmpty }
        LocalUser 'Administrator' { Should -Not -BeNullOrEmpty }
        LocalUser 'Administrator' Disabled { Should -Be $false }
        LocalUser 'Guest' Disabled { Should Be $true }
}

Describe 'ACM Certificates Configuration' {
    
    It 'Trusted Publishers/Amazon cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPublisher | Where subject -eq 'CN=Amazon, OU=Server CA 1B, O=Amazon, C=US'
        $exists | Should Not Be $Null
    }
    It 'Trusted People/*.stage.delius.probation.hmpps.dsd.io cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPeople | Where subject -eq 'CN=*.stage.delius.probation.hmpps.dsd.io'
        $exists | Should Not Be $Null
    }

    It 'Trusted People/*.stage.delius.probation.hmpps.dsd.io cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPeople | Where subject -eq 'CN=*.stage.probation.service.justice.gov.uk'
        $exists | Should Not Be $Null
    }

    It 'Trusted People/*.stage.probation.service.justice.gov.uk cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPeople | Where subject -eq 'CN=*.stage.probation.service.justice.gov.uk'
        $exists | Should Not Be $Null
    }
    
    It 'Trusted People/Amazon cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPeople | Where subject -eq 'CN=Amazon, OU=Server CA 1B, O=Amazon, C=US'
        $exists | Should Not Be $Null
    }

    It 'Trusted People/Amazon Root CA 1 cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPeople | Where subject -eq 'CN=Amazon Root CA 1, O=Amazon, C=US'
        $exists | Should Not Be $Null
    }

    It 'Trusted People/Starfield Services Root Certificate Authority - G2 cert exists' {
        $exists = Get-ChildItem cert:\LocalMachine\TrustedPeople | Where subject -eq 'CN=Starfield Services Root Certificate Authority - G2, O="Starfield Technologies, Inc.", L=Scottsdale, S=Arizona, C=US'
        $exists | Should Not Be $Null
    }
}

Describe 'DNS Search Suffix Configuration' {
    
    It 'service.justice.gov.uk suffix exists' {
        $suffix="service.justice.gov.uk"
        $dnsconfig = Get-DnsClientGlobalSetting
        if ($dnsconfig.SuffixSearchList -match $suffix) {
            $result = $true
        } else {
           $result = $false
        }

        $result | Should Be $True
    }
     
    It "$($environmentname.Value).internal suffix exists" {
        $suffix="$($environmentname.Value).internal"
        $dnsconfig = Get-DnsClientGlobalSetting
        if ($dnsconfig.SuffixSearchList -match $suffix) {
            $result = $true
        } else {
           $result = $false
        }

        $result | Should Be $True
    } 

    It "$($environment.Value).delius.probation.hmpps.dsd.io suffix exists" {
        $suffix="$($environment.Value).delius.probation.hmpps.dsd.io"
        $dnsconfig = Get-DnsClientGlobalSetting
        if ($dnsconfig.SuffixSearchList -match $suffix) {
            $result = $true
        } else {
           $result = $false
        }

        $result | Should Be $True
    } 

}
 

