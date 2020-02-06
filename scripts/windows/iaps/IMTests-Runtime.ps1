$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    write-output '----------------------------------------'
    write-output 'Running Pester BDD Runtime Test Suite'
    write-output '----------------------------------------'
    # Add tests here to test ALL config set at runtime by scripts in c:\Setup\RunTimeConfig\  :o)

    # nDelius Interface Config

    # IM Interface Config

    # UserData Re-Enabled

    # nginx config set for IM and nDelius

    # nginx listening on 80

    # nginx listening on 443

    # route53 config
    Describe 'Route53 Record Updated for iaps-admin' {
    
    }

    # Local Users Created

    

    write-output '----------------------------------------'
    write-output 'Test Suite Run Complete'
    write-output '----------------------------------------'
}
catch [Exception] {
    Write-Host ('Failed to run Pester BDD Runtime Test Suite:')
    echo $_.Exception|format-list -force
    exit 1
}
