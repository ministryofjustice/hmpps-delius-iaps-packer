 

Import-Module -Name C:\Setup\Testing\poshspec -Verbose
#Import-Module -Name C:\ProgramData\chocolatey\lib\pester\tools\pester -Verbose
 
Describe 'Packages Installed' {
    Registry 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip' { Should Exist }
    Registry 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox 71.0 (x64 en-US)' { Should Exist }
    
    Describe 'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219' {
        Registry 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1D8E6291-B0D5-35EC-8441-6616F567A0F7}'  { Should Exist }
        Registry 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1D8E6291-B0D5-35EC-8441-6616F567A0F7}' 'DisplayVersion' { Should Be '10.0.40219' }
    }

    Describe 'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161' {
        Registry 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}'  { Should Exist }
        Registry 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}' 'DisplayVersion' { Should Be '9.0.30729.6161' }
    }

    Describe 'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161' {
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{9BE518E6-ECC6-35A9-88E4-87755C07200F}'  { Should Exist }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{9BE518E6-ECC6-35A9-88E4-87755C07200F}' 'DisplayVersion' { Should Be '9.0.30729.6161' }
    }

    Describe 'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161' {
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}'  { Should Exist }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}' 'DisplayVersion' { Should Be '10.0.40219' }
    }
}

Describe 'Windows Features Installed' {
    ServerFeature FileAndStorage-Services { Should be $true }
    ServerFeature File-Services { Should be $true }
    ServerFeature Storage-Services { Should be $true }
    ServerFeature NET-Framework-Features { Should be $true }
    ServerFeature NET-Framework-Core { Should be $true }
    ServerFeature NET-Framework-45-Features { Should be $true }
    ServerFeature NET-Framework-45-Core { Should be $true }
    ServerFeature NET-WCF-Services45 { Should be $true }
    ServerFeature NET-WCF-TCP-PortSharing45 { Should be $true }
    ServerFeature FS-SMB1 { Should be $true }
    ServerFeature User-Interfaces-Infra { Should be $true }
    ServerFeature Server-Gui-Mgmt-Infra { Should be $true }
    ServerFeature Server-Gui-Shell { Should be $true }
    ServerFeature PowerShellRoot { Should be $true }
    ServerFeature PowerShell { Should be $true }
    ServerFeature PowerShell-V2 { Should be $true }
    ServerFeature PowerShell-ISE { Should be $true }
    ServerFeature WoW64-Support { Should be $true }
}

Describe 'Oracle Client Installed' {
    File 'C:\app\client\Administrator\product\12.1.0\client_1\network\admin\sqlnet.ora' { Should -Exist }

    $SEL = Select-String -Path 'C:\app\client\Administrator\product\12.1.0\client_1\network\admin\sqlnet.ora' -Pattern "SQLNET.AUTHENTICATION_SERVICES"
    if ($SEL -ne $null)
    {
        $result = $True
    }
    else
    {
        $result = $false
    }
    
    $result | Should Be $True 

    $SEL = Select-String -Path 'C:\app\client\Administrator\product\12.1.0\client_1\network\admin\sqlnet.ora' -Pattern "NAMES.DIRECTORY_PATH="
    if ($SEL -ne $null)
    {
        $result = $True
    }
    else
    {
        $result = $false
    }
    
    $result | Should Be $True 
    
    File 'C:\app\client\Administrator\product\12.1.0\client_1\network\admin\tnsnames.ora' { Should -Exist }

    Registry 'HKLM:\SOFTWARE\Wow6432Node\ORACLE' 'inst_loc' { Should Be 'C:\Program Files (x86)\Oracle\Inventory' }

    Registry 'HKLM:\SOFTWARE\Wow6432Node\ORACLE\KEY_OraClient12Home1_32bit' 'NLS_LANG' { Should Be 'ENGLISH_UNITED KINGDOM.WE8MSWIN1252' }
    Registry 'HKLM:\SOFTWARE\Wow6432Node\ORACLE\KEY_OraClient12Home1_32bit' 'ORACLE_HOME_NAME' { Should Be 'OraClient12Home1_32bit' }
}

Describe 'SqlDeveloper Client Installed' {
    File 'C:\sqldeveloper-4.1.3.20.78-x64\sqldeveloper\sqldeveloper.exe' { Should -Exist }
}

Describe 'ODBC DSNs Configured' {
    Describe 'PCMSIFIAPS ODBC DSN' {
        Registry 'HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources' 'PCMSIFIAPS' { Should Be 'Oracle in OraClient12Home1_32bit' }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\PCMSIFIAPS' 'DSN' { Should Be 'PCMSIFIAPS' }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\PCMSIFIAPS' 'ServerName' { Should Be 'IAPSNR' }

    }

    Describe 'PCMSSHADOW ODBC DSN' {
        Registry 'HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources' 'PCMSSHADOW' { Should Be 'Oracle in OraClient12Home1_32bit' }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\PCMSSHADOW' 'DSN' { Should Be 'PCMSSHADOW' }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\PCMSSHADOW' 'ServerName' { Should Be 'PCMSSHADOW' }
    }
}

Describe 'NDelius Interface Installed' {
    Describe 'IapsNDeliusInterface' {
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{1D840587-A529-4E4D-A9AB-2FF77CA42A78}'  { Should Exist }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{1D840587-A529-4E4D-A9AB-2FF77CA42A78}' 'DisplayVersion' { Should Be '1.1.3' }
    }
}

Describe 'IM Interface Installed' {
    Describe 'IMIapsInterface' {
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{686454DB-90FA-4D0E-A626-217236BA1047}'  { Should Exist }
        Registry 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{686454DB-90FA-4D0E-A626-217236BA1047}' 'DisplayVersion' { Should Be '1.0.0' }
    }
}
