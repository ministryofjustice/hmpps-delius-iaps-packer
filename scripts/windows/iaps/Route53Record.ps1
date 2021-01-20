$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    $environment = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment"
        }
    )

    $LANIP = (Get-EC2Instance -Region $region).Instances | ?{$_.InstanceId -eq $instanceid} | select -ExpandProperty PrivateIpAddress
    if (!$LANIP)  {
        Write-Host('Error - R53 Setup failed to retrieve LAN IP')
        Exit 1
    }
    
    write-output '============================================================================='
    write-output ' set DNS entry for ecternaldomain - ie. stage.delius.probation.hmpps.dsd.io'
    write-output '============================================================================='
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

    # Set ResourceRecordSet for v1 of IAPS in 
    if($env:computername -eq 'sim-win-001') {
        $resourceName = "iaps-admin." + $zoneName
    }
   
    # Set ResourceRecordSet for v2 of IAPS
    if($env:computername -eq 'sim-win-002') {
        $resourceName = "iaps-admin-v2." + $zoneName
    }
    
    $resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
    $resourceRecordSet.Name = $resourceName
    $resourceRecordSet.Type = "A"
    $resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ($LANIP)
    $resourceRecordSet.TTL = 300
    
    $resourceRecordSet
    $resourceRecordSet | Select -ExpandProperty ResourceRecords

    # Set Action
    if (((Get-R53ResourceRecordSet -MaxItem 500 -HostedZoneId $hostedZone.id).ResourceRecordSets | where Name -eq $resourceRecordSet.Name | measure).Count -eq 0)
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


    write-output '============================================================================='
    write-output ' set DNS entry for internaldomain - ie. delius-stage.internal'
    write-output '============================================================================='
    Set-Location ENV:
    $internalZoneName =  $env:InternalDomain + "."
    if (!$internalZoneName)  {
        Write-Host('Error - R53 Setup failed to zone name from Environment Variable: InternalDomain')
        Exit 1
    }
    $internalHostedZone = Get-R53HostedZones | where Name -eq $internalZoneName
    if (!$internalHostedZone)  {
        Write-Host('Error - R53 Setup failed to retrieve internalHostedZone hosted zone data')
        Exit 1
    }

    # Set ResourceRecordSet for v1 of IAPS in 
    if($env:computername -eq 'sim-win-001') {
        $resourceName = "iaps-admin." + $internalZoneName
    }
   
    # Set ResourceRecordSet for v2 of IAPS
    if($env:computername -eq 'sim-win-002') {
        $resourceName = "iaps-admin-v2." + $internalZoneName
    }
    
    $internalResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
    $internalResourceRecordSet.Name = $resourceName
    $internalResourceRecordSet.Type = "A"
    $internalResourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ($LANIP)
    $internalResourceRecordSet.TTL = 300

    $internalResourceRecordSet
    $internalResourceRecordSet | Select -ExpandProperty ResourceRecords

 
    # Set Action
    if (((Get-R53ResourceRecordSet -MaxItem 500 -HostedZoneId $internalHostedZone.id).ResourceRecordSets | where Name -eq $internalResourceRecordSet.Name | measure).Count -eq 0)
    {
        $action = [Amazon.Route53.ChangeAction]::CREATE
    }
    else
    {
        $action = [Amazon.Route53.ChangeAction]::UPSERT
    }

    # Set Change 
    $change = New-Object Amazon.Route53.Model.Change ($action, $internalResourceRecordSet)

    # Execute
    Edit-R53ResourceRecordSet -HostedZoneId $internalHostedZone.id -ChangeBatch_Change $change 

    write-output '============================================================================='
    write-output ' set DNS entry for *.probation.service.justice.gov.uk'
    write-output '============================================================================='
    Set-Location ENV:
    $PSJGUZoneName =  $environment.Value + ".probation.service.justice.gov.uk."
    if (!$PSJGUZoneName)  {
        Write-Host('Error - R53 Setup failed to zone name from PSJGUZoneName')
        Exit 1
    }
    $PSJGUZone = Get-R53HostedZones | where Name -eq $PSJGUZoneName
    if (!$PSJGUZone)  {
        Write-Host('Error - R53 Setup failed to retrieve PSJGUZone hosted zone data')
        Exit 1
    }

    # Set ResourceRecordSet for v1 of IAPS in 
    if($env:computername -eq 'sim-win-001') {
        $resourceName = "iaps-admin." + $PSJGUZoneName
    }
   
    # Set ResourceRecordSet for v2 of IAPS
    if($env:computername -eq 'sim-win-002') {
        $resourceName = "iaps-admin-v2." + $PSJGUZoneName
    }
    
    $PSJGUResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
    $PSJGUResourceRecordSet.Name = $resourceName
    $PSJGUResourceRecordSet.Type = "A"
    $PSJGUResourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ($LANIP)
    $PSJGUResourceRecordSet.TTL = 300
    $PSJGUResourceRecordSet
    $PSJGUResourceRecordSet | Select -ExpandProperty ResourceRecords

    # Set Action
    if (((Get-R53ResourceRecordSet -MaxItem 500 -HostedZoneId $PSJGUZone.id).ResourceRecordSets | where Name -eq $resourceName | measure).Count -eq 0)
    {
        $action = [Amazon.Route53.ChangeAction]::CREATE
    }
    else
    {
        $action = [Amazon.Route53.ChangeAction]::UPSERT
    }

    # Set Change 
    $change = New-Object Amazon.Route53.Model.Change ($action, $PSJGUResourceRecordSet)

    # Execute
    Edit-R53ResourceRecordSet -HostedZoneId $PSJGUZone.id -ChangeBatch_Change $change 

}
catch [Exception] {
    Write-Host ('Failed to Update R53')
    echo $_.Exception|format-list -force
    exit 1
}