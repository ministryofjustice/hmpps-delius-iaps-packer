Import-Module -Name C:\Setup\Testing\poshspec -Verbose

$ComputerName = "sim-win-001"



Describe 'ComputerName is correct' {
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Control\Computername\Computername' 'Computername' { Should Be $ComputerName }
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputername' 'Computername' { Should Be $ComputerName }
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'Hostname' { Should Be $ComputerName }
    Registry 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'NV Hostname' { Should Be $ComputerName }
    Registry 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'AltDefaultDomainName' { Should Be $ComputerName }
    Registry 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'DefaultDomainName' { Should Be $ComputerName }
}

# nDelius Interface Config
Describe 'nDelius Interface Config' {
    File 'C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config\NDELIUSIF.XML' { Should -Exist }      

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

}

# Local Users Created
Describe 'Default Local Users Created, Enabled and Disabled\' {
    LocalUser 'i2nadmin'      { Should -Not -BeNullOrEmpty }
    LocalUser 'Administrator' { Should -Not -BeNullOrEmpty }
    LocalUser 'Administrator' Disabled { Should -Be $false }
    LocalUser 'Guest' Disabled { Should Be $true }
}


Describe 'ACM Certificates Configuration' {
    
}

