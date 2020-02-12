###############################################################################
# Set sshd (OpenSSH SSH Server) service to -StartupType Disabled
################################################################################
Set-Service -Name sshd -StartupType Disabled
Stop-Service -Name sshd
Get-Service sshd | Select-Object -Property Name, StartType, Status 


