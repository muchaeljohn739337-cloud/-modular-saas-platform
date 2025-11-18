#!/bin/bash
# Pre-commit hook to scan for sensitive files and secrets
# Install: cp scripts/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

echo "🔍 Running sensitive files check..."

# Quick patterns to check in staged files
SENSITIVE_PATTERNS=(
    'sk_live_[a-zA-Z0-9]{24,}'
    'ghp_[a-zA-Z0-9]{36}'
    'gho_[a-zA-Z0-9]{36}'
    'AKIA[0-9A-Z]{16}'
    '-----BEGIN.*PRIVATE KEY-----'
)

# Check staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)
FOUND_ISSUES=false

for file in $STAGED_FILES; do
    # Skip binary files and certain paths
    if [[ "$file" =~ (node_modules|\.git|dist|build|\.next|coverage|\.lock|\.png|\.jpg|\.ico) ]]; then
        continue
    fi
    
    # Check if file is a .env file
    if [[ "$file" =~ \.env($|\.) && ! "$file" =~ \.env\.example$ ]]; then
        echo "❌ ERROR: Attempting to commit .env file: $file"
        echo "   .env files should never be committed!"
        FOUND_ISSUES=true
        continue
    fi
    
    # Check file content for sensitive patterns
    if [ -f "$file" ]; then
        for pattern in "${SENSITIVE_PATTERNS[@]}"; do
            if grep -qE "$pattern" "$file" 2>/dev/null; then
                echo "❌ ERROR: Potential secret found in: $file"
                echo "   Pattern: $pattern"
                FOUND_ISSUES=true
                break
            fi
        done
    fi
done

if [ "$FOUND_ISSUES" = true ]; then
    echo ""
    echo "🚨 COMMIT BLOCKED: Sensitive data detected!"
    echo ""
    echo "Actions required:"
    echo "  1. Remove sensitive data from the files"
    echo "  2. Run: scripts/scan-sensitive-files.sh for detailed scan"
    echo "  3. Review: SECRET_MANAGEMENT_GUIDE.md"
    echo ""
    echo "To skip this check (NOT RECOMMENDED):"
    echo "  git commit --no-verify"
    echo ""
    exit 1
fi

echo "✅ No sensitive data detected"
exit 0
