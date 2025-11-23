#!/usr/bin/env pwsh
# Branch Protection Quick Setup Script
# This script helps you set up branch protection for your GitHub repository

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('main', 'staging', 'production')]
    [string]$Branch = 'main',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('minimal', 'standard', 'strict')]
    [string]$Level = 'standard',
    
    [Parameter(Mandatory=$false)]
    [string]$Token = $env:GITHUB_TOKEN
)

Write-Host "🔒 Branch Protection Setup" -ForegroundColor Cyan
Write-Host "=" * 60

# Check if token is provided
if (-not $Token) {
    Write-Host "❌ Error: GitHub token not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide a token in one of these ways:" -ForegroundColor Yellow
    Write-Host "  1. Set environment variable: `$env:GITHUB_TOKEN = 'your_token'" -ForegroundColor Yellow
    Write-Host "  2. Pass as parameter: .\setup-branch-protection.ps1 -Token 'your_token'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Create a token at: https://github.com/settings/tokens" -ForegroundColor Cyan
    Write-Host "Required scopes: repo, admin:repo_hook" -ForegroundColor Cyan
    exit 1
}

# Get repository information
try {
    $gitRemote = git remote get-url origin
    if ($gitRemote -match 'github\.com[:/](.+?)\.git') {
        $repo = $matches[1]
    } elseif ($gitRemote -match 'github\.com[:/](.+?)$') {
        $repo = $matches[1]
    } else {
        throw "Cannot parse repository from git remote"
    }
} catch {
    Write-Host "❌ Error: Cannot determine GitHub repository" -ForegroundColor Red
    Write-Host "Make sure you're in a git repository with a GitHub remote" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Repository: $repo" -ForegroundColor Green
Write-Host "🌿 Branch: $Branch" -ForegroundColor Green
Write-Host "📊 Protection Level: $Level" -ForegroundColor Green
Write-Host ""

# Define protection configurations
$protectionConfigs = @{
    minimal = @{
        required_status_checks = $null
        enforce_admins = $false
        required_pull_request_reviews = $null
        restrictions = $null
        required_linear_history = $false
        allow_force_pushes = $true
        allow_deletions = $false
    }
    standard = @{
        required_status_checks = @{
            strict = $true
            contexts = @("build", "type-lint", "CI (pnpm checks)")
        }
        enforce_admins = $false
        required_pull_request_reviews = @{
            dismiss_stale_reviews = $true
            require_code_owner_reviews = $false
            required_approving_review_count = 1
        }
        restrictions = $null
        required_linear_history = $false
        allow_force_pushes = $false
        allow_deletions = $false
        required_conversation_resolution = $true
    }
    strict = @{
        required_status_checks = @{
            strict = $true
            contexts = @("build", "type-lint", "CI (pnpm checks)", "backend", "frontend")
        }
        enforce_admins = $true
        required_pull_request_reviews = @{
            dismiss_stale_reviews = $true
            require_code_owner_reviews = $true
            required_approving_review_count = 2
            require_last_push_approval = $true
        }
        restrictions = $null
        required_linear_history = $true
        allow_force_pushes = $false
        allow_deletions = $false
        required_conversation_resolution = $true
        lock_branch = $false
        allow_fork_syncing = $true
    }
}

$config = $protectionConfigs[$Level]
$body = $config | ConvertTo-Json -Depth 10

Write-Host "🚀 Applying branch protection..." -ForegroundColor Cyan

try {
    $headers = @{
        Authorization = "token $Token"
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $uri = "https://api.github.com/repos/$repo/branches/$Branch/protection"
    
    $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $body -ContentType "application/json"
    
    Write-Host "✅ Branch protection successfully applied!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Settings Applied:" -ForegroundColor Cyan
    
    if ($config.required_status_checks) {
        Write-Host "  ✅ Required status checks: $($config.required_status_checks.contexts -join ', ')" -ForegroundColor White
    }
    
    if ($config.required_pull_request_reviews) {
        Write-Host "  ✅ Required PR reviews: $($config.required_pull_request_reviews.required_approving_review_count)" -ForegroundColor White
    }
    
    if ($config.enforce_admins) {
        Write-Host "  ✅ Enforce for administrators" -ForegroundColor White
    }
    
    if ($config.required_linear_history) {
        Write-Host "  ✅ Require linear history" -ForegroundColor White
    }
    
    if (-not $config.allow_force_pushes) {
        Write-Host "  ✅ Block force pushes" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🔍 Verify settings: https://github.com/$repo/settings/branches" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Failed to apply branch protection" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 403) {
        Write-Host ""
        Write-Host "💡 Token may not have sufficient permissions." -ForegroundColor Yellow
        Write-Host "Required permissions:" -ForegroundColor Yellow
        Write-Host "  - repo (Full control of repositories)" -ForegroundColor Yellow
        Write-Host "  - admin:repo_hook (Full control of repository hooks)" -ForegroundColor Yellow
    }
    
    exit 1
}

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Test by creating a PR: gh pr create --title 'Test' --body 'Testing protection'" -ForegroundColor White
Write-Host "  2. Review protection guide: BRANCH_PROTECTION_GUIDE.md" -ForegroundColor White
Write-Host "  3. Update CODEOWNERS file: .github/CODEOWNERS" -ForegroundColor White
