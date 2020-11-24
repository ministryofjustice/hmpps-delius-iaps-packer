 

#https://blog.ipswitch.com/how-to-change-registry-permissions-with-powershell

$idRef     = [System.Security.Principal.NTAccount]("BUILTIN\Users")
$regRights = [System.Security.AccessControl.RegistryRights]::FullControl
$inhFlags  = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
$prFlags   = [System.Security.AccessControl.PropagationFlags]::None
$acType    = [System.Security.AccessControl.AccessControlType]::Allow

$acl1path = 'HKLM:\Software\Wow6432Node\I2n'
$acl1 = Get-Acl $acl1path
$rule1 = New-Object System.Security.AccessControl.RegistryAccessRule ($idRef, $regRights, $inhFlags, $prFlags, $acType)
$acl1.AddAccessRule($rule1)
$acl1 | Set-Acl -Path $acl1path

$acl1.Access

$acl2path = 'HKLM:\Software\Wow6432Node\Wow6432Node\I2n'
$acl2 = Get-Acl $acl2path
$rule2 = New-Object System.Security.AccessControl.RegistryAccessRule ($idRef, $regRights, $inhFlags, $prFlags, $acType)
$acl2.AddAccessRule($rule2)
$acl2 | Set-Acl -Path $acl2path

$acl2.Access 
