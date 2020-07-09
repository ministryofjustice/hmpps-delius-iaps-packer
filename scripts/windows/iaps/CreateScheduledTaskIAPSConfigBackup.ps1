$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    $dir = "C:\Setup\BackupLogs"
    if(!(Test-Path -Path $dir )){
        New-Item -ItemType directory -Path $dir
        Write-Host "Backups Log folder created"
    }
    else
    {
      Write-Host "Backups Log Folder already exists"
    }

    ################################################################################
    # Get the Environment Name from ec2 meta data 
    ################################################################################
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

    $currentenv = ($environmentName.Value)
    $currentenv

    $adminUser = (Get-SSMParameterValue -Name "/$currentenv/delius/iaps/iaps/iaps_user").Parameters.Value
    $adminUser

    $adminPassword = (Get-SSMParameterValue -Name /$currentenv/delius/iaps/iaps/iaps_password -WithDecryption $true).Parameters.Value
   
    $adminCreds = New-Credential -UserName "$adminUser" -Password "$adminPassword"

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& powershell c:\Setup\RunTimeConfig\Backup-IAPS-Configs.ps1 > c:\Setup\BackupLogs\backup.log"'

    $trigger =  New-ScheduledTaskTrigger -Daily -At 9am

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "IAPSDailyConfigBackup" -Description "Daily backup of IAPS Config Files to S3" -User "SIM-WIN-001\$adminUser" -Password $adminPassword

}
catch [Exception] {
    Write-Host ('Error: Failed to copy IAPS config files to s3')
    echo $_.Exception|format-list -force
    #exit 1
} 
  
