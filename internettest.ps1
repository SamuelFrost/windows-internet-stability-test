# Configuration
$target = "8.8.8.8"  # Google DNS - you can change this to your ISP's DNS or gateway
$pollIntervalSeconds = 1  # Wait between pings (1 second = 60 pings/minute)
$intervalSeconds = 3600  # Summary interval (3600 seconds = 1 hour)

# Counters
$success = 0
$failure = 0
$totalSuccess = 0
$totalFailure = 0
$startTime = Get-Date

# Arrays to track failure timestamps
$intervalFailures = @()
$allFailures = @()

Write-Host "Monitoring connection to $target... (Ctrl+C to stop)" -ForegroundColor Cyan
Write-Host "Ping interval: $pollIntervalSeconds seconds | Summary interval: $intervalSeconds seconds`n" -ForegroundColor Gray

while ($true) {
    # Send a single ping using Test-Connection (compatible with PowerShell 5.1)
    try {
        $result = Test-Connection -ComputerName $target -Count 1 -Quiet
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
        $intervalTotal = $success + $failure
        if ($intervalTotal -gt 0) {
            $uptime = [math]::Round(($success / $intervalTotal) * 100, 2)
        } else {
            $uptime = 0
        }

        $overallTotal = $totalSuccess + $totalFailure
        if ($overallTotal -gt 0) {
            $overallUptime = [math]::Round(($totalSuccess / $overallTotal) * 100, 2)
        } else {
            $overallUptime = 0
        }

        Write-Host "`n--- 1-Minute Summary ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) ---" -ForegroundColor Yellow
        Write-Host "Successes (interval): $success"
        Write-Host "Failures  (interval): $failure"
        Write-Host "Uptime    (interval): $uptime%"
        if ($intervalFailures.Count -gt 0) {
            Write-Host "Failure times (interval): $($intervalFailures -join ', ')" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "Total Successes: $totalSuccess"
        Write-Host "Total Failures:  $totalFailure"
        Write-Host "Overall Uptime:  $overallUptime%"
        Write-Host "All failure times (JST): [$($allFailures -join ', ')]" -ForegroundColor DarkYellow
        Write-Host "-----------------------------------------`n"

        # Reset counters for the next interval block
        $success = 0
        $failure = 0
        $intervalFailures = @()
        $startTime = Get-Date
    }

    Start-Sleep -Seconds $pollIntervalSeconds
}
