# 🚀 Sample Pull Request

## Summary

Added subscription upgrade feature with full agent workflow.

---

## Changes

- [x] Feature: User can upgrade subscription plan
- [x] Backend: Added POST /api/subscription/upgrade
- [x] Frontend: Created SubscriptionUpgradeModal component
- [x] Tests: Added backend and frontend tests
- [x] Docs: Updated README and API docs

---

## Checklist

### Code Quality

- [x] Code follows project conventions
- [x] No duplicated logic added
- [x] Feature is tenant-safe (for SaaS)

### Tests

- [x] Tests updated or created
  - Used `@saas-tests create tests for subscriptionController.js`
  - Used `@saas-tests create tests for SubscriptionUpgradeModal.jsx`

### Documentation

- [x] Docs updated
  - Used `@saas-docs update README.md with subscription upgrade instructions`

### Security

- [x] No sensitive data logged
- [x] Permissions correctly applied
  - Used `@saas-security audit subscription feature`

### Architecture

- [x] Follows project structure
  - Used `@saas-architect review folder structure for new subscription feature`

---

## Automation Helpers Used

- `@saas-fixer scan diff for issues`
- `@saas-ui-fixer fix SubscriptionUpgradeModal.jsx`
- `@saas-api-sync compare backend and frontend API usage`
- `@saas-performance scan SubscriptionUpgradeModal.jsx`
- `@saas-migrations review pending migrations`
- `@saas-devops validate Dockerfile and CI`
- `@saas-errors standardize error handling in backend/src/services`
- `@saas-release generate changelog and bump version`

---

## Screenshots / Outputs

_Attach relevant screenshots or logs here._

---

## Notes

- All agent suggestions followed repo conventions (see `.github/copilot-instructions.md`).
- No critical issues found in final scan.

---

**PR scanned and documented using Copilot agents for full workflow coverage.**
