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

$IMHost = 
    switch ($environment.Value) {
        'prod'  { 'data-im' }
        'stage' { 'data-nle'}
        default { 'Unknown'  }
    }

$IMPort = 
    switch ($environment.Value) {
        'prod'  { '' }
        'stage' { ':8443'}
        default { '' }
    }

Describe 'IM  Webservice Connectivity Test' {
    $url = 'https://localhost/IMIAPSSoap/service.svc'

     add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


    $response = Invoke-WebRequest -URI $url

    Describe 'Calling https://localhost/IMIAPSSoap/service.svc should return StatusCode 200' {
        $response.StatusCode | Should Be 200
    }

    Describe 'Content should contain correct IM webservice response' {
        $searchtext="https://$IMHost.noms.gsi.gov.uk$IMPort/IMIapsSoap/Service.svc"

        write-output $response.Content

        if ($response.Content -match $searchtext) {
            $result = $true
        } else {
           $result = $false
        }
        $result | Should Be $True
    }
}

Describe 'NDelius Interface Connectivity Test' {
    $url = 'https://localhost/NDeliusIAPS/RetrieveOffender?wsdl'

    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    $response = Invoke-WebRequest -URI $url

    Describe 'Calling https://localhost/NDeliusIAPS/RetrieveOffender?wsdl should return StatusCode 200' {
        $response.StatusCode | Should Be 200
    }

    Describe 'Content should contain correct NDelius webservice response' {
        $searchtext='https://interface-app-internal.' + $environmentName.Value + '.internal:443/NDeliusIAPS/RetrieveOffender'
        if ($response.Content -match $searchtext) {
            $result = $true
        } else {
           $result = $false
        }
        $result | Should Be $True
    }
}