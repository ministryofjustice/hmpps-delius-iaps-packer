 # To get a list of properties run:
#  Get-OdbcDsn -Name  PCMSIFIAPS | select  -ExpandProperty Attribute

# Name                           Value                                                                                                                                                                      
# ----                           -----                                                                                                                                                                      
# Password                                                                                                                                                                                                  
# StatementCache                 F                                                                                                                                                                          
# NumericSetting                 NLS                                                                                                                                                                        
# Description                                                                                                                                                                                               
# BindAsFLOAT                    F                                                                                                                                                                          
# UserID                                                                                                                                                                                                    
# Application Attributes         T                                                                                                                                                                          
# FailoverDelay                  10                                                                                                                                                                         
# DisableDPM                     F                                                                                                                                                                          
# ServerName                     IAPSNR                                                                                                                                                                     
# BatchAutocommitMode            IfAllSuccessful                                                                                                                                                            
# FailoverRetryCount             10                                                                                                                                                                         
# MaxTokenSize                   8192                                                                                                                                                                       
# EXECSyntax                     F                                                                                                                                                                          
# DisableRULEHint                T                                                                                                                                                                          
# UseOCIDescribeAny              F                                                                                                                                                                          
# ForceWCHAR                     F                                                                                                                                                                          
# Attributes                     W                                                                                                                                                                          
# EXECSchemaOpt                                                                                                                                                                                             
# AggregateSQLType               FLOAT                                                                                                                                                                      
# Lobs                           T                                                                                                                                                                          
# QueryTimeout                   T                                                                                                                                                                          
# MetadataIdDefault              F                                                                                                                                                                          
# MaxLargeData                   0                                                                                                                                                                          
# DSN                            PCMSIFIAPS                                                                                                                                                                 
# CloseCursor                    F                                                                                                                                                                          
# DisableMTS                     T                                                                                                                                                                          
# Failover                       T                                                                                                                                                                          
# ResultSets                     T                                                                                                                                                                          
# CacheBufferSize                20                                                                                                                                                                         
# FetchBufferSize                64000                                                                                                                                                                      
# SQLTranslateErrors             F                                                                                                                                                                          
# BindAsDATE                     F                                                                                                                                                                          

$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

try {
    Write-Host('Creating ODBC DSNs')
    Import-Module Wdac
    $OdbcDriver = Get-OdbcDriver -Name 'Oracle in OraClient12Home1_32bit' -Platform 32-bit
    If(!$OdbcDriver.Count) # Only continue if 1 SQL ODBC driver is installed
    { 
        Add-OdbcDsn -Name 'PCMSIFIAPS' `
                    -DriverName $OdbcDriver.Name `
                    -Platform 32-bit `
                    -DsnType System `
                    -SetPropertyValue @("DataSourceName=PCMSIFIAPS", "ServerName=IAPSNR") 
        
        Add-OdbcDsn -Name 'PCMSSHADOW' `
                    -DriverName $OdbcDriver.Name `
                    -Platform 32-bit `
                    -DsnType System `
                    -SetPropertyValue @("DataSourceName=PCMSSHADOW", "ServerName=PCMSSHADOW") 
   
    }
}
catch [Exception] {
    Write-Host ('Failed to Create ODBC DSNs')
    echo $_.Exception|format-list -force
    exit 1
} 
