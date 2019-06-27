$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$keyPrefix = "IAPS/"
# The local file path where files should be copied
$localPath = "C:\Setup\"

Read-S3Object -BucketName $env:ZAIZI_BUCKET -KeyPrefix $keyPrefix -Folder $localPath -Region $env:AWS_REGION

if( (Get-ChildItem $localPath | Measure-Object).Count -eq 0)
{
    echo "Error: Local Artefact Directory is empty"
    exit 1
}