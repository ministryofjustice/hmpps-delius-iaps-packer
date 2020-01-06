<powershell>

$adminUser = (Get-SSMParameterValue -Name /delius-core-dev/delius-core/iaps/iaps/iaps_user).Parameters.Value
$adminPassword = (Get-SSMParameterValue -Name /delius-core-dev/delius-core/iaps/iaps/iaps_password -WithDecryption $true).Parameters.Value

$adminCreds = New-Credential -UserName "$adminUser" -Password "$adminPassword"
Install-User -Credential $adminCreds

Add-GroupMember -Name Administrators -Member $adminUser

$ComputerName = "sim-win-001"
[System.Environment]::SetEnvironmentVariable("ExternalDomain", "dev.delius-core.probation.hmpps.dsd.io",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("ExternalDomain", "dev.delius-core.probation.hmpps.dsd.io", [System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable("ExternalDomain", "dev.delius-core.probation.hmpps.dsd.io", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("InternalDomain", "delius-core-dev.internal",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("InternalDomain", "delius-core-dev.internal", [System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable("InternalDomain", "delius-core-dev.internal", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("PSNProxy", "localhost",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PSNProxy", "localhost", [System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable("PSNProxy", "localhost", [System.EnvironmentVariableTarget]::User)

Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" 
Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" 

New-PSDrive -name HKU -PSProvider "Registry" -Root "HKEY_USERS"

Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\Computername" -name "Computername" -value $ComputerName
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputername" -name "Computername" -value $ComputerName
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" -value $ComputerName
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" -value  $ComputerName
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "AltDefaultDomainName" -value $ComputerName
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $ComputerName

# Resize system drive if overridden from ami value
$MaxSize = (Get-PartitionSupportedSize -DriveLetter C).sizeMax
Resize-Partition -DriveLetter C -Size $MaxSize

# Set timezone
tzutil /s 'GMT Standard Time' 

# Run all scripts that apply runtime config
$runtimeconfig = 'C:\Setup\RunTimeConfig'
Get-ChildItem $runtimeconfig -Filter *.ps1 | 
    Foreach-Object {
        & $runtimeconfig\$_
    }
</powershell>
<persist>true</persist>