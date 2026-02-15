# Configuration
$target = "8.8.8.8" # Google DNS - you can change this to your ISP's DNS or gateway (use the ipconfig command to find your default gateway)
$pingTimeoutSeconds = 1 # Timeout for each ping (1 second)
$pollIntervalSeconds = 1 # Wait between pings (1 second = 60 pings/minute)
$intervalSeconds = 3600 # Summary interval (3600 seconds = 1 hour)

# Counters
$success = 0
$failure = 0
$totalSuccess = 0
$totalFailure = 0
$startTime = Get-Date
$scriptStartTime = Get-Date

# Arrays to track failure timestamps
$intervalFailures = @()
$allFailures = @()

# Function to calculate and display statistics
function Show-Statistics {
    param(
        [switch]$IsFinalSummary
    )
    
    # Calculate interval statistics
    $intervalTotal = $success + $failure
    if ($intervalTotal -gt 0) {
        $intervalUptime = [math]::Round(($success / $intervalTotal) * 100, 2)
    } else {
        $intervalUptime = 0
    }
    
    # Calculate overall statistics
    $overallTotal = $totalSuccess + $totalFailure
    if ($overallTotal -gt 0) {
        $overallUptime = [math]::Round(($totalSuccess / $overallTotal) * 100, 2)
    } else {
        $overallUptime = 0
    }
    
    if ($IsFinalSummary) {
        # Final summary format
        $endTime = Get-Date
        $totalRuntime = $endTime - $scriptStartTime
        
        Write-Host "`n`n================================================" -ForegroundColor Cyan
        Write-Host "           FINAL SUMMARY" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "Target: $target"
        Write-Host "Start time: $($scriptStartTime.ToString('yyyy-MM-dd HH:mm:ss'))"
        Write-Host "End time: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))"
        Write-Host "Total runtime: $([math]::Floor($totalRuntime.TotalHours))h $($totalRuntime.Minutes)m $($totalRuntime.Seconds)s"
        Write-Host ""
        Write-Host "Total Pings Sent: $overallTotal"
        Write-Host "Successful Pings: $totalSuccess" -ForegroundColor Green
        Write-Host "Failed Pings: $totalFailure" -ForegroundColor Red
        Write-Host "Overall Uptime: $overallUptime%" -ForegroundColor $(if ($overallUptime -ge 99) { "Green" } elseif ($overallUptime -ge 95) { "Yellow" } else { "Red" })
        
        if ($allFailures.Count -gt 0) {
            Write-Host ""
            Write-Host "All failure timestamps:" -ForegroundColor Red
            Write-Host "[$($allFailures -join ', ')]" -ForegroundColor DarkYellow
        } else {
            Write-Host ""
            Write-Host "No failures detected during monitoring!" -ForegroundColor Green
        }
        
        Write-Host "================================================`n" -ForegroundColor Cyan
    } else {
        # Regular interval summary format
        Write-Host "`n--- Interval Summary ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) ---" -ForegroundColor Yellow
        Write-Host "Successes (interval): $success"
        Write-Host "Failures  (interval): $failure"
        Write-Host "Uptime    (interval): $intervalUptime%"
        if ($intervalFailures.Count -gt 0) {
            Write-Host "Failure times (interval): $($intervalFailures -join ', ')" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "Total Successes: $totalSuccess"
        Write-Host "Total Failures:  $totalFailure"
        Write-Host "Overall Uptime:  $overallUptime%"
        Write-Host "All failure times: [$($allFailures -join ', ')]" -ForegroundColor DarkYellow
        Write-Host "-----------------------------------------`n"
    }
}

# Handle Ctrl+C to show summary before exit
[Console]::TreatControlCAsInput = $false

Write-Host "Monitoring connection to $target... (Ctrl+C to stop)" -ForegroundColor Cyan
Write-Host "Ping interval: $pollIntervalSeconds seconds | Summary interval: $intervalSeconds seconds`n" -ForegroundColor Gray

try {
    while ($true) {
        try {
            $result = Test-Connection -ComputerName $target -Count 1 -Quiet -TimeoutSeconds $pingTimeoutSeconds
            if ($result) {
                $success++
                $totalSuccess++
            } else {
                $failure++
                $totalFailure++
                $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                $intervalFailures += $timestamp
                $allFailures += $timestamp
                Write-Host "$timestamp - PING FAILED" -ForegroundColor Red
            }
        } catch {
            $failure++
            $totalFailure++
            $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            $intervalFailures += $timestamp
            $allFailures += $timestamp
            Write-Host "$timestamp - PING EXCEPTION: $($_.Exception.Message)" -ForegroundColor Red
        }

        # Check if interval seconds have passed
        if ((Get-Date) -gt $startTime.AddSeconds($intervalSeconds)) {
            # Show interval summary
            Show-Statistics
            
            # Reset counters for the next interval block
            $success = 0
            $failure = 0
            $intervalFailures = @()
            $startTime = Get-Date
        }

        Start-Sleep -Seconds $pollIntervalSeconds
    }
} finally {
    # This will always run when the script exits (including Ctrl+C)
    Show-Statistics -IsFinalSummary
}
