$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Clear-Host
try {

    Write-Output 'Stopping Windows service IapsNDeliusInterfaceWinService'
    stop-service IapsNDeliusInterfaceWinService
    Write-Output 'Stopping Windows service IMIapsInterfaceWinService'
    stop-service IMIapsInterfaceWinService

    ##############################################
    # Get the Environment Name from ec2 meta data 
    ##############################################
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    Write-Output "instanceid: $instanceid"
    
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
    Write-Output "environmentName: $environmentName"

    $IMConfigFilesPrefix="IapsIMInterface/"
    $NDeliusIFConfigFilesPrefix="IapsNDeliusInterface/"

    ##############################################
    # Calculate S3 Bucket Name 
    ##############################################
    $s3bucketname = 'tf-eu-west-2-hmpps-' + $environmentName.Value + '-iaps-s3bucket'
    Write-Output "Checking backups bucket '$s3bucketname' for latest backup folder"

    $LatestFolder = aws s3 ls $s3bucketname/ | sort -Descending | Select-Object -first 1
    $LatestFolderFormatted = $LatestFolder.Replace('PRE','').Replace('/','').replace(' ','')

    $SourcePath = "s3://$s3bucketname/$LatestFolderFormatted/"
    Write-Output "SourcePath is '$SourcePath'"

    ##############################################
    # Restore Files from S3
    ##############################################
    $IMConfigFilesFolder = "C:\Program Files (x86)\I2N\IapsIMInterface\Config"
    Write-Output "IMConfigFilesFolder is '$IMConfigFilesFolder'"

    # specify list of files to restore for IM Interface
    $IMFilestorestore = @(
        "IMIAPS.xml"
    )

    $NDeliusIFConfigFilesFolder = "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config"
    Write-Output "NDeliusIFConfigFilesFolder is '$NDeliusIFConfigFilesFolder'"

    # specify list of files to restore for NDelius Interface
    $NDeliusFilestorestore = @(
        "IAPSCMSIF.xml",
        "IAPSCMSIF_DATA.XML",
        "NDELIUSIF.xml",
        "NDELIUSIF_DATA.XML"
    )

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Restore IM Interface Config files from latest backup"
    Write-Output "-----------------------------------------------------------------"
   
    foreach ($file in $IMFilestorestore) {

        $sourcefile = "$SourcePath$IMConfigFilesPrefix$file"
        $targetfile = "$IMConfigFilesFolder\$file"
        
        write-output "Restoring file '$sourcefile' to '$targetfile'"
        try {
           aws s3 cp $sourcefile $targetfile
        }
        catch [Exception] {
            Write-Host ("Error: Failed to restore IAPS IM Interface config file '$sourcefile' to '$targetfile' from s3")
            echo $_.Exception|format-list -force
        } 
    }

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Restore Latest NDelius Interface Config files"
    Write-Output "-----------------------------------------------------------------"

    foreach ($file in $NDeliusFilestorestore) {

        $sourcefile = "$SourcePath$NDeliusIFConfigFilesPrefix$file"
        $targetfile = "$NDeliusIFConfigFilesFolder\$file"
        write-output "Restoring file '$sourcefile' to '$targetfile'"

        try {
            aws s3 cp $sourcefile $targetfile
        }
        catch [Exception] {
            Write-Host ("Error: Failed to restore IAPS NDelius Interface config file '$sourcefile' to '$targetfile' from s3")
            echo $_.Exception|format-list -force
        } 
    }

    ##############################################
    # List backed up files to Backup Log
    ##############################################
    Write-Output "-----------------------------------------------------------------"
    Write-Output "Contents of target restore folders after copy"
    Write-Output "-----------------------------------------------------------------"
    dir $IMConfigFilesFolder
    dir $NDeliusIFConfigFilesFolder

    #Write-Output 'Starting Windows service IapsNDeliusInterfaceWinService'
    #start-service IapsNDeliusInterfaceWinService
    #Write-Output 'Starting Windows service IMIapsInterfaceWinService'
    #start-service IMIapsInterfaceWinService
    
}
catch [Exception] {
    Write-Host ("Error: Failed to restore IAPS config files from s3")
    echo $_.Exception|format-list -force
    #exit 1
} 
