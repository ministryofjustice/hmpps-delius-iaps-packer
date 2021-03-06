 

Import-Module -Name C:\Setup\Testing\poshspec -Verbose
#Import-Module -Name C:\ProgramData\chocolatey\lib\pester\tools\pester -Verbose

Describe 'Core Windows Services' {
    Describe 'MpsSvc (Windows Firewall) is Running' {
        Service MpsSvc Status { Should Be Running }
    } 
}

Describe 'AmazonCloudWatchAgent Windows Service' {
    It 'Service is Installed' {
        $service = Get-Service | Where { $_.Name -eq 'AmazonCloudWatchAgent' }
        $service | Should Not Be $null
    }

    It 'Service is set to Automatic StartType' {
        $service = Get-Service | Where { $_.Name -eq 'AmazonCloudWatchAgent' }
        $service.StartType | Should Be 'Automatic'
    }
} 
 
Describe 'IAPS Windows Services' {
    Describe 'nginx is Running' {
        Service nginx Status { Should Be Running }
    } 
    Describe 'IapsNDeliusInterfaceWinService is Running' {
        Service IapsNDeliusInterfaceWinService Status { Should Be Running }
    }   
    Describe 'IMIapsInterfaceWinService is Running' {
        Service IMIapsInterfaceWinService Status { Should Be Running }
    }     
}

Describe 'Firewall Profiles' {
    It 'Public Firewall Enabled' {
        Get-NetFirewallProfile -Name Public | Select -ExpandProperty Enabled {  Should Be $true }
    } 
    It 'Private Firewall Enabled' {
        Get-NetFirewallProfile -Name Private | Select -ExpandProperty Enabled {  Should Be $true }
    } 
    It 'Domain Firewall Enabled' {
        Get-NetFirewallProfile -Name Domain | Select -ExpandProperty Enabled {  Should Be $true }
    } 
}

Describe 'Firewall Rules' {
    
    It 'Firewall Rule Configured - Allow Inbound http 80' {
        $displayname = 'Allow Inbound http 80'
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Inbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'TCP' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be '860' }
    } 
    It 'Firewall Rule Configured - Allow Inbound https 443' {
        $displayname = 'Allow Inbound https 443'
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Inbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'TCP' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be '443' }
    } 
    It 'Firewall Rule Configured - Allow Inbound ALL ICMP v4' {
        $displayname = 'Allow Inbound ALL ICMP v4'
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Inbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'ICMPv4' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'RPC' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty IcmpType { Should Be '8' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty DynamicTarget { Should Be 'Any' }
    } 
    It 'Firewall Rule Configured - Allow Inbound WinRM 5985' {
        $displayname = 'Allow Inbound WinRM 5985'
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Inbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'TCP' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be '5985' }
    } 
    It 'Firewall Rule Configured - Allow Outbound Port http 80' {
        $displayname = 'Allow Outbound Port http 80'
       Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Outbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'TCP' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be '80' }
    } 
    It 'Firewall Rule Configured - Allow Outbound Port https 443' {
        $displayname = 'Allow Outbound Port https 443'
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Outbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'TCP' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be '443' }
    } 
    It 'Firewall Rule Configured - Allow Outbound Oracle 1521' {
        $displayname = 'Allow Outbound Oracle 1521'
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Enabled {Should Be $True}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Action {Should Be 'Allow'}
        Get-NetFirewallRule -DisplayName $displayname | Select -ExpandProperty Direction {Should Be 'Outbound'}
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Protocol { Should Be 'TCP' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty Localport { Should Be 'Any' }
        Get-NetFirewallRule -DisplayName $displayname | Get-NetFirewallPortFilter | Select -ExpandProperty RemotePort { Should Be '1521' }
    } 
}
