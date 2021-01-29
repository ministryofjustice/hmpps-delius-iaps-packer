Write-Output "------------------------------------" 
Write-Output "Cycling nginx logs.."
Write-Output Get-Date 
Write-Output "------------------------------------"

# get todays date for timestamping archived
$DateFrom = get-date -UFormat "%Y-%m-%d"

# source nginx logs folder
$nginxLogsFolder = "C:\nginx\nginx-1.17.6\logs"

Write-Output "Stopping nginx service.."
Stop-Service -Name nginx

Write-Output "Archiving log '$nginxLogsFolder\access.log' to '${nginxLogsFolder}access_$DateFrom.log'"
Move-Item -Path $nginxLogsFolder\access.log -Destination $nginxLogsFolder\access_$DateFrom.log

Write-Output "Archiving logs to error_$DateFrom.log"
Move-Item -Path  C:\nginx\nginx-1.17.6\logs\error.log -Destination C:\nginx\nginx-1.17.6\logs\error_$DateFrom.log

Write-Output "Restarting the nginx service"
Start-Service -Name nginx
