$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Security Groups will be used to apply CIDR based restrictions

# Inbound Rules (http/80, https/443, All ICMP v4, WinRM 5985)
New-NetFirewallRule -DisplayName "Allow Inbound http 80" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 80
New-NetFirewallRule -DisplayName "Allow Inbound https 443" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 443
New-NetFirewallRule -DisplayName "Allow Inbound ALL ICMP v4" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow 
New-NetFirewallRule -DisplayName "Allow Inbound WinRM 5985" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 5985

#New-NetFirewallRule -DisplayName "Allow Inbound OpenSSH Server (sshd)" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 22
#New-NetFirewallRule -DisplayName "Allow Inbound 30443 TestDebug" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 30443
#New-NetFirewallRule -DisplayName "Allow Inbound 8080" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 8080

# Outbound Rules (http,https,oracle)
New-NetFirewallRule -DisplayName "Allow Outbound Port http 80" -Direction Outbound -RemotePort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port https 443" -Direction Outbound -RemotePort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Oracle 1521" -Direction Outbound -RemotePort 1521 -Protocol TCP -Action Allow

# outbound oracle 1521, 443, 80, 
#New-NetFirewallRule -DisplayName "Allow Outbound Oracle Client 1521" -Direction Outbound -RemotePort 1521 -Protocol TCP -Action Allow
#New-NetFirewallRule -DisplayName "Allow Outbound Port 8080" -Direction Outbound -RemotePort 8080 -Protocol TCP -Action Allow
#New-NetFirewallRule -DisplayName "Allow Outbound Port 443" -Direction Outbound -RemotePort 443 -Protocol TCP -Action Allow
#New-NetFirewallRule -DisplayName "Allow Outbound Port 80" -Direction Outbound -RemotePort 80 -Protocol TCP -Action Allow
