# LocalADDeployment
# Active Directory Environment Setup with PowerShell

This repository contains PowerShell scripts to set up a complete Active Directory (AD) environment on Windows Server (2019, 2022, or 2025), including AD DS, DNS, DHCP, Remote Access Services (RAS) with VPN, domain joining, and user creation from a text file.

## Prerequisites
- Windows Server 2019, 2022, or 2025 installed
- Administrative privileges on the server
- Static IP address configured on the server
- Two network adapters (recommended for RAS/VPN: one internal, one external)
- Network connectivity to the internet and clients

## Step-by-Step Setup Process

### Step 1: Prepare the Environment
1. **Log in** to your Windows Server with an administrative account.
2. **Set a static IP** on the server (e.g., `192.168.1.10`).
3. **Open PowerShell** as Administrator:
   - Right-click Start > Windows PowerShell (Admin).

### Step 2: Install and Configure AD, DNS, DHCP, and RAS
1. **Download or Create the Script**:
   - Save the script as `Setup-AD-DHCP-DNS-RAS.ps1` from this repository.
2. **Customize Variables**:
   - Open the script in a text editor (e.g., Notepad or VS Code).
   - Update the following variables to match your environment:
     ```powershell
     $DomainName = "contoso.local"
     $NetBIOSName = "CONTOSO"
     $SafeModePW = "SafeP@ssw0rd123!"
     $DHCPStartRange = "192.168.1.100"
     $DHCPEndRange = "192.168.1.200"
     $DHCPSubnet = "192.168.1.0"
     $DHCPMask = "255.255.255.0"
     $DHCPGateway = "192.168.1.1"
     $VPNServerIP = "192.168.1.10"
     $VPNRangeStart = "192.168.1.210"
     $VPNRangeEnd = "192.168.1.250"
