$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
Write-Host('Fetching IAPS Delius Local Users to Create from SSM Parameter Store')
    # Get the instance id from ec2 meta data
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
    $application = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="application"
        }
    )

    $IAPSLocalUsersSSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_local_users"
    try {
        $IAPSLocalUsersList = Get-SSMParameter -Name $IAPSLocalUsersSSMPath -WithDecryption $true
        Write-Host("Raw users list from Parameter Store Path '$IAPSLocalUsersSSMPath': '$IAPSLocalUsersList'")
    }
    catch [Exception] {
        Write-Host ("Failed to fetch ssm params from $IAPSLocalUsersSSMPath")
        echo $_.Exception|format-list -force
        exit 1
    } 
    
    $onetimepassword = "MustBeChanged0!"
    $userslist = $IAPSLocalUsersList.Value.split(",") 

    Write-Host("Creating Local Users specified in Parameter Store Path '$IAPSLocalUsersSSMPath'")
    $userslist | ForEach-Object {
        $user = $_
        Write-Host("Creating user: $user")
        $creds = New-Credential -UserName $user -Password $onetimepassword
        Install-User -Credential $creds -PasswordExpires
        Add-GroupMember -Name Administrators -Member $user
        # Limited by version of powershell - need to use net cmd to force password change
        net user $user /logonpasswordchg:yes
    } 
}
catch [Exception] {
    Write-Host ('Failed to create users')
    echo $_.Exception|format-list -force
    exit 1
}