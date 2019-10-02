$onetimepassword = "MustBeChanged0!"
$userslist = ".\i2n-users.txt"

Get-Content $userslist | ForEach-Object {
    $user = $_
    Write-Host("Creating user: $user")
    $creds = New-Credential -UserName $user -Password $onetimepassword
    Install-User -Credential $creds -PasswordExpires
    Add-GroupMember -Name Administrators -Member $user
    # Limited by version of powershell - need to use net cmd to force password change
    net user $user /logonpasswordchg:yes
} 
