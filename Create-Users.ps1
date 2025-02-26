# Script to Create AD Users from NewUsers.txt file
# Run with Administrative Privileges on a Domain Controller

# Define variables
$DomainName = "contoso.local"           # Change to your domain name
$NetBIOSName = "CONTOSO"               # Change to your NetBIOS name
$UsersOU = "OU=Users,DC=$NetBIOSName,DC=local"  # Target OU for new users
$DefaultPassword = "P@ssw0rd123!"      # Default password for new users
$InputFile = "C:\Scripts\NewUsers.txt" # Path to your input file

# Check if the input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "Error: NewUsers.txt file not found at $InputFile" -ForegroundColor Red
    Write-Host "Please create the file with format: FirstName,LastName,Username" -ForegroundColor Yellow
    exit 1
}

# Function to create user
function New-ADUserFromFile {
    param (
        [string]$FirstName,
        [string]$LastName,
        [string]$Username
    )
    
    try {
        # Construct user properties
        $FullName = "$FirstName $LastName"
        $SamAccountName = $Username
        $UPN = "$Username@$DomainName"
        $SecurePassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force

        # Check if user already exists
        if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue) {
            Write-Host "User $SamAccountName already exists. Skipping..." -ForegroundColor Yellow
            return
        }

        # Create new AD user
        Write-Host "Creating user: $FullName ($SamAccountName)" -ForegroundColor Green
        New-ADUser `
            -Name $FullName `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UPN `
            -Path $UsersOU `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Host "Successfully created $SamAccountName" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error creating user $SamAccountName : $_" -ForegroundColor Red
    }
}

# Main execution
try {
    Write-Host "Starting user creation process from $InputFile..." -ForegroundColor Green
    
    # Read the input file
    $users = Get-Content $InputFile | ForEach-Object { $_.Split(",") }
    
    # Process each user
    foreach ($user in $users) {
        if ($user.Count -ne 3) {
            Write-Host "Invalid line format in file: $($user -join ','). Expected FirstName,LastName,Username" -ForegroundColor Red
            continue
        }
        
        $FirstName = $user[0].Trim()
        $LastName = $user[1].Trim()
        $Username = $user[2].Trim()
        
        New-ADUserFromFile -FirstName $FirstName -LastName $LastName -Username $Username
    }
    
    Write-Host "User creation process completed!" -ForegroundColor Green
    
    # Verify created users
    Write-Host "Verifying created users..." -ForegroundColor Green
    $createdUsers = Get-ADUser -Filter * -SearchBase $UsersOU | Select-Object Name, SamAccountName
    $createdUsers | Format-Table -AutoSize
}
catch {
    Write-Host "Error processing file: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Script completed. Check above output for any errors." -ForegroundColor Yellow
