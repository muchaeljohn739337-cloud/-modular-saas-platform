# 🗂️ Copilot Agent Workflow Diagram

Below is an ASCII diagram showing how all 12 Copilot agents interact across a typical SaaS feature development cycle. Use this for onboarding new developers!

```
+-------------------+
| 1. Architect      |
| @saas-architect   |
+-------------------+
          |
          v
+-------------------+
| 2. Backend        |
| @saas-fixer       |
+-------------------+
          |
          v
+-------------------+
| 3. Frontend       |
| @saas-ui-fixer    |
+-------------------+
          |
          v
+-------------------+
| 4. API Sync       |
| @saas-api-sync    |
+-------------------+
          |
          v
+-------------------+
| 5. Tests          |
| @saas-tests       |
+-------------------+
          |
          v
+-------------------+
| 6. Security       |
| @saas-security    |
+-------------------+
          |
          v
+-------------------+
| 7. Performance    |
| @saas-performance |
+-------------------+
          |
          v
+-------------------+
| 8. Migrations     |
| @saas-migrations  |
+-------------------+
          |
          v
+-------------------+
| 9. DevOps         |
| @saas-devops      |
+-------------------+
          |
          v
+-------------------+
| 10. Docs          |
| @saas-docs        |
+-------------------+
          |
          v
+-------------------+
| 11. Errors        |
| @saas-errors      |
+-------------------+
          |
          v
+-------------------+
| 12. Release       |
| @saas-release     |
+-------------------+
```

**How to use:**

- Start at the top (architecture), move down through each agent as you build, test, secure, optimize, document, and release a feature.
- Each agent automates or guides its stage, ensuring a complete, safe, and well-documented dev cycle.

**Recommended Onboarding Tips:**

- Always start with `@saas-architect` to confirm folder structure and naming before coding.
- Use `@saas-fixer` and `@saas-ui-fixer` for fast bug detection and safe code fixes.
- Run `@saas-api-sync` after backend/frontend changes to keep API contracts in sync.
- Generate and update tests with `@saas-tests` for every new feature or fix.
- Audit security and permissions with `@saas-security` before merging.
- Scan for performance bottlenecks with `@saas-performance` on key components and endpoints.
- Validate database migrations with `@saas-migrations` before applying to production.
- Use `@saas-devops` to check Docker, CI/CD, and deployment scripts.
- Update documentation with `@saas-docs` after every major change.
- Standardize error handling and logging with `@saas-errors` for consistency and safety.
- Prepare changelogs and release notes with `@saas-release` before deploying.

**Best Practice:**

- Use agents iteratively—run them after each major step, not just at the end.
- Document agent usage in your PRs and onboarding guides for team consistency.

**Example Commands:**

- Architecture: `@saas-architect review folder structure`
- Backend: `@saas-fixer scan backend/src/routes/*.ts`
- Frontend: `@saas-ui-fixer fix SubscriptionUpgradeModal.jsx`
- API Sync: `@saas-api-sync compare backend and frontend API usage`
- Tests: `@saas-tests create tests for backend/src/services/paymentService.ts`
- Security: `@saas-security audit payments API`
- Performance: `@saas-performance scan backend/src/routes/payments.ts`
- Migrations: `@saas-migrations review pending migrations`
- DevOps: `@saas-devops validate Dockerfile and CI`
- Docs: `@saas-docs update README.md with new endpoints`
- Errors: `@saas-errors standardize error handling in backend/src/services`
- Release: `@saas-release generate changelog and bump version`

**Repo Conventions:**

- Always import Prisma via `backend/src/prismaClient.ts`
- Serialize Decimal fields with `serializeDecimalFields()`
- Register new routes in `backend/src/index.ts`
- Update allowedOrigins in `backend/src/config/index.ts` for new environments
- Use Winston logger for all error and info logs

**Troubleshooting:**

- If agent output doesn’t match repo conventions, check `.github/copilot-instructions.md` or ask a lead dev.

---

**See Also:**

- [Sample Pull Request](.github/SAMPLE_PR.md): Example PR showing agent usage and documentation best practices
