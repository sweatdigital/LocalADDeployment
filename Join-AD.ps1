# Script to Join Windows Server to Active Directory Domain
# Compatible with Windows Server 2019, 2022, and 2025
# Run with Administrative Privileges

# Define variables
$DomainName = "contoso.local"              # Change to your domain name
$DomainAdminUser = "CONTOSO\AdminUser"     # Change to your domain admin username
$DomainAdminPassword = "P@ssw0rd123!"      # Change to your domain admin password
$ComputerName = "Server01"                 # Change to desired computer name (optional)

# Function to check if server is already domain-joined
function Test-DomainMembership {
    try {
        $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
        if ($computerSystem.PartOfDomain -and $computerSystem.Domain -eq $DomainName) {
            Write-Host "Server is already joined to $DomainName" -ForegroundColor Yellow
            return $true
        }
        return $false
    }
    catch {
        Write-Host "Error checking domain membership: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    # Check current domain status
    Write-Host "Checking current domain membership..." -ForegroundColor Green
    if (Test-DomainMembership) {
        exit
    }

    # Set computer name (optional)
    if ($ComputerName) {
        Write-Host "Setting computer name to $ComputerName..." -ForegroundColor Green
        Rename-Computer -NewName $ComputerName -Force -Restart:$false
    }

    # Ensure network connectivity to domain
    Write-Host "Testing connectivity to domain..." -ForegroundColor Green
    if (-not (Test-Connection -ComputerName $DomainName -Count 2 -Quiet)) {
        throw "Cannot reach domain controller. Check network connectivity."
    }

    # Convert password to secure string
    $securePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($DomainAdminUser, $securePassword)

    # Join the domain
    Write-Host "Joining computer to $DomainName..." -ForegroundColor Green
    Add-Computer `
        -DomainName $DomainName `
        -Credential $credential `
        -Restart:$true `
        -Force `
        -ErrorAction Stop

    Write-Host "Domain join initiated successfully!" -ForegroundColor Green
    Write-Host "Server will restart to complete the domain join process." -ForegroundColor Yellow

    # Wait a moment before restart
    Start-Sleep -Seconds 5
}
catch {
    Write-Host "Error joining domain: $_" -ForegroundColor Red
    Write-Host "Common issues to check:" -ForegroundColor Yellow
    Write-Host "- Valid domain admin credentials" -ForegroundColor Yellow
    Write-Host "- Network connectivity to domain controller" -ForegroundColor Yellow
    Write-Host "- DNS settings pointing to domain controller" -ForegroundColor Yellow
    exit 1
}

# Post-join verification (runs after reboot if you run script again)
if (Test-DomainMembership) {
    Write-Host "Verification: Successfully joined to $DomainName" -ForegroundColor Green
    
    # Display domain join information
    $computerInfo = Get-WmiObject -Class Win32_ComputerSystem
    Write-Host "Computer Name: $($computerInfo.Name)" -ForegroundColor Cyan
    Write-Host "Domain: $($computerInfo.Domain)" -ForegroundColor Cyan
}
