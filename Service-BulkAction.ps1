function Pause-Return {
    Write-Host "`nPress any key to return to the menu..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$LogFile = "$PSScriptRoot\ServiceBulkManager.log"

do {
    Clear-Host

    Write-Host "========================================"
    Write-Host "        BULK SERVICE MANAGER"
    Write-Host "========================================`n"

    Write-Host "Main actions:"
    Write-Host "  1) START services"
    Write-Host "  2) STOP services"
    Write-Host "  3) STATUS services"

    Write-Host "`nOther actions:"
    Write-Host "  4) BULK ENABLE services (Automatic)"
    Write-Host "  5) BULK ENABLE services (Delayed start)"
    Write-Host "  6) BULK MANUAL services"
    Write-Host "  7) BULK DISABLE services"

    Write-Host "`n  0) EXIT"

    $choice = Read-Host "`nEnter option number"

    if ($choice -eq "0") {
        Write-Host "Exiting..." -ForegroundColor Yellow
        break
    }

    switch ($choice) {
        "1" { $mode = "start";   $actionText = "START" }
        "2" { $mode = "stop";    $actionText = "STOP" }
        "3" { $mode = "status";  $actionText = "STATUS" }
        "4" { $mode = "auto";    $actionText = "ENABLE (AUTOMATIC)" }
        "5" { $mode = "delayed"; $actionText = "ENABLE (DELAYED START)" }
        "6" { $mode = "manual";  $actionText = "MANUAL" }
        "7" { $mode = "disable"; $actionText = "DISABLE" }
        default {
            Write-Host "Invalid selection." -ForegroundColor Red
            Pause-Return
            continue
        }
    }

    $searchText = Read-Host "Enter text to search in service Name or DisplayName (e.g. Veeam)"

    if ([string]::IsNullOrWhiteSpace($searchText)) {
        Write-Host "Empty search text. Aborting." -ForegroundColor Yellow
        Pause-Return
        continue
    }

    $pattern = "*$searchText*"

    switch ($mode) {

        "start" {
            $services = Get-Service | Where-Object {
                ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.Status -eq "Stopped"
            }
        }

        "stop" {
            $services = Get-Service | Where-Object {
                ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.Status -eq "Running"
            }
        }

        "status" {
            $services = Get-Service | Where-Object {
                $_.Name -like $pattern -or $_.DisplayName -like $pattern
            }
        }

        "auto" {
            $services = Get-Service | Where-Object {
                ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.StartType -ne "Automatic"
            }
            $targetStartType = "Automatic"
        }

        "delayed" {
            $services = Get-Service | Where-Object {
                ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.StartType -ne "AutomaticDelayedStart"
            }
            $targetStartType = "AutomaticDelayedStart"
        }

        "manual" {
            $services = Get-Service | Where-Object {
                ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.StartType -ne "Manual"
            }
            $targetStartType = "Manual"
        }

        "disable" {
            $services = Get-Service | Where-Object {
                ($_.Name -like $pattern -or $_.DisplayName -like $pattern) -and $_.StartType -ne "Disabled"
            }
            $targetStartType = "Disabled"
        }
    }

    if (!$services) {
        Write-Host "No applicable services found containing '$searchText'." -ForegroundColor Yellow
        Pause-Return
        continue
    }

    Write-Host "`nServices matching '$searchText':" -ForegroundColor Cyan
    $services | Select Name, DisplayName, Status, StartType | Format-Table -AutoSize

    if ($mode -eq "status") {
        Write-Host "`nStatus check completed." -ForegroundColor Green
        Pause-Return
        continue
    }

    Write-Host "`nPreview changes:" -ForegroundColor Cyan
    $services | Select Name,
        @{Name="CurrentStartType";Expression={$_.StartType}},
        @{Name="NewStartType";Expression={$targetStartType}} |
    Format-Table -AutoSize

    $confirm = Read-Host "`nConfirm action $actionText? (y/n)"
    if ($confirm -notmatch "^[yY]$") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        Pause-Return
        continue
    }

    if ($mode -eq "disable") {
        Write-Host "`nWARNING: You are about to DISABLE services!" -ForegroundColor Red
        Write-Host "This may break system or applications." -ForegroundColor Red
        $doubleConfirm = Read-Host "Type DISABLE to continue"
        if ($doubleConfirm -ne "DISABLE") {
            Write-Host "Disable operation aborted." -ForegroundColor Yellow
            Pause-Return
            continue
        }
    }

    foreach ($svc in $services) {
        try {
            Set-Service -Name $svc.Name -StartupType $targetStartType -ErrorAction Stop
            Write-Host "OK: $($svc.Name) set to $targetStartType" -ForegroundColor Green
            Add-Content $LogFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $($svc.Name) | SET TO $targetStartType"
        }
        catch {
            Write-Host "SKIPPED: $($svc.Name) - Access denied or protected service" -ForegroundColor Yellow
            Add-Content $LogFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $($svc.Name) | ERROR | $($_.Exception.Message)"
        }
    }

    Write-Host "`nOperation completed." -ForegroundColor Green
    Pause-Return

} while ($true)
