$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    ##############################################
    # Get the Environment Name from ec2 meta data 
    ##############################################
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

    ##############################################
    # Calculate S3 Bucket Name 
    ##############################################
    $s3bucketname = 'tf-eu-west-2-hmpps-' + $environmentName.Value + '-iaps-s3bucket'
    
    ##############################################
    # Calculate Date Stamped Folder Name 
    ##############################################
    # get todays date and create unique folder name
    $foldername = Get-Date -Format 'yyyyMMdd_HHmmss'
    Write-Output $foldername

    $s3backuppath = "s3://$s3bucketname/$foldername"
    Write-Output "---Backing up files to S3 folder $s3backuppath"

    ##############################################
    # Backup Files to S3
    ##############################################
    # specify list of files to backup
    $IMConfigFilesFolder = "C:\Program Files (x86)\I2N\IapsIMInterface\Config"
    $IMConfigFilesPrefix = "IapsIMInterface"

    $IMFilestobackup = @(
        "IMIAPS.xml"
    )

    $NDeliusIFConfigFilesFolder = "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config"
    $NDeliusIFConfigFilesPrefix = "IapsNDeliusInterface"

    $NDeliusFilestobackup = @(
        "IAPSCMSIF.xml",
        "IAPSCMSIF_DATA.XML",
        "NDELIUSIF.xml",
        "NDELIUSIF_DATA.XML"
    )

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Backup IM Interface Config files"
    Write-Output "-----------------------------------------------------------------"
   
    foreach ($file in $IMFilestobackup) {

        $sourcefile = "$IMConfigFilesFolder\$file"
        $targetfile =  "$s3backuppath/$IMConfigFilesPrefix/$file"

        write-output "Backing up file '$sourcefile' to '$s3backuppath'"
        try {
            aws s3 cp $sourcefile $targetfile
        }
        catch [Exception] {
            Write-Host ("Error: Failed to copy IAPS config file '$sourcefile' to s3")
            echo $_.Exception|format-list -force
            
        } 
    }

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Backup NDelius Interface Config files"
    Write-Output "-----------------------------------------------------------------"

    foreach ($file in $NDeliusFilestobackup) {

        $sourcefile = "$NDeliusIFConfigFilesFolder\$file"
        $targetfile =  "$s3backuppath/$NDeliusIFConfigFilesPrefix/$file"

        write-output "Backing up file '$sourcefile' to '$s3backuppath'"
        aws s3 cp $sourcefile $targetfile

    }

    ##############################################
    # List backed up files to Backup Log
    ##############################################
    Write-Output "-----------------------------------------------------------------"
    Write-Output "Contents of s3 bucket $s3backuppath/ after copy"
    Write-Output "-----------------------------------------------------------------"
    aws s3 ls $s3backuppath/$IMConfigFilesPrefix/
    aws s3 ls $s3backuppath/$NDeliusIFConfigFilesPrefix/

}
catch [Exception] {
    Write-Host ("Error: Failed to copy IAPS config files to s3")
    echo $_.Exception|format-list -force
    #exit 1
} 
 
 
 
