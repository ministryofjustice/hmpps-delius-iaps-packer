$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    Import-Module Carbon

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
    Write-Output "The current environment is $currentenv"

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& powershell c:\Setup\NginxCycleLogs.ps1 > c:\Setup\BackupLogs\NginxCycleLogs.log"'
    $trigger = New-ScheduledTaskTrigger -Daily -At 2am
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "NginxDailyLogsBackup" -Description "Daily archive of nginx Config Files" -User "NT AUTHORITY\SYSTEM"

}
catch [Exception] {
    Write-Host ('Error: Failed to create Windows Scheduled Task to Archive nginx log files')
    echo $_.Exception|format-list -force
} 
