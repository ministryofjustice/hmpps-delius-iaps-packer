$hku = Get-PSDrive | Where { $_.Root -eq 'HKEY_USERS'}
if($hku -eq $null) {
    write-host 'Creating HKEY_USERS as PSDrive HKU'
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
}
else {
    write-host 'HKEY_USERS PSDrive HKU already exists, skipping'
} 

Invoke-Pester -Script C:\Setup\Testing\IMTests-Generic.ps1

Invoke-Pester -Script C:\Setup\Testing\IMTests-PackerAMIBuild.ps1
