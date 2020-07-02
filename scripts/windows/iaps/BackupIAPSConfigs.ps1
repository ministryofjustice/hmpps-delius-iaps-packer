$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Clear-Host

try {

    ################################################################################
    # Get the Environment Name from ec2 meta data 
    ################################################################################
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

    $s3bucketname = 'tf-eu-west-2-hmpps-' + $environmentName.Value + '-iaps-s3bucket'
    
    # get todays date and create unique folder name
    $foldername = Get-Date -Format 'yyyyMMdd_HHmmss'
    Write-Output $foldername

    $s3backuppath = "s3://$s3bucketname/$foldername"
    Write-Output "---Backing up files to S3 folder $s3backuppath"

    # specify list of files to backup
    $IMFilestobackup = @(
        "IMIAPS.xml"
    )

    $NDeliusFilestobackup = @(
        "IAPSCMSIF.xml",
        "IAPSCMSIF_DATA.XML",
        "NDELIUSIF.xml",
        "NDELIUSIF_DATA.XML"
    )

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Backup IMInterface Config files"
    Write-Output "-----------------------------------------------------------------"
    
    $IMConfigFilesFolder = "C:\Program Files (x86)\I2N\IapsIMInterface\Config"

    foreach ($file in $IMFilestobackup) {

        $sourcefile = "$IMConfigFilesFolder\$file"
        $targetfile =  "$s3backuppath/$file"

        write-output "Backing up file '$sourcefile' to '$s3backuppath'"
        aws s3 cp $sourcefile $targetfile

    }

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Backup NDelius Interface Config files"
    Write-Output "-----------------------------------------------------------------"

    $NDeliusIFConfigFilesFolder = "C:\Program Files (x86)\I2N\IapsNDeliusInterface\Config"

    foreach ($file in $NDeliusFilestobackup) {

        $sourcefile = "$NDeliusIFConfigFilesFolder\$file"
        $targetfile =  "$s3backuppath/$file"

        write-output "Backing up file '$sourcefile' to '$s3backuppath'"
        aws s3 cp $sourcefile $targetfile

    }

    Write-Output "-----------------------------------------------------------------"
    Write-Output "Contents of s3 bucket $s3backuppath/ after copy"
    Write-Output "-----------------------------------------------------------------"
    aws s3 ls $s3backuppath/

}
catch [Exception] {
    Write-Host ('Error: Failed to copy IAPS config files to s3')
    echo $_.Exception|format-list -force
    exit 1
} 
 
 
