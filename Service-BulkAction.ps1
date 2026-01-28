Write-Host "========================================"
Write-Host "        BULK SERVICE MANAGER"
Write-Host "========================================`n"

Write-Host "Select action:"
Write-Host "  1) START services"
Write-Host "  2) STOP services"
$choice = Read-Host "Enter 1 or 2"

switch ($choice) {
    "1" { $mode = "start"; $actionText = "START" }
    "2" { $mode = "stop";  $actionText = "STOP"  }
    default {
        Write-Host "Invalid selection. Please enter 1 or 2." -ForegroundColor Red
        exit
    }
}

# Ask for search text
$searchText = Read-Host "Enter text to search in service Name or DisplayName (e.g. Veeam)"

if ([string]::IsNullOrWhiteSpace($searchText)) {
    Write-Host "Empty search text. Aborting." -ForegroundColor Yellow
    exit
}

# Case-insensitive contains search
$pattern = "*$searchText*"

# Filter services based on action
if ($mode -eq "start") {
    $services = Get-Service | Where-Object {
        ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.Status -eq "Stopped"
    }
}
else {
    $services = Get-Service | Where-Object {
        ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.Status -eq "Running"
    }
}

if (!$services) {
    Write-Host "No applicable services found containing '$searchText'." -ForegroundColor Yellow
    exit
}

# Show services
Write-Host "`nServices that will be ${actionText}:" -ForegroundColor Cyan
$services | Select Name, DisplayName, Status | Format-Table -AutoSize

# Confirmation
$confirm = Read-Host "`nConfirm action $actionText? (y/n)"

if ($confirm -notmatch "^[yY]$") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Execute action
foreach ($svc in $services) {
    if ($mode -eq "start") {
        Write-Host "Starting $($svc.Name)..." -ForegroundColor Green
        Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "Stopping $($svc.Name)..." -ForegroundColor Red
        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`nOperation completed." -ForegroundColor Green
