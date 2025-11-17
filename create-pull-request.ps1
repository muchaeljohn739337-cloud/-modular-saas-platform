# Create Pull Request for Weather API SaaS

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CREATE PULL REQUEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

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

# Check current branch
try {
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>&1
    Write-Host "Current branch: $currentBranch`n" -ForegroundColor White
} catch {
    Write-Host "❌ Not in a git repository" -ForegroundColor Red
    exit 1
}

# Check for uncommitted changes
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  You have uncommitted changes:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 1: Create Feature Branch" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($currentBranch -eq "feature/weather-api-saas") {
    Write-Host "✅ Already on feature branch: $currentBranch`n" -ForegroundColor Green
} else {
    Write-Host "Current branch: $currentBranch" -ForegroundColor White
    Write-Host "Suggested branch name: feature/weather-api-saas`n" -ForegroundColor Yellow
    
    Write-Host "Create new branch? (Y/N): " -ForegroundColor Yellow -NoNewline
    $createBranch = Read-Host
    
    if ($createBranch -eq "Y" -or $createBranch -eq "y") {
        git checkout -b feature/weather-api-saas
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Created and switched to: feature/weather-api-saas`n" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create branch`n" -ForegroundColor Red
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 2: Stage and Commit Changes" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Files to commit:" -ForegroundColor Yellow
Write-Host "  Backend:" -ForegroundColor Cyan
Write-Host "    - backend/src/routes/weatherSaas.ts (602 lines)" -ForegroundColor White
Write-Host "    - backend/__tests__/routes/weather.test.ts (186 lines)" -ForegroundColor White
Write-Host "    - backend/prisma/schema.prisma (updated)" -ForegroundColor White
Write-Host "    - backend/prisma/migrations/* (4 migrations)" -ForegroundColor White
Write-Host "    - backend/src/index.ts (updated)" -ForegroundColor White
Write-Host "    - backend/.env.example (updated)`n" -ForegroundColor White

Write-Host "  Frontend:" -ForegroundColor Cyan
Write-Host "    - frontend/src/components/WeatherSaaSDashboard.tsx (521 lines)" -ForegroundColor White
Write-Host "    - frontend/src/app/weather/page.tsx (14 lines)`n" -ForegroundColor White

Write-Host "  Documentation:" -ForegroundColor Cyan
Write-Host "    - WEATHER_SAAS_README.md" -ForegroundColor White
Write-Host "    - WEATHER_SAAS_SETUP.md" -ForegroundColor White
Write-Host "    - WEATHER_SAAS_BUSINESS_MODEL.md" -ForegroundColor White
Write-Host "    - WEATHER_SAAS_TRANSFORMATION.md" -ForegroundColor White
Write-Host "    - WEATHER_API_QUICK_REFERENCE.md" -ForegroundColor White
Write-Host "    - WEATHER_API_IMPLEMENTATION_COMPLETE.md" -ForegroundColor White
Write-Host "    - .github/WEATHER_API_IMPLEMENTATION_CHECKLIST.md" -ForegroundColor White
Write-Host "    - .github/ISSUE_TEMPLATE/weather_api_saas.md" -ForegroundColor White
Write-Host "    - .github/PULL_REQUEST_TEMPLATE_WEATHER_SAAS.md`n" -ForegroundColor White

Write-Host "  Scripts:" -ForegroundColor Cyan
Write-Host "    - test-weather-api.ps1" -ForegroundColor White
Write-Host "    - create-github-issue.ps1" -ForegroundColor White
Write-Host "    - create-pull-request.ps1`n" -ForegroundColor White

Write-Host "Stage all files? (Y/N): " -ForegroundColor Yellow -NoNewline
$stageFiles = Read-Host

if ($stageFiles -eq "Y" -or $stageFiles -eq "y") {
    Write-Host "`nStaging files..." -ForegroundColor Cyan
    git add backend/src/routes/weatherSaas.ts
    git add backend/__tests__/routes/weather.test.ts
    git add backend/prisma/schema.prisma
    git add backend/prisma/migrations/
    git add backend/src/index.ts
    git add backend/.env.example
    git add frontend/src/components/WeatherSaaSDashboard.tsx
    git add frontend/src/app/weather/
    git add WEATHER_*.md
    git add .github/WEATHER_*.md
    git add .github/ISSUE_TEMPLATE/weather_api_saas.md
    git add .github/PULL_REQUEST_TEMPLATE_WEATHER_SAAS.md
    git add test-weather-api.ps1
    git add create-github-issue.ps1
    git add create-pull-request.ps1
    
    Write-Host "✅ Files staged`n" -ForegroundColor Green
    
    Write-Host "Commit message:" -ForegroundColor Yellow
    $commitMessage = @"
feat: Add Weather API SaaS with tiered subscriptions

- Implement 4-tier subscription model (FREE/PRO/BUSINESS/ENTERPRISE)
- Add 8 RESTful endpoints with rate limiting and feature gating
- Create database schema with usage tracking and analytics
- Build SaaS dashboard with pricing modal and usage stats
- Add comprehensive documentation (8 guides)
- Include test scripts and GitHub templates

Revenue potential: `$50K-360K/year
Profit margin: 96%+

Backend:
- weatherSaas.ts: Complete API with middleware (602 lines)
- Prisma models: SubscriptionTier, WeatherApiUsage, WeatherAlert
- Rate limiting: Daily quotas per tier (50-25,000 calls/day)
- Feature gating: Forecast (Pro+), Batch (Business+), Alerts (Pro+)
- Usage tracking: Analytics with city, response time, caching

Frontend:
- WeatherSaaSDashboard.tsx: Full SaaS UI (521 lines)
- Real-time usage progress bar with color coding
- Interactive pricing modal with 4-tier comparison
- Upgrade CTAs when nearing limits

Documentation:
- Business model with revenue projections
- Setup guide with step-by-step instructions
- Quick reference with all test commands
- Implementation checklist
- GitHub issue and PR templates

Testing:
- Unit tests for all endpoints
- No TypeScript errors
- Database migrations applied
- Test scripts for automation

Closes #XXX (add issue number after creating GitHub issue)
"@
    
    Write-Host $commitMessage -ForegroundColor White
    Write-Host "`nCommit with this message? (Y/N): " -ForegroundColor Yellow -NoNewline
    $doCommit = Read-Host
    
    if ($doCommit -eq "Y" -or $doCommit -eq "y") {
        git commit -m $commitMessage
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ Changes committed successfully!`n" -ForegroundColor Green
        } else {
            Write-Host "`n❌ Commit failed`n" -ForegroundColor Red
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 3: Push to Remote" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "Push branch '$currentBranch' to origin? (Y/N): " -ForegroundColor Yellow -NoNewline
$doPush = Read-Host

if ($doPush -eq "Y" -or $doPush -eq "y") {
    Write-Host "`nPushing to origin..." -ForegroundColor Cyan
    git push -u origin $currentBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Pushed successfully!`n" -ForegroundColor Green
    } else {
        Write-Host "❌ Push failed`n" -ForegroundColor Red
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 4: Create Pull Request" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$prTemplatePath = ".\.github\PULL_REQUEST_TEMPLATE_WEATHER_SAAS.md"

if (Test-Path $prTemplatePath) {
    Write-Host "✅ PR template found: $prTemplatePath`n" -ForegroundColor Green
    
    if ($hasGhCli) {
        Write-Host "Create PR with GitHub CLI? (Y/N): " -ForegroundColor Yellow -NoNewline
        $createPR = Read-Host
        
        if ($createPR -eq "Y" -or $createPR -eq "y") {
            Write-Host "`nCreating pull request..." -ForegroundColor Cyan
            
            gh pr create `
                --title "feat: Weather API SaaS with Tiered Subscriptions" `
                --body-file $prTemplatePath `
                --base main `
                --head $currentBranch `
                --label "feature,enhancement,monetization"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n✅ Pull request created successfully!" -ForegroundColor Green
                Write-Host "View your PR in browser? (Y/N): " -ForegroundColor Yellow -NoNewline
                $viewPR = Read-Host
                if ($viewPR -eq "Y" -or $viewPR -eq "y") {
                    gh pr view --web
                }
            } else {
                Write-Host "`n❌ Failed to create pull request" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Manual Steps (without GitHub CLI):" -ForegroundColor Cyan
        Write-Host "1. Go to: https://github.com/muchaeljohn739337-cloud/-modular-saas-platform/compare" -ForegroundColor Yellow
        Write-Host "2. Select base: main" -ForegroundColor Yellow
        Write-Host "3. Select compare: $currentBranch" -ForegroundColor Yellow
        Write-Host "4. Click 'Create pull request'" -ForegroundColor Yellow
        Write-Host "5. Copy content from: $prTemplatePath" -ForegroundColor Yellow
        Write-Host "6. Add labels: feature, enhancement, monetization" -ForegroundColor Yellow
        Write-Host "7. Request reviewers" -ForegroundColor Yellow
        Write-Host "8. Click 'Create pull request'`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  PR template not found at: $prTemplatePath" -ForegroundColor Yellow
    Write-Host "   You'll need to write the PR description manually.`n" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "PR Title:" -ForegroundColor Cyan
Write-Host "  feat: Weather API SaaS with Tiered Subscriptions`n" -ForegroundColor White

Write-Host "Key Highlights:" -ForegroundColor Cyan
Write-Host "  ✅ 8 RESTful API endpoints" -ForegroundColor Green
Write-Host "  ✅ 4-tier subscription model" -ForegroundColor Green
Write-Host "  ✅ Rate limiting & feature gating" -ForegroundColor Green
Write-Host "  ✅ Full SaaS dashboard" -ForegroundColor Green
Write-Host "  ✅ Database migrations applied" -ForegroundColor Green
Write-Host "  ✅ Comprehensive documentation" -ForegroundColor Green
Write-Host "  ✅ Revenue potential: `$50K-360K/year`n" -ForegroundColor Green

Write-Host "What Reviewers Should Check:" -ForegroundColor Cyan
Write-Host "  - Backend API security (rate limiting, auth)" -ForegroundColor Yellow
Write-Host "  - Database schema and migrations" -ForegroundColor Yellow
Write-Host "  - Frontend UI/UX and responsiveness" -ForegroundColor Yellow
Write-Host "  - Documentation completeness" -ForegroundColor Yellow
Write-Host "  - Test coverage" -ForegroundColor Yellow
Write-Host "  - Production readiness`n" -ForegroundColor Yellow

Write-Host "Next Steps After PR Approval:" -ForegroundColor Cyan
Write-Host "  1. Merge to main branch" -ForegroundColor White
Write-Host "  2. Deploy to staging environment" -ForegroundColor White
Write-Host "  3. Run integration tests" -ForegroundColor White
Write-Host "  4. Deploy to production" -ForegroundColor White
Write-Host "  5. Monitor for errors" -ForegroundColor White
Write-Host "  6. Begin marketing campaign`n" -ForegroundColor White
