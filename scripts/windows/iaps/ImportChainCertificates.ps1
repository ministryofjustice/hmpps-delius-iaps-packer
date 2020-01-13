$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {
    Write-Host('---------------------------------')
    Write-Host('Importing Chain Certificates')
    Write-Host('---------------------------------')
    Import-Certificate -FilePath "C:\Setup\Certificates\ca chain 1.cer" -CertStoreLocation Cert:\LocalMachine\TrustedPeople
    Import-Certificate -FilePath "C:\Setup\Certificates\ca chain 2.Cer" -CertStoreLocation Cert:\LocalMachine\TrustedPeople
    Import-Certificate -FilePath "C:\Setup\Certificates\ca chain 3.Cer" -CertStoreLocation Cert:\LocalMachine\TrustedPeople

    Get-ChildItem -Recurse Cert:\LocalMachine\TrustedPeople
}
catch [Exception]{
    Write-Host ('Failed to Import Chain Certificates')
    echo $_.Exception|format-list -force
    exit 1
} 
