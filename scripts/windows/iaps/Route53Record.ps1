
$LANIP = Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address -expandproperty IPV4Address

Set-Location ENV:
$zoneName =  $env:ExternalDomain + "."

$hostedZone = Get-R53HostedZones | where Name -eq $zoneName

# Set ResourceRecordSet
$resourceName = "iaps-admin." + $zoneName
$resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$resourceRecordSet.Name = $resourceName
$resourceRecordSet.Type = "A"
$resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ($LANIP.IPAddressToString)
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
