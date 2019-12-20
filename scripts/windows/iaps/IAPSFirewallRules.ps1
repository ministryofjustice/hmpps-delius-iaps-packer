$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Security Groups will be used to apply CIDR based restrictions
# Inbound Rules

# inbound 443,80, 8080, All ICMP v4, OpenSSH Server, WinRM 5985, TEst Debug 30443
New-NetFirewallRule -DisplayName "Allow Inbound 80" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 80
New-NetFirewallRule -DisplayName "Allow Inbound 443" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 443
New-NetFirewallRule -DisplayName "Allow Inbound 8080" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 8080
New-NetFirewallRule -DisplayName "Allow Inbound ALL ICMP v4" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow 
New-NetFirewallRule -DisplayName "Allow Inbound WinRM 5985" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 5985
New-NetFirewallRule -DisplayName "Allow Inbound OpenSSH Server (sshd)" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 22
New-NetFirewallRule -DisplayName "Allow Inbound 30443 TestDebug" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 30443

# Outbound Rules
New-NetFirewallRule -DisplayName "Allow Outbound Port 80" -Direction Outbound -RemotePort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port 8080" -Direction Outbound -RemotePort 8080 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port 443" -Direction Outbound -RemotePort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Oracle Client 1521" -Direction Outbound -RemotePort 1521 -Protocol TCP -Action Allow
# outbound oracle 1521, 443, 80, 
New-NetFirewallRule -DisplayName "Allow Outbound Oracle Client 1521" -Direction Outbound -RemotePort 1521 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port 443" -Direction Outbound -RemotePort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port 80" -Direction Outbound -RemotePort 80 -Protocol TCP -Action Allow
