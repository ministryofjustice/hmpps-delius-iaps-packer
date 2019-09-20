$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    $LANIP = (Get-EC2Instance -Region $region).Instances | ?{$_.InstanceId -eq $instanceid} | select -ExpandProperty PrivateIpAddress
    if (!$LANIP)  {
        Write-Host('Error - R53 Setup failed to retrieve LAN IP')
        Exit 1
    }
    Set-Location ENV:
    $zoneName =  $env:ExternalDomain + "."
    if (!$zoneName)  {
        Write-Host('Error - R53 Setup failed to zone name from Environment Variable: ExternalDomain')
        Exit 1
    }
    $hostedZone = Get-R53HostedZones | where Name -eq $zoneName
    if (!$hostedZone)  {
        Write-Host('Error - R53 Setup failed to retrieve hosted zone data')
        Exit 1
    }
    # Set ResourceRecordSet
    $resourceName = "iaps-admin." + $zoneName
    $resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
    $resourceRecordSet.Name = $resourceName
    $resourceRecordSet.Type = "A"
    $resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ($LANIP)
    $resourceRecordSet.TTL = 300


    # Set Action
    if (((Get-R53ResourceRecordSet -HostedZoneId $hostedZone.id).ResourceRecordSets | where Name -eq $resourceName | measure).Count -eq 0)
    {
        $action = [Amazon.Route53.ChangeAction]::CREATE
    }
    else
    {
        $action = [Amazon.Route53.ChangeAction]::UPSERT
    }

    # Set Change 
    $change = New-Object Amazon.Route53.Model.Change ($action, $resourceRecordSet)

    # Execute
    Edit-R53ResourceRecordSet -HostedZoneId $hostedZone.id -ChangeBatch_Change $change 
}
catch [Exception] {
    Write-Host ('Failed to Update R53')
    echo $_.Exception|format-list -force
    exit 1
}