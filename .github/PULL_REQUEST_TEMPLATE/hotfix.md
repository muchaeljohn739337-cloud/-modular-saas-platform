---
name: 🔥 Hotfix PR
about: Urgent production fix requiring immediate deployment
title: "hotfix: [Brief description of critical issue]"
labels: ["hotfix", "critical", "needs-review"]
---

## 🚨 CRITICAL ISSUE

<!-- Clear description of the production problem -->

### Impact

- [ ] Production down
- [ ] Data loss risk
- [ ] Security vulnerability
- [ ] Payment processing blocked
- [ ] User authentication broken
- [ ] Other critical functionality broken

### Affected Users

<!-- Describe who is impacted -->

- All users / Specific users / Admin only
- Estimated impact: [number] users or [percentage]%

### When did this start?

<!-- Timestamp or event that triggered the issue -->

Started: [Date/Time]
Duration: [X hours/minutes]

---

## 🔗 Related Issues

Fixes #
Emergency fix for #

---

## 🔧 Hotfix Solution

<!-- Describe the immediate fix -->

### Root Cause

<!-- Brief explanation of what caused the issue -->

### Immediate Fix

<!-- What this PR does to resolve the issue -->

1.
2.
3.

### Why this approach?

<!-- Justify the quick fix approach -->

---

## ⚡ Verification

### Tested in Production-like Environment

- [ ] Tested against production database snapshot
- [ ] Tested with production environment variables
- [ ] Tested with production-scale data
- [ ] Verified fix resolves the issue

### Rollback Tested

- [ ] Rollback procedure tested
- [ ] Rollback takes <5 minutes
- [ ] Database state verified after rollback

---

## 🚀 Deployment Plan

### Immediate Steps

1. **Backup:** [What to backup before deploying]
2. **Deploy:** [Deployment command/process]
3. **Verify:** [How to confirm fix is working]
4. **Monitor:** [What metrics to watch]

### Deployment Timeline

- **Estimated deployment time:** [X minutes]
- **Estimated verification time:** [X minutes]
- **Total downtime expected:** [X minutes] or [No downtime]

### Rollback Procedure (if fix fails)

```bash
# Immediate rollback steps:
1. git revert <commit-hash>
2. Deploy previous version
3. Verify services restored
4. Alert team
```

---

## 📊 Monitoring

### Metrics to Watch Post-Deploy

- [ ] Error rate returns to normal
- [ ] API response times acceptable
- [ ] Database connections stable
- [ ] Payment success rate restored
- [ ] User authentication success rate
- [ ] [Other relevant metric]

### Alert Thresholds

```
Error rate: < [X]%
Response time: < [X]ms
Success rate: > [X]%
```

---

## 🔒 Security Impact

- [ ] No security implications
- [ ] Security vulnerability patched
- [ ] Requires immediate security review
- [ ] Customer data protected
- [ ] Audit log entry created

---

## ✅ Hotfix Checklist

- [ ] Issue confirmed in production
- [ ] Fix tested in staging/local
- [ ] Rollback plan documented
- [ ] Deployment steps documented
- [ ] On-call team notified
- [ ] Stakeholders notified
- [ ] Monitoring dashboard ready
- [ ] Post-deployment verification plan ready

---

## 📞 Communication

### Who was notified?

- [ ] Engineering team
- [ ] Product team
- [ ] Customer support
- [ ] Management
- [ ] Customers (if needed)

### Incident Channel

<!-- Link to Slack channel or incident management system -->

- Slack: #incidents
- Incident ID:

---

## 🔄 Post-Hotfix Tasks

<!-- Create follow-up issues for these -->

- [ ] Write post-mortem (link to issue: #)
- [ ] Add regression tests (link to issue: #)
- [ ] Implement permanent fix (link to issue: #)
- [ ] Update monitoring/alerting (link to issue: #)
- [ ] Review similar code for same issue (link to issue: #)

---

## 📝 Technical Details

### Error Logs

```
[Paste relevant error logs]
```

### Stack Trace

```
[Paste stack trace if applicable]
```

### Database Query (if applicable)

```sql
-- Query causing issue or fix query
```

---

## ⚠️ MERGE IMMEDIATELY AFTER APPROVAL

**This is a hotfix. Once approved, merge and deploy immediately.**

Required approvals: **1 senior engineer**
