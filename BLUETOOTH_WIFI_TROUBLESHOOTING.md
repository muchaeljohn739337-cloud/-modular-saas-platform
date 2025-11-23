# Bluetooth Handshake & Wi-Fi Packet Drop Analysis

## Practical Guide to Network Troubleshooting

---

## 🔵 Bluetooth Connection Handshake

### How Bluetooth Pairing Works (Classic Bluetooth)

#### 1. **Inquiry Phase**

```
Device A (Master) → Broadcasts inquiry packets
Device B (Slave)   → Responds with device info (MAC, name, class)
```

#### 2. **Paging Phase**

```
Device A → Sends page request to Device B's MAC address
Device B → Responds with acknowledgment
```

#### 3. **Link Establishment**

```
Device A ↔ Device B: Negotiate connection parameters
- Clock offset synchronization
- Frequency hopping sequence
- Authentication
```

#### 4. **Authentication & Pairing**

```
Step 1: PIN/Passkey Exchange
Device A → Generate random number (RAND)
Device B → Generate RAND

Step 2: Link Key Generation
Both devices → Compute link key using:
- BD_ADDR (Bluetooth Device Address)
- PIN code
- RAND values

Step 3: Authentication
Device A → Send challenge (AU_RAND)
Device B → Compute response using link key
Device B → Send SRES (Signed Response)
Device A → Verify SRES

Step 4: Encryption (Optional)
Both devices → Generate encryption key from link key
Start encrypted communication
```

### BLE (Bluetooth Low Energy) Pairing

```
Phase 1: Pairing Feature Exchange
- Device A & B exchange I/O capabilities
- Determine pairing method (Just Works, Passkey, OOB)

Phase 2: Short-Term Key (STK) Generation
- Device A sends pairing request
- Device B sends pairing response
- Generate Temporary Key (TK)

Phase 3: Authentication
- Exchange random numbers
- Compute STK = f4(TK, Nmaster, Nslave, 0)

Phase 4: Long-Term Key (LTK) Distribution
- Generate permanent LTK
- Exchange keys for future connections

Phase 5: Connection Complete
- Encrypted link established
- Save LTK for reconnection
```

---

## 📶 Wi-Fi Packet Drops - Root Causes

### 1. **Signal Interference**

```
Common Interferers:
- Microwave ovens (2.4 GHz)
- Bluetooth devices (2.4 GHz)
- Cordless phones
- Baby monitors
- Neighboring Wi-Fi networks
```

**Detection:**

```powershell
# Check Wi-Fi channel congestion
netsh wlan show networks mode=bssid

# See which channels neighbors are using
# Look for overlapping channels (1, 6, 11 are non-overlapping for 2.4 GHz)
```

### 2. **Weak Signal Strength**

```
Signal Quality Indicators:
Excellent:  -30 to -50 dBm
Good:       -50 to -60 dBm
Fair:       -60 to -70 dBm
Poor:       -70 to -80 dBm
Unusable:   -80 dBm and below
```

**Check Signal Strength:**

```powershell
# View current connection details
netsh wlan show interfaces

# Look for "Signal" percentage
# Anything below 60% may cause packet drops
```

### 3. **Network Congestion**

```
Too Many Devices:
- Each device competes for bandwidth
- CSMA/CA (Carrier Sense Multiple Access with Collision Avoidance)
- Devices wait for channel to be free before transmitting

Symptoms:
- High latency
- Intermittent disconnections
- Slow download speeds
```

### 4. **Driver/Hardware Issues**

```powershell
# Check Wi-Fi adapter driver
Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*"} | Select-Object Name, DriverVersion, DriverDate

# Update driver if outdated
# Manufacturer's website > Download latest driver
```

### 5. **Router/AP Overload**

```
Signs of Router Overload:
- Packet loss increases with more connected devices
- Router becomes hot to touch
- Admin interface becomes slow/unresponsive

Solutions:
- Reboot router regularly
- Update router firmware
- Upgrade to better router (Wi-Fi 6/6E)
```

