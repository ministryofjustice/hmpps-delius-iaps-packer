$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host ('==================================================')
Write-Host ('Updating Region Config')
Write-Host ('==================================================')

Write-Host ('---------region config before update-------------')
try {
    Get-WinSystemLocale
    Get-WinHomeLocation
    Get-WinUserLanguageList
}
catch [Exception] {
    Write-Host ('Exception getting region config')
    echo $_.Exception|format-list -force
    exit 1
}

try {
    Set-WinSystemLocale -SystemLocale en-GB
}
catch [Exception] {
    Write-Host ('Set-WinSystemLocale: Exception')
    echo $_.Exception|format-list -force
    exit 1
}

try {
    Set-WinHomeLocation -GeoId 242
}
catch [Exception] {
    Write-Host ('Set-WinHomeLocation:Exception')
    echo $_.Exception|format-list -force
    exit 1
}

try {
    Set-WinUserLanguageList -LanguageList (New-WinUserLanguageList -Language en-GB) -Force 
}
catch [Exception] {
    Write-Host ('Set-WinUserLanguageList:Exception')
    echo $_.Exception|format-list -force
    exit 1
}

Write-Host ('---------region config post update-------------')
try {
    Get-WinSystemLocale
    Get-WinHomeLocation
    Get-WinUserLanguageList
}
catch [Exception] {
    Write-Host ('Exception getting region config')
    echo $_.Exception|format-list -force
    exit 1
} 

