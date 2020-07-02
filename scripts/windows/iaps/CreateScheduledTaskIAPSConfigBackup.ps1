 
$adminUser = (Get-SSMParameterValue -Name /delius-stage/delius/iaps/iaps/iaps_user).Parameters.Value
$adminPassword = (Get-SSMParameterValue -Name /delius-stage/delius/iaps/iaps/iaps_password -WithDecryption $true).Parameters.Value

$adminCreds = New-Credential -UserName "$adminUser" -Password "$adminPassword"

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& powershell c:\Setup\Backup-IAPS-Configs.ps1 > c:\Setup\Backup-IAPS-Configs.log"'

$trigger =  New-ScheduledTaskTrigger -Daily -At 9am

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "IAPSDailyConfigBackup" -Description "Daily backup of IAPS Config Files to S3" -User $adminUser -Password $adminPassword
