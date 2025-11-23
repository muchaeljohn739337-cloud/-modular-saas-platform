<#
.SYNOPSIS
    Security Hardening & Secret Scanner for Advancia Pay Platform
.DESCRIPTION
    Comprehensive security audit script that:
    1. Scans for exposed secrets and credentials
    2. Checks git history for leaked secrets
    3. Validates environment variable security
    4. Verifies deployment configurations
    5. Provides remediation steps
.NOTES
    Author: Advancia Security Team
    Version: 1.0.0
    Date: 2025-11-20
#>

param(
    [switch]$DeepScan,
    [switch]$FixIssues,
    [switch]$GitHistory,
    [switch]$ExportReport
)

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }
function Write-Section { param($Message) Write-Host "`n═══ $Message ═══" -ForegroundColor Magenta }

# Security patterns to detect
$SecretPatterns = @{
    "AWS Access Key" = 'AKIA[0-9A-Z]{16}'
    "AWS Secret Key" = '(?i)aws(.{0,20})?[''"`"][0-9a-zA-Z\/+]{40}[''"`"]'
    "GitHub Token" = 'ghp_[0-9a-zA-Z]{36}|gho_[0-9a-zA-Z]{36}|ghu_[0-9a-zA-Z]{36}|ghs_[0-9a-zA-Z]{36}|ghr_[0-9a-zA-Z]{36}'
    "Vercel Token" = '[A-Za-z0-9]{24}'
    "Stripe Secret Key" = 'sk_(live|test)_[0-9a-zA-Z]{24,}'
    "Stripe Webhook Secret" = 'whsec_[0-9a-zA-Z]{32,}'
    "JWT Secret" = '(?i)jwt[_-]?secret[''"`"]?\s*[:=]\s*[''"`"]?[A-Za-z0-9+/=]{32,}'
    "Database URL with Password" = 'postgres(?:ql)?://[^:]+:([^@\s]+)@'
    "Private Key" = '-----BEGIN (RSA |EC )?PRIVATE KEY-----'
    "API Key" = '(?i)api[_-]?key[''"`"]?\s*[:=]\s*[''"`"]?[A-Za-z0-9]{20,}'
    "Password in Code" = '(?i)password[''"`"]?\s*[:=]\s*[''"`"]?(?!<[%\$])[A-Za-z0-9!@#$%^&*]{8,}[''"`"]?'
    "OAuth Token" = '(?i)oauth[_-]?token[''"`"]?\s*[:=]\s*[''"`"]?[A-Za-z0-9._-]{20,}'
    "Cryptomus API Key" = '(?i)cryptomus[_-]?api[_-]?key'
    "Email Password" = '(?i)email[_-]?password[''"`"]?\s*[:=]'
}

# Files and directories to exclude
$ExcludePatterns = @(
    "node_modules",
    ".git",
    ".next",
    "dist",
    "build",
    "coverage",
    "*.log",
    "*.lock",
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock"
)

# Initialize report
$Report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalFiles = 0
    ScannedFiles = 0
    Issues = @()
    Warnings = @()
    GitHistory = @()
    Summary = @{}
}

Write-Section "Advancia Pay Security Hardening Tool"
Write-Info "Starting comprehensive security scan..."
Write-Info "Workspace: $PWD"

# ═══════════════════════════════════════════════════════════
# 1. FILE SYSTEM SCAN FOR SECRETS
# ═══════════════════════════════════════════════════════════
Write-Section "Scanning Files for Exposed Secrets"

$FilesToScan = Get-ChildItem -Path . -Recurse -File | Where-Object {
    $file = $_
    $shouldExclude = $false
    foreach ($pattern in $ExcludePatterns) {
        if ($file.FullName -like "*$pattern*") {
            $shouldExclude = $true
            break
        }
    }
    -not $shouldExclude
}

$Report.TotalFiles = $FilesToScan.Count
Write-Info "Scanning $($Report.TotalFiles) files..."

