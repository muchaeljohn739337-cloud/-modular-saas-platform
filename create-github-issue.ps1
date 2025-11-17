# Create GitHub Issue for Weather API SaaS

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CREATE GITHUB ISSUE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "This script will help you create a GitHub issue using the template.`n" -ForegroundColor Yellow

# Check if gh CLI is installed
try {
    $ghVersion = gh --version 2>&1
    Write-Host "✅ GitHub CLI (gh) is installed" -ForegroundColor Green
    $hasGhCli = $true
} catch {
    Write-Host "⚠️  GitHub CLI (gh) not found" -ForegroundColor Yellow
    Write-Host "   Install from: https://cli.github.com/`n" -ForegroundColor Cyan
    $hasGhCli = $false
}

$templatePath = ".\.github\ISSUE_TEMPLATE\weather_api_saas.md"

if (Test-Path $templatePath) {
    Write-Host "✅ Issue template found: $templatePath`n" -ForegroundColor Green
    
    if ($hasGhCli) {
        Write-Host "Creating issue with GitHub CLI...`n" -ForegroundColor Cyan
        
        # Read the template
        $template = Get-Content $templatePath -Raw
        
        # Extract title from template (look for title: field)
        if ($template -match "title:\s*'?\[?FEATURE\]?\s*(.+?)'?[\r\n]") {
            $title = "[FEATURE] Weather API SaaS with Tiered Subscriptions"
        } else {
            $title = "Weather API SaaS Implementation"
        }
        
        Write-Host "Title: $title" -ForegroundColor White
        Write-Host "`nOption 1 - Create issue now:" -ForegroundColor Cyan
        Write-Host @"
gh issue create ``
    --title "$title" ``
    --body-file "$templatePath" ``
    --label "feature,enhancement,monetization,high-priority"
"@ -ForegroundColor White
        
        Write-Host "`nOption 2 - Create issue and assign team members:" -ForegroundColor Cyan
        Write-Host @"
gh issue create ``
    --title "$title" ``
    --body-file "$templatePath" ``
    --label "feature,enhancement,monetization,high-priority" ``
    --assignee @me
"@ -ForegroundColor White
        
        Write-Host "`nOption 3 - Create issue in interactive mode:" -ForegroundColor Cyan
        Write-Host "gh issue create --body-file `"$templatePath`"`n" -ForegroundColor White
        
        Write-Host "Do you want to create the issue now? (Y/N): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        
        if ($response -eq "Y" -or $response -eq "y") {
            Write-Host "`nCreating issue..." -ForegroundColor Cyan
            gh issue create `
                --title $title `
                --body-file $templatePath `
                --label "feature,enhancement,monetization,high-priority"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n✅ Issue created successfully!" -ForegroundColor Green
            } else {
                Write-Host "`n❌ Failed to create issue" -ForegroundColor Red
            }
        } else {
            Write-Host "`nSkipped. You can create it manually later.`n" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "Manual Steps (without GitHub CLI):" -ForegroundColor Cyan
        Write-Host "1. Go to: https://github.com/muchaeljohn739337-cloud/-modular-saas-platform/issues/new" -ForegroundColor Yellow
        Write-Host "2. Click 'Weather API SaaS Implementation' template (if available)" -ForegroundColor Yellow
        Write-Host "3. Or copy content from: $templatePath" -ForegroundColor Yellow
        Write-Host "4. Add labels: feature, enhancement, monetization, high-priority" -ForegroundColor Yellow
        Write-Host "5. Assign team members" -ForegroundColor Yellow
        Write-Host "6. Click 'Submit new issue'`n" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "❌ Template not found at: $templatePath" -ForegroundColor Red
    Write-Host "   Make sure you're in the repository root directory.`n" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ISSUE DETAILS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Title:" -ForegroundColor Cyan
Write-Host "  [FEATURE] Weather API SaaS with Tiered Subscriptions`n" -ForegroundColor White

Write-Host "Labels:" -ForegroundColor Cyan
Write-Host "  - feature" -ForegroundColor White
Write-Host "  - enhancement" -ForegroundColor White
Write-Host "  - monetization" -ForegroundColor White
Write-Host "  - high-priority`n" -ForegroundColor White

Write-Host "Suggested Assignees:" -ForegroundColor Cyan
Write-Host "  - Backend Team: API optimization & caching" -ForegroundColor White
Write-Host "  - Frontend Team: UI polish & integration" -ForegroundColor White
Write-Host "  - DevOps Team: Deployment & monitoring" -ForegroundColor White
Write-Host "  - QA Team: Testing & validation`n" -ForegroundColor White

Write-Host "Template Location:" -ForegroundColor Cyan
Write-Host "  $templatePath`n" -ForegroundColor White
