# Network Diagnostic Tool
# Real-time packet loss and connectivity monitor

param(
    [string]$Target = "8.8.8.8",
    [int]$Interval = 1,
    [switch]$Continuous
)

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        Network Diagnostic & Packet Loss Monitor          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Initial diagnostics
Write-Host "🔍 Running Initial Diagnostics...`n" -ForegroundColor Yellow

# 1. Network Adapters
Write-Host "━━━ Network Adapters ━━━" -ForegroundColor Gray
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Format-Table Name, Status, LinkSpeed, MediaType -AutoSize

# 2. Wi-Fi Connection Details
Write-Host "`n━━━ Wi-Fi Details ━━━" -ForegroundColor Gray
$wifiInfo = netsh wlan show interfaces | Select-String "SSID|Signal|Channel|State"
$wifiInfo

# 3. Default Gateway
Write-Host "`n━━━ Gateway Information ━━━" -ForegroundColor Gray
$gateway = (Get-NetRoute | Where-Object {$_.DestinationPrefix -eq '0.0.0.0/0'}).NextHop
Write-Host "Gateway IP: $gateway" -ForegroundColor Green

# 4. Quick Gateway Ping Test
Write-Host "`n━━━ Gateway Connectivity Test (5 packets) ━━━" -ForegroundColor Gray
$gatewayTest = Test-Connection -ComputerName $gateway -Count 5 -ErrorAction SilentlyContinue
if ($gatewayTest) {
    $avgLatency = [math]::Round(($gatewayTest | Measure-Object -Property ResponseTime -Average).Average, 2)
    $packetLoss = [math]::Round((5 - $gatewayTest.Count) / 5 * 100, 2)
    Write-Host "✅ Gateway: Reachable" -ForegroundColor Green
    Write-Host "Average Latency: $avgLatency ms" -ForegroundColor Cyan
    Write-Host "Packet Loss: $packetLoss%" -ForegroundColor $(if ($packetLoss -eq 0) {"Green"} elseif ($packetLoss -lt 5) {"Yellow"} else {"Red"})
} else {
    Write-Host "❌ Gateway: Unreachable" -ForegroundColor Red
}

# 5. DNS Test
Write-Host "`n━━━ DNS Resolution Test ━━━" -ForegroundColor Gray
$dnsTime = Measure-Command { Resolve-DnsName google.com -ErrorAction SilentlyContinue }
Write-Host "DNS Lookup Time: $([math]::Round($dnsTime.TotalMilliseconds, 2)) ms" -ForegroundColor Cyan

# 6. Internet Connectivity
Write-Host "`n━━━ Internet Connectivity Test ━━━" -ForegroundColor Gray
$internetTest = Test-Connection -ComputerName $Target -Count 5 -ErrorAction SilentlyContinue
if ($internetTest) {
    $avgLatency = [math]::Round(($internetTest | Measure-Object -Property ResponseTime -Average).Average, 2)
    Write-Host "✅ Internet: Connected" -ForegroundColor Green
    Write-Host "Average Latency: $avgLatency ms" -ForegroundColor Cyan
} else {
    Write-Host "❌ Internet: Disconnected" -ForegroundColor Red
}

# 7. Adapter Statistics
Write-Host "`n━━━ Network Adapter Statistics ━━━" -ForegroundColor Gray
Get-NetAdapterStatistics | Where-Object {$_.Name -like "*Wi-Fi*" -or $_.Name -like "*Ethernet*"} | 
    Select-Object Name, 
        @{Name='ReceivedMB';Expression={[math]::Round($_.ReceivedBytes/1MB,2)}},
        @{Name='SentMB';Expression={[math]::Round($_.SentBytes/1MB,2)}},
        ReceivedDiscardedPackets,
        OutboundDiscardedPackets | 
    Format-Table -AutoSize

# Continuous Monitoring
if ($Continuous) {
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║           Starting Continuous Packet Monitor             ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "`nTarget: $Target | Interval: $Interval second(s)" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Yellow

    $packetsSent = 0
    $packetsReceived = 0
    $totalLatency = 0
    $minLatency = 9999
    $maxLatency = 0

    while ($true) {
        $packetsSent++
        $result = Test-Connection -ComputerName $Target -Count 1 -ErrorAction SilentlyContinue
        
        $timestamp = Get-Date -Format 'HH:mm:ss'
        
        if ($result) {
            $packetsReceived++
            $latency = $result.ResponseTime
            $totalLatency += $latency
            
            if ($latency -lt $minLatency) { $minLatency = $latency }
            if ($latency -gt $maxLatency) { $maxLatency = $latency }
            
            $color = if ($latency -lt 50) {"Green"} elseif ($latency -lt 100) {"Yellow"} else {"Red"}
            $lossPercent = [math]::Round((($packetsSent - $packetsReceived) / $packetsSent) * 100, 2)
            $avgLatency = [math]::Round($totalLatency / $packetsReceived, 2)
            
            Write-Host "[$timestamp] ✅ Reply from $Target : time=${latency}ms | Loss=$lossPercent% | Avg=${avgLatency}ms | Min=${minLatency}ms | Max=${maxLatency}ms" -ForegroundColor $color
        } else {
            $lossPercent = [math]::Round((($packetsSent - $packetsReceived) / $packetsSent) * 100, 2)
            Write-Host "[$timestamp] ❌ Request timed out | Loss=$lossPercent% | Sent=$packetsSent | Received=$packetsReceived" -ForegroundColor Red
        }
        
        Start-Sleep -Seconds $Interval
    }
}

Write-Host "`n✅ Diagnostic Complete!" -ForegroundColor Green
Write-Host "`n💡 Tips:" -ForegroundColor Cyan
Write-Host "  • Run with -Continuous flag for real-time monitoring" -ForegroundColor White
Write-Host "  • Example: .\network-diagnostic.ps1 -Continuous -Target 192.168.1.1" -ForegroundColor Gray
Write-Host "  • Use your gateway IP for local network testing" -ForegroundColor Gray
Write-Host "  • Use 8.8.8.8 or 1.1.1.1 for internet testing`n" -ForegroundColor Gray
