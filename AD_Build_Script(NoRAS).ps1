# Script to Install and Configure Active Directory, DNS, and DHCP
# Run with Administrative Privileges

# Define variables
$DomainName = "contoso.local"           # Change to your desired domain name
$NetBIOSName = "CONTOSO"               # Change to your desired NetBIOS name
$SafeModePW = "SafeP@ssw0rd123!"       # Change to your preferred Safe Mode password
$DNSSuffix = "contoso.local"           # Change to match your domain
$DHCPStartRange = "192.168.1.100"      # Change to your desired DHCP start range
$DHCPEndRange = "192.168.1.200"        # Change to your desired DHCP end range
$DHCPSubnet = "192.168.1.0"            # Change to your subnet
$DHCPMask = "255.255.255.0"            # Change to your subnet mask
$DHCPGateway = "192.168.1.1"           # Change to your gateway

# Install required Windows Features
Write-Host "Installing Active Directory Domain Services..." -ForegroundColor Green
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "Installing DNS Server..." -ForegroundColor Green
Install-WindowsFeature -Name DNS -IncludeManagementTools

Write-Host "Installing DHCP Server..." -ForegroundColor Green
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Configure AD DS
Write-Host "Configuring Active Directory Domain Services..." -ForegroundColor Green
Import-Module ADDSDeployment
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBIOSName `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString $SafeModePW -AsPlainText -Force) `
    -Force:$true

# Wait for system to reboot after AD installation
Start-Sleep -Seconds 300

# Configure DNS
Write-Host "Configuring DNS Settings..." -ForegroundColor Green
Add-DnsServerPrimaryZone -Name $DNSSuffix -ZoneFile "$DNSSuffix.dns"
Set-DnsServerForwarder -IPAddress "8.8.8.8"  # Google DNS as forwarder

# Configure DHCP
Write-Host "Configuring DHCP Server..." -ForegroundColor Green
Add-DhcpServerv4Scope `
    -Name "Primary Scope" `
    -StartRange $DHCPStartRange `
    -EndRange $DHCPEndRange `
    -SubnetMask $DHCPMask `
    -State Active `
    -LeaseTime "8.00:00:00"

# Set DHCP Options
Set-DhcpServerv4OptionValue `
    -OptionId 3 `
    -Value $DHCPGateway `
    -ScopeId $DHCPSubnet

Set-DhcpServerv4OptionValue `
    -OptionId 6 `
    -Value $DHCPGateway `
    -ScopeId $DHCPSubnet

# Authorize DHCP in AD
Add-DhcpServerInDC

# Configure Security Settings
Write-Host "Configuring Security Settings..." -ForegroundColor Green
Set-DhcpServerv4Binding -BindingState $true -InterfaceAlias "Ethernet"

# Add basic OU structure
Write-Host "Creating Organizational Units..." -ForegroundColor Green
New-ADOrganizationalUnit -Name "Users" -Path "DC=$($NetBIOSName),DC=local"
New-ADOrganizationalUnit -Name "Computers" -Path "DC=$($NetBIOSName),DC=local"
New-ADOrganizationalUnit -Name "Servers" -Path "DC=$($NetBIOSName),DC=local"

# Create a basic admin user
Write-Host "Creating Administrative User..." -ForegroundColor Green
New-ADUser `
    -Name "AdminUser" `
    -GivenName "Admin" `
    -Surname "User" `
    -SamAccountName "AdminUser" `
    -UserPrincipalName "AdminUser@$DomainName" `
    -Path "OU=Users,DC=$($NetBIOSName),DC=local" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
    -Enabled $true

# Add user to Domain Admins group
Add-ADGroupMember -Identity "Domain Admins" -Members "AdminUser"

Write-Host "Active Directory Setup Complete!" -ForegroundColor Green
Write-Host "Please reboot the server to ensure all changes take effect." -ForegroundColor Yellow`
    -State Active `
    -LeaseTime "8.00:00:00"

# Set DHCP Options
Set-DhcpServerv4OptionValue `
    -OptionId 3 `
    -Value $DHCPGateway `
    -ScopeId $DHCPSubnet

Set-DhcpServerv4OptionValue `
    -OptionId 6 `
    -Value $DHCPGateway `
    -ScopeId $DHCPSubnet

# Authorize DHCP in AD
Add-DhcpServerInDC

# Configure Security Settings
Write-Host "Configuring Security Settings..." -ForegroundColor Green
Set-DhcpServerv4Binding -BindingState $true -InterfaceAlias "Ethernet"

# Add basic OU structure
Write-Host "Creating Organizational Units..." -ForegroundColor Green
New-ADOrganizationalUnit -Name "Users" -Path "DC=$($NetBIOSName),DC=local"
New-ADOrganizationalUnit -Name "Computers" -Path "DC=$($NetBIOSName),DC=local"
New-ADOrganizationalUnit -Name "Servers" -Path "DC=$($NetBIOSName),DC=local"

# Create a basic admin user
Write-Host "Creating Administrative User..." -ForegroundColor Green
New-ADUser `
    -Name "AdminUser" `
    -GivenName "Admin" `
    -Surname "User" `
    -SamAccountName "AdminUser" `
    -UserPrincipalName "AdminUser@$DomainName" `
    -Path "OU=Users,DC=$($NetBIOSName),DC=local" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
    -Enabled $true

# Add user to Domain Admins group
Add-ADGroupMember -Identity "Domain Admins" -Members "AdminUser"

Write-Host "Active Directory Setup Complete!" -ForegroundColor Green
Write-Host "Please reboot the server to ensure all changes take effect." -ForegroundColor Yellow