foreach ($file in $FilesToScan) {
    $Report.ScannedFiles++
    
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        
        foreach ($patternName in $SecretPatterns.Keys) {
            $pattern = $SecretPatterns[$patternName]
            if ($content -match $pattern) {
                $matches = [regex]::Matches($content, $pattern)
                foreach ($match in $matches) {
                    # Redact the actual secret
                    $redacted = $match.Value.Substring(0, [Math]::Min(10, $match.Value.Length)) + "***REDACTED***"
                    
                    $issue = @{
                        Type = $patternName
                        File = $file.FullName.Replace($PWD, ".")
                        Line = ($content.Substring(0, $match.Index) -split "`n").Count
                        Preview = $redacted
                        Severity = "CRITICAL"
                    }
                    
                    $Report.Issues += $issue
                    Write-Error "$patternName found in: $($issue.File):$($issue.Line)"
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to scan: $($file.Name)"
    }
}

Write-Success "File scan complete. Found $($Report.Issues.Count) potential issues."

# ═══════════════════════════════════════════════════════════
# 2. GIT HISTORY SCAN (Optional)
# ═══════════════════════════════════════════════════════════
if ($GitHistory) {
    Write-Section "Scanning Git History for Leaked Secrets"
    
    try {
        $gitLog = git log --all --full-history --source --oneline
        
        # Check specific files with known issues
        $sensitiveFiles = @(
            "VERCEL_DEPLOYMENT_GUIDE.md",
            ".env",
            ".env.production",
            "backend/.env",
            "frontend/.env"
        )
        
        foreach ($file in $sensitiveFiles) {
            if (Test-Path $file) {
                Write-Info "Checking history for: $file"
                
                $fileHistory = git log --all --full-history -- $file
                if ($fileHistory) {
                    $commits = git log --all --full-history --oneline -- $file | Measure-Object
                    
                    $historyItem = @{
                        File = $file
                        Commits = $commits.Count
                        Status = "REVIEW REQUIRED"
                    }
                    $Report.GitHistory += $historyItem
                    Write-Warning "File $file has $($commits.Count) commits in history"
                }
            }
        }
        
        # Search for specific leaked token
        Write-Info "Searching for known exposed tokens in git history..."
        $knownTokens = @("5Mfvjjg2L4B46AbiypV6fgGH")
        
        foreach ($token in $knownTokens) {
            $found = git log --all --full-history -S $token --oneline
            if ($found) {
                Write-Error "CRITICAL: Token found in git history!"
                $Report.GitHistory += @{
                    Token = "REDACTED"
                    Found = $true
                    Message = "Token must be revoked immediately"
                    Severity = "CRITICAL"
                }
            }
        }
        
        Write-Success "Git history scan complete."
    }
    catch {
        Write-Warning "Git not available or not a git repository"
    }
}

# ═══════════════════════════════════════════════════════════
# 3. ENVIRONMENT VARIABLE VALIDATION
# ═══════════════════════════════════════════════════════════
Write-Section "Validating Environment Configuration"

$envFiles = @(
    ".env",
    "backend/.env",
    "frontend/.env",
    ".env.local",
    ".env.production"
)

foreach ($envFile in $envFiles) {
    if (Test-Path $envFile) {
        Write-Warning "Found environment file: $envFile"
        $Report.Warnings += "Environment file exists in workspace: $envFile"
        
        # Check if it's in .gitignore
        if (Test-Path ".gitignore") {
            $gitignore = Get-Content ".gitignore" -Raw
            if ($gitignore -notmatch [regex]::Escape($envFile)) {
                Write-Error "$envFile is NOT in .gitignore!"
                $Report.Issues += @{
                    Type = "Unprotected Environment File"
                    File = $envFile
                    Severity = "HIGH"
                    Recommendation = "Add to .gitignore immediately"
                }
            }
            else {
                Write-Success "$envFile is properly ignored"
            }
        }
    }
}

# ═══════════════════════════════════════════════════════════
# 4. DEPLOYMENT CONFIGURATION CHECKS
# ═══════════════════════════════════════════════════════════
Write-Section "Checking Deployment Configurations"

# Check Vercel configuration
if (Test-Path "vercel.json") {
    Write-Info "Validating vercel.json..."
    $vercelConfig = Get-Content "vercel.json" -Raw | ConvertFrom-Json
    
    # Check for security headers
    if ($vercelConfig.headers) {
        Write-Success "Security headers configured"
    }
    else {
        Write-Warning "No security headers in vercel.json"
        $Report.Warnings += "Consider adding security headers to vercel.json"
    }
}

# Check for exposed ports or services
Write-Info "Checking for hardcoded URLs and endpoints..."
$configFiles = Get-ChildItem -Path . -Recurse -Include "*.json", "*.js", "*.ts", "*.tsx" -Exclude "node_modules" | Select-Object -First 100

foreach ($file in $configFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match "localhost:4000|127\.0\.0\.1") {
        Write-Warning "Localhost reference in: $($file.Name)"
    }
}

# ═══════════════════════════════════════════════════════════
# 5. VERCEL TOKEN CHECK
# ═══════════════════════════════════════════════════════════
Write-Section "Vercel Security Audit"

try {
    # Check if vercel CLI is available
    $vercelVersion = vercel --version 2>$null
    if ($vercelVersion) {
        Write-Success "Vercel CLI detected: $vercelVersion"
        
        # Check environment variables
        Write-Info "Checking Vercel environment variables..."
        $envList = vercel env ls 2>$null
        if ($envList -match "Encrypted") {
            Write-Success "Environment variables are encrypted"
        }
        
        # Warn about token management
        Write-Warning "Please verify Vercel tokens are not exposed:"
        Write-Info "  1. Go to: https://vercel.com/account/tokens"
        Write-Info "  2. Review all active tokens"
        Write-Info "  3. Revoke any suspicious or exposed tokens"
        Write-Info "  4. Generate new tokens as needed"
    }
}
catch {
    Write-Warning "Vercel CLI not available for audit"
}

# ═══════════════════════════════════════════════════════════
# 6. GENERATE SUMMARY REPORT
# ═══════════════════════════════════════════════════════════
Write-Section "Security Audit Summary"

$Report.Summary = @{
    TotalFiles = $Report.TotalFiles
    ScannedFiles = $Report.ScannedFiles
    CriticalIssues = ($Report.Issues | Where-Object { $_.Severity -eq "CRITICAL" }).Count
    HighIssues = ($Report.Issues | Where-Object { $_.Severity -eq "HIGH" }).Count
    Warnings = $Report.Warnings.Count
    GitHistoryItems = $Report.GitHistory.Count
}

Write-Info "`nScan Statistics:"
Write-Host "  Files Scanned: $($Report.Summary.ScannedFiles)"
Write-Host "  Critical Issues: $($Report.Summary.CriticalIssues)" -ForegroundColor $(if ($Report.Summary.CriticalIssues -gt 0) { "Red" } else { "Green" })
Write-Host "  High Issues: $($Report.Summary.HighIssues)" -ForegroundColor $(if ($Report.Summary.HighIssues -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Warnings: $($Report.Summary.Warnings)" -ForegroundColor Yellow

# ═══════════════════════════════════════════════════════════
# 7. REMEDIATION RECOMMENDATIONS
# ═══════════════════════════════════════════════════════════
Write-Section "Recommended Actions"

if ($Report.Issues.Count -gt 0) {
    Write-Error "`n🚨 CRITICAL ACTIONS REQUIRED:"
    Write-Host "  1. IMMEDIATELY revoke any exposed tokens/keys"
    Write-Host "  2. Rotate all compromised credentials"
    Write-Host "  3. Review and fix files listed above"
    Write-Host "  4. Run: git log --all -S 'SECRET_VALUE' to find in history"
    Write-Host "  5. Consider using BFG Repo-Cleaner to remove from git history"
}

Write-Info "`n📋 GENERAL SECURITY CHECKLIST:"
Write-Host "  ☐ All .env files in .gitignore"
Write-Host "  ☐ No secrets in version control"
Write-Host "  ☐ Vercel environment variables encrypted"
Write-Host "  ☐ Database passwords rotated regularly"
Write-Host "  ☐ API keys restricted by IP/domain"
Write-Host "  ☐ 2FA enabled on all services"
Write-Host "  ☐ Security headers configured"
Write-Host "  ☐ HTTPS enforced everywhere"

# ═══════════════════════════════════════════════════════════
# 8. EXPORT REPORT (Optional)
# ═══════════════════════════════════════════════════════════
if ($ExportReport) {
    $reportPath = "security-audit-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $Report | ConvertTo-Json -Depth 10 | Out-File $reportPath
    Write-Success "Report exported to: $reportPath"
}

# ═══════════════════════════════════════════════════════════
# 9. AUTO-FIX (Optional)
# ═══════════════════════════════════════════════════════════
if ($FixIssues) {
    Write-Section "Applying Automatic Fixes"
    
    # Ensure .gitignore includes sensitive files
    $gitignoreEntries = @(
        ".env",
        ".env.local",
        ".env.*.local",
        ".env.production",
        "*.pem",
        "*.key",
        "*.p12",
        ".vercel",
        "security-audit-report-*.json"
    )
    
    if (Test-Path ".gitignore") {
        $gitignore = Get-Content ".gitignore"
        $updated = $false
        
        foreach ($entry in $gitignoreEntries) {
            if ($gitignore -notcontains $entry) {
                Add-Content ".gitignore" "`n$entry"
                Write-Success "Added $entry to .gitignore"
                $updated = $true
            }
        }
        
        if ($updated) {
            Write-Success ".gitignore updated with security entries"
        }
    }
}

Write-Section "Security Audit Complete"
Write-Info "Run with -GitHistory to scan git history"
Write-Info "Run with -FixIssues to apply automatic fixes"
Write-Info "Run with -ExportReport to save JSON report"

exit $(if ($Report.Summary.CriticalIssues -gt 0) { 1 } else { 0 })
