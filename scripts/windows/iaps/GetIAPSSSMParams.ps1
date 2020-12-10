$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    
    ###############################################################
    # Get creds from ParameterStore for this environment to connect
    ###############################################################
    Write-Host('Fetching IAPS Delius Credentials from SSM Parameter Store')
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

    $apacheds_iaps_user_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/apacheds/apacheds/iaps_user"
    $apacheds_iaps_user = Get-SSMParameter -Name $apacheds_iaps_user_SSMPath -WithDecryption $true
    [string]::Format(“apacheds_iaps_user: {0}”,$apacheds_iaps_user.Value)

    $apacheds_iaps_user_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/apacheds/apacheds/iaps_user_password"
    $apacheds_iaps_user_password = Get-SSMParameter -Name $apacheds_iaps_user_password_SSMPath -WithDecryption $true
    [string]::Format(“apacheds_iaps_user_password: {0}”,$apacheds_iaps_user_password.Value)

    $iaps_imcentral_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_iapscentral_password"
    $iaps_imcentral_password = Get-SSMParameter -Name $iaps_imcentral_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_imcentral_password: {0}”,$iaps_imcentral_password.Value)

    $iaps_iapscentral_password_coded_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_iapscentral_password_coded"
    $iaps_iapscentral_password_coded = Get-SSMParameter -Name $iaps_iapscentral_password_coded_SSMPath -WithDecryption $true
    [string]::Format(“iaps_iapscentral_password_coded: {0}”,$iaps_iapscentral_password_coded.Value)

    $iaps_im_soapserver_odbc_database_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_database"
    $iaps_im_soapserver_odbc_database = Get-SSMParameter -Name $iaps_im_soapserver_odbc_database_SSMPath -WithDecryption $true
    [string]::Format(“iaps_im_soapserver_odbc_database: {0}”,$iaps_im_soapserver_odbc_database.Value)

    $iaps_im_soapserver_odbc_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_password"
    $iaps_im_soapserver_odbc_password = Get-SSMParameter -Name $iaps_im_soapserver_odbc_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_im_soapserver_odbc_password: {0}”,$iaps_im_soapserver_odbc_password.Value)

    $iaps_im_soapserver_odbc_server_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_server"
    $iaps_im_soapserver_odbc_server = Get-SSMParameter -Name $iaps_im_soapserver_odbc_server_SSMPath -WithDecryption $true
    [string]::Format(“iaps_im_soapserver_odbc_server: {0}”,$iaps_im_soapserver_odbc_server.Value)

    $iaps_im_soapserver_odbc_uid_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_im_soapserver_odbc_uid"
    $iaps_im_soapserver_odbc_uid = Get-SSMParameter -Name $iaps_im_soapserver_odbc_uid_SSMPath -WithDecryption $true
    [string]::Format(“iaps_im_soapserver_odbc_uid: {0}”,$iaps_im_soapserver_odbc_uid.Value)

    $iaps_local_users_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_local_users"
    $iaps_local_users = Get-SSMParameter -Name $iaps_local_users_SSMPath -WithDecryption $true
    [string]::Format(“iaps_local_users: {0}”,$iaps_local_users.Value)

    $iaps_local_users_onetime_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_local_users_onetime_password"
    $iaps_local_users_onetime_password = Get-SSMParameter -Name $iaps_local_users_onetime_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_local_users_onetime_password: {0}”,$iaps_local_users_onetime_password.Value)

    $iaps_ndelius_soap_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_ndelius_soap_password"
    $iaps_ndelius_soap_password = Get-SSMParameter -Name $iaps_ndelius_soap_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_ndelius_soap_password: {0}”,$iaps_ndelius_soap_password.Value)

    $iaps_ndelius_soap_password_coded_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_ndelius_soap_password_coded"
    $iaps_ndelius_soap_password_coded = Get-SSMParameter -Name $iaps_ndelius_soap_password_coded_SSMPath -WithDecryption $true
    [string]::Format(“iaps_ndelius_soap_password_coded: {0}”,$iaps_ndelius_soap_password_coded.Value)

    $iaps_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_password"
    $iaps_password = Get-SSMParameter -Name $iaps_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_password: {0}”,$iaps_password.Value)

    $iaps_pcms_oracle_replica_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_pcms_oracle_replica_password"
    $iaps_pcms_oracle_replica_password = Get-SSMParameter -Name $iaps_pcms_oracle_replica_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_pcms_oracle_replica_password: {0}”,$iaps_pcms_oracle_replica_password.Value)

    $iaps_pcms_oracle_replica_password_coded_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_pcms_oracle_replica_password_coded"
    $iaps_pcms_oracle_replica_password_coded = Get-SSMParameter -Name $iaps_pcms_oracle_replica_password_coded_SSMPath -WithDecryption $true
    [string]::Format(“iaps_pcms_oracle_replica_password_coded: {0}”,$iaps_pcms_oracle_replica_password_coded.Value)

    $iaps_pcms_oracle_shadow_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_pcms_oracle_shadow_password"
    $iaps_pcms_oracle_shadow_password = Get-SSMParameter -Name $iaps_pcms_oracle_shadow_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_pcms_oracle_shadow_password: {0}”,$iaps_pcms_oracle_shadow_password.Value)

    $iaps_pcms_oracle_shadow_password_coded_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_pcms_oracle_shadow_password_coded"
    $iaps_pcms_oracle_shadow_password_coded = Get-SSMParameter -Name $iaps_pcms_oracle_shadow_password_coded_SSMPath -WithDecryption $true
    [string]::Format(“iaps_pcms_oracle_shadow_password_coded: {0}”,$iaps_pcms_oracle_shadow_password_coded.Value)

    $iaps_rds_admin_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_rds_admin_password"
    $iaps_rds_admin_password = Get-SSMParameter -Name $iaps_rds_admin_password_SSMPath -WithDecryption $true
    [string]::Format(“iaps_rds_admin_password: {0}”,$iaps_rds_admin_password.Value)

    $iaps_smtpp_password_coded_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_smtp_password_coded"
    $iaps_smtpp_password_coded = Get-SSMParameter -Name $iaps_smtpp_password_coded_SSMPath -WithDecryption $true
    [string]::Format(“iaps_smtpp_password_coded: {0}”,$iaps_smtpp_password_coded.Value)

    $iaps_smtp_password_coded_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_smtp_password_coded"
    $iaps_smtp_password_coded = Get-SSMParameter -Name $iaps_smtp_password_coded_SSMPath -WithDecryption $true
    [string]::Format(“iaps_smtp_password_coded: {0}”,$iaps_smtp_password_coded.Value)

    $iaps_user_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/iaps/iaps/iaps_user"
    $iaps_user = Get-SSMParameter -Name $iaps_user_SSMPath -WithDecryption $true
    [string]::Format(“iaps_user: {0}”,$iaps_user.Value)

}
catch [Exception] {
    Write-Host ('Failed to get ssm ParameterStore values')
    echo $_.Exception|format-list -force
    Exit 1
}