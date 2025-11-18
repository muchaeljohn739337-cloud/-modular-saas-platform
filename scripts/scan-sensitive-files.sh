#!/bin/bash
# Sensitive Files Scanner and Protector
# Scans repository for potentially sensitive files and ensures proper protection

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

FIX_MODE=false
DETAILED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix) FIX_MODE=true; shift ;;
        --detailed) DETAILED=true; shift ;;
        *) shift ;;
    esac
done

echo -e "${CYAN}🔍 Sensitive Files Scanner${NC}"
echo "================================================================================"

ISSUES_COUNT=0
FILES_SCANNED=0
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0

# Function to check if path should be ignored
should_ignore() {
    local path="$1"
    if [[ "$path" =~ (node_modules|\.git|dist|build|\.next|coverage|SECURITY_AUDIT|SECRET_MANAGEMENT_GUIDE|\.example) ]]; then
        return 0
    fi
    return 1
}

# Scan for sensitive file patterns
echo -e "\n${YELLOW}🔎 Scanning for sensitive file patterns...${NC}"

declare -A sensitive_patterns=(
    ["Environment Files"]="*.env .env.* *.env.local *.env.production"
    ["Key Files"]="*.pem *.key *.p12 *.pfx *.asc"
    ["Config Files"]="*secrets*.json *credentials*.json *.keystore"
    ["Database Dumps"]="*.sql *.dump *.backup backup.dump"
    ["SSH/GPG Keys"]="id_rsa* id_dsa* id_ed25519* *.ppk"
)

for category in "${!sensitive_patterns[@]}"; do
    echo -e "\n${CYAN}Checking: $category${NC}"
    patterns="${sensitive_patterns[$category]}"
    
    for pattern in $patterns; do
        while IFS= read -r -d '' file; do
            if ! should_ignore "$file"; then
                # Check if file is tracked by git
                if git ls-files --error-unmatch "$file" &>/dev/null; then
                    echo -e "  ${RED}❌ TRACKED: $file${NC}"
                    ((ISSUES_COUNT++))
                    ((HIGH_COUNT++))
                elif [ "$DETAILED" = true ]; then
                    echo -e "  ${GREEN}✅ Ignored: $file${NC}"
                fi
            fi
        done < <(find . -name "$pattern" -type f -print0 2>/dev/null)
    done
done

# Scan file contents for secrets
echo -e "\n${YELLOW}🔍 Scanning file contents for secrets...${NC}"

declare -a patterns=(
    "CRITICAL:AWS Keys:AKIA[0-9A-Z]{16}"
    "CRITICAL:GitHub Tokens:ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}"
    "CRITICAL:Stripe Live Keys:sk_live_[a-zA-Z0-9]{24,}"
    "CRITICAL:Private Keys:-----BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY-----"
    "HIGH:Hardcoded Passwords:password[[:space:]]*[:=][[:space:]]*['\"][^YOUR_][^'\"]{5,}"
    "HIGH:JWT Secrets:JWT_SECRET[[:space:]]*[:=][[:space:]]*['\"][^YOUR_][^'\"]{10,}"
    "HIGH:Database URLs:postgresql://[^:]+:[^@]+@[^l][^o]"
    "MEDIUM:Stripe Test Keys:sk_test_[a-zA-Z0-9]{24,}"
)

find . -type f \( -name "*.sh" -o -name "*.ps1" -o -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" \) ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/.next/*" 2>/dev/null | while read -r file; do
    ((FILES_SCANNED++))
    
    for pattern_spec in "${patterns[@]}"; do
        IFS=':' read -r severity name pattern <<< "$pattern_spec"
        
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            line_numbers=$(grep -nE "$pattern" "$file" 2>/dev/null | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
            
            case $severity in
                CRITICAL) 
                    echo -e "  ${RED}[CRITICAL] $file:$line_numbers - $name${NC}"
                    ((CRITICAL_COUNT++))
                    ;;
                HIGH)
                    echo -e "  ${YELLOW}[HIGH] $file:$line_numbers - $name${NC}"
                    ((HIGH_COUNT++))
                    ;;
                MEDIUM)
                    echo -e "  ${CYAN}[MEDIUM] $file:$line_numbers - $name${NC}"
                    ((MEDIUM_COUNT++))
                    ;;
            esac
            ((ISSUES_COUNT++))
        fi
    done
done

# Check .gitignore coverage
echo -e "\n${YELLOW}🔒 Checking .gitignore protection...${NC}"

required_ignores=(
    ".env"
    ".env.local"
    ".env.*.local"
    ".env.production"
    ".env.staging"
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx"
    "*secrets*.json"
    "*.dump"
    "backup.dump"
)

if [ -f ".gitignore" ]; then
    for pattern in "${required_ignores[@]}"; do
        if ! grep -qF "$pattern" .gitignore; then
            echo -e "  ${YELLOW}⚠️  Missing: $pattern${NC}"
            ((ISSUES_COUNT++))
            ((MEDIUM_COUNT++))
            
            if [ "$FIX_MODE" = true ]; then
                echo "$pattern" >> .gitignore
                echo -e "  ${GREEN}✅ Added '$pattern' to .gitignore${NC}"
            fi
        fi
    done
else
    echo -e "  ${RED}❌ .gitignore not found!${NC}"
    ((ISSUES_COUNT++))
fi

# Summary Report
echo ""
echo "================================================================================"
echo -e "${CYAN}📊 SCAN SUMMARY${NC}"
echo "================================================================================"

echo -e "\n${WHITE}Files Scanned: $FILES_SCANNED${NC}"

echo -e "\n${WHITE}Issues Found:${NC}"
echo -e "  ${RED}🔴 CRITICAL: $CRITICAL_COUNT${NC}"
echo -e "  ${YELLOW}🟡 HIGH: $HIGH_COUNT${NC}"
echo -e "  ${CYAN}🔵 MEDIUM: $MEDIUM_COUNT${NC}"
echo -e "  ${WHITE}📝 TOTAL: $ISSUES_COUNT${NC}"

if [ $ISSUES_COUNT -gt 0 ]; then
    echo -e "\n${RED}⚠️  ACTION REQUIRED${NC}"
    echo -e "${YELLOW}Review and fix all issues above before committing!${NC}"
    
    if [ "$FIX_MODE" = true ]; then
        echo -e "\n${CYAN}🔧 Automatic fixes applied where possible${NC}"
        echo -e "${YELLOW}⚠️  Manual fixes still required for exposed secrets!${NC}"
        echo -e "${YELLOW}Run: git grep -E '(sk_live_|ghp_|AKIA)' to find and remove them${NC}"
    fi
else
    echo -e "\n${GREEN}✅ No sensitive files or secrets detected!${NC}"
fi

echo -e "\n${CYAN}📚 Recommendations:${NC}"
echo -e "  ${WHITE}1. Review SECRET_MANAGEMENT_GUIDE.md${NC}"
echo -e "  ${WHITE}2. Use environment variables for secrets${NC}"
echo -e "  ${WHITE}3. Never commit .env files${NC}"
echo -e "  ${WHITE}4. Rotate any exposed credentials immediately${NC}"
echo -e "  ${WHITE}5. Enable GitHub secret scanning${NC}"

if [ $ISSUES_COUNT -gt 0 ]; then
    exit 1
fi

exit 0
