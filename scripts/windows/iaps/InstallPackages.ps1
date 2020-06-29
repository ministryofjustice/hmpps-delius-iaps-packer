$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try
{
    Write-Host('vcredist packages')
    choco install -y vcredist2010
    choco install -y vcredist2008

    Write-Host('nginx proxy')
    choco install -y nginx --version 1.17.6 --params "/installLocation:C:\nginx /port:80"

    Write-Host('Firefox browser')
    choco install -y firefox --version 71.0

    Write-Host('7Zip archive util')
    choco install -y 7zip.install --version 19.0

    Write-Host('Install openssl for converting between pkcs12 and pem')
    # Installs vcredist140 (Visual C++ 2017) as a dependency
    choco install -y openssl.light --version 1.1.1.20181020

    Write-Host('Install SoapUI for test and debugging')
    choco install -y soapui

}
catch [Exception] {
    Write-Host ('Failed installing one or more chocolatey packages - see logs')
    echo $_.Exception|format-list -force
    Exit 1
}
