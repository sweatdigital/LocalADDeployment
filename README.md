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
     ```
3. **Run the Script**:
   - In PowerShell, navigate to the script directory:
     ```powershell
     cd C:\path\to\script
     ```
   - Execute the script:
     ```powershell
     .\Setup-AD-DHCP-DNS-RAS.ps1
     ```
  ## Watch the Setup Demo
![Setup Demo](https://github.com/sweatdigital/LocalADDeployment/raw/main/demo.gif)

4. **Wait for Reboot**:
   - The server will reboot automatically after AD installation.
   - Log back in after the reboot to continue configuration.

5. **Verify Services**:
   - Check AD DS: `Get-ADDomain`
   - Check DNS: `Get-DnsServerZone`
   - Check DHCP: `Get-DhcpServerv4Scope`
   - Check RAS: `Get-RemoteAccess`

### Step 3: Join Additional Servers to the Domain
1. **Download or Create the Script**:
   - Save the script as `Join-AD.ps1` from this repository.
2. **Customize Variables**:
   - Update the following:
     ```powershell
     $DomainName = "contoso.local"
     $DomainAdminUser = "CONTOSO\AdminUser"
     $DomainAdminPassword = "P@ssw0rd123!"
     $ComputerName = "Server01"  # Optional
     ```
3. **Run the Script**:
   - On the server to join, run in an elevated PowerShell:
     ```powershell
     .\Join-AD.ps1
     ```
4. **Wait for Reboot**:
   - The server will restart to complete the domain join.
5. **Verify Join**:
   - After reboot, run the script again to confirm:
     ```powershell
     .\Join-AD.ps1
     ```

### Step 4: Create Users from a Text File
1. **Prepare the Input File**:
   - Create a file named `NewUsers.txt` (e.g., `C:\Scripts\NewUsers.txt`).
   - Use this format (comma-separated, no spaces after commas):
     ```
     FirstName,LastName,Username
     John,Doe,jdoe
     Jane,Smith,jsmith
     ```
2. **Download or Create the Script**:
   - Save the script as `Create-Users.ps1` from this repository.
3. **Customize Variables**:
   - Update the following:
     ```powershell
     $DomainName = "contoso.local"
     $NetBIOSName = "CONTOSO"
     $UsersOU = "OU=Users,DC=CONTOSO,DC=local"
     $DefaultPassword = "P@ssw0rd123!"
     $InputFile = "C:\Scripts\NewUsers.txt"
     ```
4. **Run the Script**:
   - Execute on the domain controller:
     ```powershell
     .\Create-Users.ps1
     ```
5. **Verify Users**:
   - Check Active Directory Users and Computers for new users in the "Users" OU.
   - Or use PowerShell: `Get-ADUser -Filter * -SearchBase "OU=Users,DC=CONTOSO,DC=local"`

### Step 5: Test the Environment
1. **Test DHCP**:
   - Connect a client device and verify it receives an IP in the range `192.168.1.100-200`.
2. **Test DNS**:
   - Run `nslookup contoso.local` from a client to verify DNS resolution.
3. **Test AD**:
   - Log in to a joined server with `CONTOSO\AdminUser`.
4. **Test VPN**:
   - Configure a VPN client with:
     - Server: `192.168.1.10`
     - Type: L2TP/IPsec
     - PSK: `YourPSKHere`
     - Username: `CONTOSO\VPNUser`
     - Password: `VPNP@ssw0rd123!`
   - Connect and verify IP in range `192.168.1.210-250`.

## Security Recommendations
- Change all default passwords immediately after setup.
- Configure firewall rules for VPN (e.g., UDP 1701 for L2TP).
- Use certificates instead of PSK for VPN in production.
- Implement Group Policies for enhanced security.

## Troubleshooting
- **DNS Issues**: Ensure the server’s primary DNS points to itself (e.g., `192.168.1.10`).
- **DHCP Not Working**: Verify the scope is active and authorized (`Get-DhcpServerInDC`).
- **VPN Fails**: Check firewall and NAT settings on the router.
- **Domain Join Fails**: Confirm network connectivity and credentials.

## Files in This Repository
- `Setup-AD-DHCP-DNS-RAS.ps1`: Configures AD, DNS, DHCP, and RAS.
- `Join-AD.ps1`: Joins a server to the domain.
- `Create-Users.ps1`: Creates users from `NewUsers.txt`.
- `NewUsers.txt`: Sample user input file (create your own).

## Add User Process
The `Create-Users.ps1` script streamlines adding users to your AD environment, making it versatile for various scenarios:
1. **Prepare `NewUsers.txt`**:
   - Format: `FirstName,LastName,Username` (e.g., `John,Doe,jdoe`).
   - Save to `C:\Scripts\NewUsers.txt` (or adjust path in the script).
2. **Customize the Script**:
   - Edit variables like `$DomainName`, `$NetBIOSName`, and `$InputFile` to match your setup.
3. **Execute the Script**:
   - Run `.\Create-Users.ps1` on the domain controller in an elevated PowerShell session.
4. **Verify Users**:
   - Check the "Users" OU in AD Users and Computers or run:
     ```powershell
     Get-ADUser -Filter * -SearchBase "OU=Users,DC=CONTOSO,DC=local"
     ```
   - Users will be created with the default password, requiring a change at first login.

This process can be used for:
- **Setup of New Environments for Business**: Efficiently onboard employees in a new office or company by automating user creation.
- **Exploring Building a Homelab**: Experiment with AD user management in a personal lab environment.

For a homelab, I recommend using a spare desktop, i.e., Dell Precision T3610 or higher with i7 or Xen v3 processor with a min of 96GB with 2 x 1TB (or higher) SSD's on which you can install:
- **(Hypervisor 1) Proxmox VE 8**: A powerful, open-source virtualization platform.
- **(Hypervisor 2) VirtualBox**: A simpler option for your laptop or machine.

## Contributing
Feel free to fork this repository, submit issues, or create pull requests with enhancements!

## License
This project is licensed under the MIT License.
