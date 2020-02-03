

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {
    Write-Host('---------------------------------')
    Write-Host('Importing PSN Certificates')
    Write-Host('---------------------------------')
    Import-Certificate -FilePath "C:\Setup\Certificates\ca chain 1.cer" -CertStoreLocation Cert:\LocalMachine\TrustedPeople
  
    Get-ChildItem -Recurse Cert:\LocalMachine\TrustedPeople
}
catch [Exception]{
    Write-Host ('Failed to Import PSN Certificates')
    echo $_.Exception|format-list -force
    exit 1
} 
