$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    if (! (Test-Path -Path C:\Setup\ACMCerts) ) {
        Write-Host('Creating ACMCerts Directory')
        New-Item -Path 'C:\Setup' -Name 'ACMCerts' -ItemType 'directory'
    }
    Write-Host('Fetching Valid ACM Certificates from this Account/Region')
    $activecerts = Get-ACMCertificateList -CertificateStatus "ISSUED"
    foreach ($cert in $activecerts) {
        $certname = $cert.DomainName.Replace('*','wildcard')
        Write-Host("Writing Cert and Chain PEM files for $certname")
        $certpemfile = "C:\Setup\ACMCerts\$certname.pem"
        $chainpemfile = "C:\Setup\ACMCerts\$certname.chain.pem"
        $certpem = Get-ACMCertificate -CertificateArn $cert.CertificateArn
        Out-File -FilePath $certpemfile -InputObject $certpem.Certificate -Force
        Out-File -FilePath $chainpemfile -InputObject $certpem.CertificateChain -Force
        Write-Host("Importing cert into TrustedPeople store for $certname")
        Import-Certificate -CertStoreLocation Cert:\LocalMachine\TrustedPeople  $certpemfile
        Write-Host("Importing chain into TrustedPublisher store for $certname")
        Import-Certificate -CertStoreLocation Cert:\LocalMachine\TrustedPublisher $chainpemfile
    }
}
catch [Exception]{
    Write-Host ('Failed to Import ACM Certificates')
    echo $_.Exception|format-list -force
    exit 1
}