---

## 🔍 Diagnosing Packet Drops

### Method 1: Continuous Ping Test

```powershell
# Ping your router continuously
ping -t 192.168.1.1

# Look for "Request timed out" or high latency spikes
# Press Ctrl+C to stop and see statistics

# Expected results:
# 0% packet loss = Excellent
# 1-5% loss = Acceptable for most uses
# 5-10% loss = Noticeable issues
# 10%+ loss = Serious problem
```

### Method 2: Pathping (Advanced Diagnostics)

```powershell
# Trace route with packet loss analysis
pathping google.com

# Shows packet loss at each hop
# Identifies if problem is:
# - Your network (first hop)
# - ISP network (middle hops)
# - Destination (last hop)
```

### Method 3: PowerShell Network Statistics

```powershell
# Get detailed interface statistics
Get-NetAdapterStatistics | Format-Table Name, ReceivedBytes, SentBytes, ReceivedDiscardedPackets, OutboundDiscardedPackets

# Monitor dropped packets in real-time
while ($true) {
    Clear-Host
    $stats = Get-NetAdapterStatistics | Where-Object {$_.Name -like "*Wi-Fi*"}
    Write-Host "Received Discarded: $($stats.ReceivedDiscardedPackets)"
    Write-Host "Outbound Discarded: $($stats.OutboundDiscardedPackets)"
    Start-Sleep -Seconds 2
}
```

### Method 4: Event Viewer Logs

```powershell
# Check for Wi-Fi driver errors
Get-EventLog -LogName System -Source "*WLAN*" -Newest 50 | Format-Table TimeGenerated, EntryType, Message

# Look for patterns of disconnections
```

---

## 🛠️ Troubleshooting Script

Save as `network-diagnostic.ps1`:

```powershell
# Network Diagnostic Tool
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Network Diagnostic & Troubleshooting Tool   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. Check Network Adapters
Write-Host "1️⃣  Network Adapters:" -ForegroundColor Yellow
Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MediaType | Format-Table

# 2. Check Wi-Fi Connection
Write-Host "`n2️⃣  Wi-Fi Connection Details:" -ForegroundColor Yellow
netsh wlan show interfaces

# 3. Check Default Gateway
Write-Host "`n3️⃣  Default Gateway:" -ForegroundColor Yellow
$gateway = (Get-NetRoute | Where-Object {$_.DestinationPrefix -eq '0.0.0.0/0'}).NextHop
Write-Host "Gateway IP: $gateway" -ForegroundColor Green

# 4. Ping Gateway
Write-Host "`n4️⃣  Testing Gateway Connectivity (10 packets):" -ForegroundColor Yellow
$pingResult = Test-Connection -ComputerName $gateway -Count 10
$packetLoss = (($pingResult.Count - ($pingResult | Where-Object {$_.StatusCode -eq 0}).Count) / $pingResult.Count) * 100
Write-Host "Packet Loss: $packetLoss%" -ForegroundColor $(if ($packetLoss -eq 0) {"Green"} elseif ($packetLoss -lt 5) {"Yellow"} else {"Red"})

# 5. Check DNS
Write-Host "`n5️⃣  DNS Resolution Test:" -ForegroundColor Yellow
$dnsTest = Measure-Command { Resolve-DnsName google.com -ErrorAction SilentlyContinue }
Write-Host "DNS Lookup Time: $($dnsTest.TotalMilliseconds) ms" -ForegroundColor Cyan

# 6. Check Internet Connectivity
Write-Host "`n6️⃣  Internet Connectivity Test:" -ForegroundColor Yellow
$internetTest = Test-Connection -ComputerName 8.8.8.8 -Count 5 -ErrorAction SilentlyContinue
if ($internetTest) {
    Write-Host "✅ Internet: Connected" -ForegroundColor Green
    $avgLatency = ($internetTest | Measure-Object -Property ResponseTime -Average).Average
    Write-Host "Average Latency: $avgLatency ms" -ForegroundColor Cyan
} else {
    Write-Host "❌ Internet: Disconnected" -ForegroundColor Red
}

