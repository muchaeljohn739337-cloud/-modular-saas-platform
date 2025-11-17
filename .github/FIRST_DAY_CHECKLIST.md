# 🟢 First Day Developer Checklist

Welcome to the Advancia SaaS platform! Follow this checklist to get set up and use Copilot agents effectively from day one.

---

## 1. Clone & Install

- [ ] Clone the repository
- [ ] Install dependencies (`npm install` in backend and frontend)
- [ ] Set up your `.env` files

## 2. Review Architecture & Conventions

- [ ] Read `.github/COPILOT_AGENT_WORKFLOW_DIAGRAM.md` for agent workflow
- [ ] Review `.github/copilot-instructions.md` for repo-specific rules

## 3. Workspace Setup

- [ ] Open the project in VS Code
- [ ] Ensure Copilot Chat is enabled

## 4. Try Copilot Agents

- [ ] Run `@saas-architect review folder structure`
- [ ] Run `@saas-fixer scan workspace`
- [ ] Run `@saas-ui-fixer check frontend components`
- [ ] Run `@saas-api-sync compare backend and frontend API usage`
- [ ] Run `@saas-tests create tests for backend/src/services/paymentService.ts`
- [ ] Run `@saas-security audit payments API`
- [ ] Run `@saas-performance scan backend/src/routes/payments.ts`
- [ ] Run `@saas-migrations review pending migrations`
- [ ] Run `@saas-devops validate Dockerfile and CI`
- [ ] Run `@saas-docs update README.md with new endpoints`
- [ ] Run `@saas-errors standardize error handling in backend/src/services`
- [ ] Run `@saas-release generate changelog and bump version`

## 5. Make a Sample PR

- [ ] Create a test branch and make a small change
- [ ] Use Copilot agents to scan and document your PR
- [ ] Reference agent usage in your PR description

## 6. Ask for Help

- [ ] If agent output doesn’t match repo conventions, check `.github/copilot-instructions.md` or ask a lead dev

---

**Tip:** Link to `.github/COPILOT_AGENT_WORKFLOW_DIAGRAM.md` in your README for easy access!

Welcome aboard! 🚀
