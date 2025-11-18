#!/bin/bash
# Branch Protection Quick Setup Script
# This script helps you set up branch protection for your GitHub repository

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
BRANCH="${1:-main}"
LEVEL="${2:-standard}"
TOKEN="${GITHUB_TOKEN:-}"

# Validate inputs
if [[ ! "$BRANCH" =~ ^(main|staging|production)$ ]]; then
    echo -e "${RED}❌ Error: Branch must be one of: main, staging, production${NC}"
    exit 1
fi

if [[ ! "$LEVEL" =~ ^(minimal|standard|strict)$ ]]; then
    echo -e "${RED}❌ Error: Level must be one of: minimal, standard, strict${NC}"
    exit 1
fi

echo -e "${CYAN}🔒 Branch Protection Setup${NC}"
echo "============================================================"

# Check if token is provided
if [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ Error: GitHub token not found${NC}"
    echo ""
    echo -e "${YELLOW}Please provide a token in one of these ways:${NC}"
    echo -e "${YELLOW}  1. Set environment variable: export GITHUB_TOKEN='your_token'${NC}"
    echo -e "${YELLOW}  2. Pass as first argument: ./setup-branch-protection.sh main standard your_token${NC}"
    echo ""
    echo -e "${CYAN}Create a token at: https://github.com/settings/tokens${NC}"
    echo -e "${CYAN}Required scopes: repo, admin:repo_hook${NC}"
    exit 1
fi

# Get repository information
if ! git remote get-url origin &>/dev/null; then
    echo -e "${RED}❌ Error: Not a git repository${NC}"
    exit 1
fi

GIT_REMOTE=$(git remote get-url origin)
if [[ $GIT_REMOTE =~ github\.com[:/](.+)\.git ]]; then
    REPO="${BASH_REMATCH[1]}"
elif [[ $GIT_REMOTE =~ github\.com[:/](.+)$ ]]; then
    REPO="${BASH_REMATCH[1]}"
else
    echo -e "${RED}❌ Error: Cannot parse GitHub repository from git remote${NC}"
    exit 1
fi

echo -e "${GREEN}📦 Repository: $REPO${NC}"
echo -e "${GREEN}🌿 Branch: $BRANCH${NC}"
echo -e "${GREEN}📊 Protection Level: $LEVEL${NC}"
echo ""

# Define protection configurations
case $LEVEL in
    minimal)
        PAYLOAD='{
          "required_status_checks": null,
          "enforce_admins": false,
          "required_pull_request_reviews": null,
          "restrictions": null,
          "required_linear_history": false,
          "allow_force_pushes": true,
          "allow_deletions": false
        }'
        ;;
    
    standard)
        PAYLOAD='{
          "required_status_checks": {
            "strict": true,
            "contexts": ["build", "type-lint", "CI (pnpm checks)"]
          },
          "enforce_admins": false,
          "required_pull_request_reviews": {
            "dismiss_stale_reviews": true,
            "require_code_owner_reviews": false,
            "required_approving_review_count": 1
          },
          "restrictions": null,
          "required_linear_history": false,
          "allow_force_pushes": false,
          "allow_deletions": false,
          "required_conversation_resolution": true
        }'
        ;;
    
    strict)
        PAYLOAD='{
          "required_status_checks": {
            "strict": true,
            "contexts": ["build", "type-lint", "CI (pnpm checks)", "backend", "frontend"]
          },
          "enforce_admins": true,
          "required_pull_request_reviews": {
            "dismiss_stale_reviews": true,
            "require_code_owner_reviews": true,
            "required_approving_review_count": 2,
            "require_last_push_approval": true
          },
          "restrictions": null,
          "required_linear_history": true,
          "allow_force_pushes": false,
          "allow_deletions": false,
          "required_conversation_resolution": true,
          "lock_branch": false,
          "allow_fork_syncing": true
        }'
        ;;
esac

echo -e "${CYAN}🚀 Applying branch protection...${NC}"

# Apply branch protection
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$REPO/branches/$BRANCH/protection" \
  -d "$PAYLOAD")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
    echo -e "${GREEN}✅ Branch protection successfully applied!${NC}"
    echo ""
    echo -e "${CYAN}📋 Settings Applied:${NC}"
    
    case $LEVEL in
        minimal)
            echo "  ✅ Block branch deletion"
            echo "  ⚠️  Allow force pushes (use with caution)"
            ;;
        standard)
            echo "  ✅ Required status checks: build, type-lint, CI (pnpm checks)"
            echo "  ✅ Required PR reviews: 1"
            echo "  ✅ Dismiss stale reviews"
            echo "  ✅ Require conversation resolution"
            echo "  ✅ Block force pushes"
            ;;
        strict)
            echo "  ✅ Required status checks: build, type-lint, CI (pnpm checks), backend, frontend"
            echo "  ✅ Required PR reviews: 2"
            echo "  ✅ Require code owner approval"
            echo "  ✅ Enforce for administrators"
            echo "  ✅ Require linear history"
            echo "  ✅ Block force pushes"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}🔍 Verify settings: https://github.com/$REPO/settings/branches${NC}"
    
else
    echo -e "${RED}❌ Failed to apply branch protection${NC}"
    echo ""
    echo -e "${RED}HTTP Status: $HTTP_CODE${NC}"
    echo "$BODY" | jq -r '.message // .' 2>/dev/null || echo "$BODY"
    
    if [ "$HTTP_CODE" -eq 401 ] || [ "$HTTP_CODE" -eq 403 ]; then
        echo ""
        echo -e "${YELLOW}💡 Token may not have sufficient permissions.${NC}"
        echo -e "${YELLOW}Required permissions:${NC}"
        echo -e "${YELLOW}  - repo (Full control of repositories)${NC}"
        echo -e "${YELLOW}  - admin:repo_hook (Full control of repository hooks)${NC}"
    fi
    
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${CYAN}📚 Next Steps:${NC}"
echo "  1. Test by creating a PR: gh pr create --title 'Test' --body 'Testing protection'"
echo "  2. Review protection guide: BRANCH_PROTECTION_GUIDE.md"
echo "  3. Update CODEOWNERS file: .github/CODEOWNERS"