# 7. Check for Packet Drops
Write-Host "`n7️⃣  Network Adapter Packet Statistics:" -ForegroundColor Yellow
Get-NetAdapterStatistics | Format-Table Name, ReceivedBytes, SentBytes, ReceivedDiscardedPackets, OutboundDiscardedPackets

# 8. Nearby Wi-Fi Networks
Write-Host "`n8️⃣  Nearby Wi-Fi Networks (Channel Analysis):" -ForegroundColor Yellow
Write-Host "Checking for channel congestion..." -ForegroundColor Gray
netsh wlan show networks mode=bssid | Select-String "SSID|Channel|Signal"

Write-Host "`n✅ Diagnostic Complete!" -ForegroundColor Green
Write-Host "`nRecommendations:" -ForegroundColor Cyan
if ($packetLoss -gt 5) {
    Write-Host "⚠️  High packet loss detected - Check Wi-Fi signal strength" -ForegroundColor Yellow
}
if ($avgLatency -gt 100) {
    Write-Host "⚠️  High latency - Check for network congestion" -ForegroundColor Yellow
}
```

---

## 🎯 Common Packet Drop Scenarios

### Scenario 1: Intermittent Drops Every Few Minutes

**Likely Cause:** Interference or power-saving mode

```powershell
# Disable Wi-Fi adapter power saving
$adapter = Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*"}
Disable-NetAdapterPowerManagement -Name $adapter.Name

# Or via Device Manager:
# Device Manager > Network Adapters > Wi-Fi Adapter > Properties
# Power Management > Uncheck "Allow computer to turn off this device"
```

### Scenario 2: Drops During High Traffic

**Likely Cause:** Bandwidth saturation or router overload

```powershell
# Check current bandwidth usage
Get-NetAdapterStatistics | Select-Object Name,
    @{Name='ReceivedMB';Expression={[math]::Round($_.ReceivedBytes/1MB,2)}},
    @{Name='SentMB';Expression={[math]::Round($_.SentBytes/1MB,2)}}

# Solution: Implement QoS (Quality of Service) on router
# Prioritize critical traffic (video calls, gaming)
```

### Scenario 3: Drops After Windows Update

**Likely Cause:** Driver incompatibility

```powershell
# Roll back network adapter driver
# Device Manager > Network Adapters > Right-click Wi-Fi adapter
# Properties > Driver > Roll Back Driver

# Or reinstall driver
pnputil /enum-drivers
# Find your Wi-Fi driver and note the published name (oem##.inf)
pnputil /delete-driver oem##.inf /uninstall
# Restart PC - Windows will reinstall default driver
```

---

## 📊 Monitoring Tools

### Real-Time Packet Loss Monitor

```powershell
# monitor-packets.ps1
param(
    [string]$Target = "8.8.8.8",
    [int]$Interval = 1
)

$packetsSent = 0
$packetsLost = 0

Write-Host "Monitoring packet loss to $Target (Press Ctrl+C to stop)`n" -ForegroundColor Cyan

while ($true) {
    $packetsSent++
    $result = Test-Connection -ComputerName $Target -Count 1 -ErrorAction SilentlyContinue

    if (-not $result) {
        $packetsLost++
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ❌ PACKET LOST" -ForegroundColor Red
    } else {
        $latency = $result.ResponseTime
        $color = if ($latency -lt 50) {"Green"} elseif ($latency -lt 100) {"Yellow"} else {"Red"}
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✅ Reply: $latency ms" -ForegroundColor $color
    }

    $lossPercent = [math]::Round(($packetsLost / $packetsSent) * 100, 2)
    Write-Host "Statistics: Sent=$packetsSent | Lost=$packetsLost | Loss=$lossPercent%" -ForegroundColor Cyan

    Start-Sleep -Seconds $Interval
}
```

---

## 🔧 Advanced Fixes

### Fix 1: Change Wi-Fi Channel (Router-Side)

```
2.4 GHz: Use channels 1, 6, or 11 (non-overlapping)
5 GHz: Use channels 36, 40, 44, 48 (less congested)

Steps:
1. Login to router admin panel (usually 192.168.1.1)
2. Navigate to Wireless Settings
3. Change channel to least congested one
4. Save and reboot router
```

### Fix 2: Adjust MTU (Maximum Transmission Unit)

```powershell
# Check current MTU
netsh interface ipv4 show subinterfaces

# Set optimal MTU (usually 1500 for Ethernet, 1492 for PPPoE)
netsh interface ipv4 set subinterface "Wi-Fi" mtu=1500 store=persistent

# Test different values if experiencing fragmentation
```

### Fix 3: DNS Optimization

```powershell
# Change to faster DNS servers
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1","1.0.0.1")

# Or use Google DNS
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("8.8.8.8","8.8.4.4")

# Clear DNS cache
Clear-DnsClientCache
```

### Fix 4: Reset Network Stack

```powershell
# Nuclear option - resets all network settings
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns

# Restart computer after running these commands
```

---

## 📱 Bluetooth Troubleshooting

### Common Bluetooth Issues

#### 1. Pairing Fails

```powershell
# Remove old pairing and re-pair
# Settings > Bluetooth & Devices > Remove device
# Put device in pairing mode again

# Check Bluetooth service
Get-Service | Where-Object {$_.Name -like "*bluetooth*"}

# Restart Bluetooth service
Restart-Service bthserv
```

#### 2. Audio Stuttering/Drops

```
Causes:
- Interference from Wi-Fi (both use 2.4 GHz)
- Bluetooth codec mismatch
- Distance/obstacles between devices

Solutions:
- Move away from Wi-Fi router
- Use Bluetooth 5.0+ devices (better coexistence)
- Update Bluetooth drivers
- Use aptX or AAC codec instead of SBC
```

#### 3. Connection Drops After Sleep

```powershell
# Prevent Bluetooth adapter from sleeping
$btAdapter = Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Bluetooth*"}
# Device Manager > Bluetooth > Properties > Power Management
# Uncheck "Allow computer to turn off this device"
```

---

## 🎓 Understanding the Tech

### How Wi-Fi Actually Works

```
1. Device wants to send data
2. Device listens: Is channel free?
   - Yes → Send data frame
   - No → Wait random time (backoff), try again
3. Access Point receives frame
4. AP sends ACK (acknowledgment)
5. If no ACK received → Device retransmits
6. Too many retransmissions → Connection drops
```

### Why Packets Drop

```
Physical Layer:
- Weak signal strength
- Interference
- Hardware malfunction

Data Link Layer:
- Buffer overflow (router memory full)
- Collision (two devices transmit simultaneously)
- Bit errors (corrupted data)

Network Layer:
- Routing issues
- TTL (Time To Live) expiration
- Congestion

Transport Layer:
- Congestion control (TCP intentionally drops)
- Flow control
```

---

## 📚 Quick Reference

### Essential Commands

```powershell
# Network info
ipconfig /all
netsh wlan show interfaces
Get-NetAdapter

# Connectivity tests
ping <address>
tracert <address>
pathping <address>
Test-Connection <address>

# DNS
nslookup <domain>
Resolve-DnsName <domain>
Clear-DnsClientCache

# Statistics
netstat -e
Get-NetAdapterStatistics
```

### Signal Quality Guidelines

```
RSSI (Received Signal Strength Indicator):
-30 dBm: Maximum signal, you're next to the router
-50 dBm: Excellent signal
-60 dBm: Good signal
-67 dBm: Fair signal (minimum for streaming)
-70 dBm: Poor signal (web browsing only)
-80 dBm: Unusable signal
```

---

**Created:** November 22, 2025  
**Purpose:** Understand and troubleshoot Bluetooth handshakes and Wi-Fi packet drops  
**Use Case:** Network diagnostics, IoT development, connectivity issues
