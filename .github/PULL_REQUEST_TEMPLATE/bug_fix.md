---
name: 🐛 Bug Fix PR
about: Pull request that fixes a bug
title: "fix: [Brief description of bug fix]"
labels: ["bug", "needs-review"]
---

## 🐛 Bug Description

<!-- Clear description of the bug being fixed -->

### What was broken?

<!-- Describe the broken behavior -->

### What's the root cause?

<!-- Explain why the bug occurred -->

---

## 🔗 Related Issues

Fixes #
Closes #

---

## 🔧 Solution

<!-- Describe how the bug was fixed -->

### Changes Made

1.
2.
3.

### Why this approach?

<!-- Explain why this solution was chosen -->

---

## 🧪 Testing

### Reproduction Steps (Before Fix)

1.
2.
3. **Result:** [Broken behavior]

### Verification Steps (After Fix)

1.
2.
3. **Result:** [Expected behavior]

### Test Cases Added

- [ ] Unit test for bug scenario
- [ ] Regression test to prevent recurrence
- [ ] Edge cases covered

---

## ✅ Bug Fix Checklist

- [ ] Root cause identified and documented
- [ ] Fix implemented and tested
- [ ] Tests added to prevent regression
- [ ] No new bugs introduced (tested edge cases)
- [ ] Backend tests pass (`npm test`)
- [ ] Frontend tests pass (if applicable)
- [ ] Production check passes
- [ ] Documentation updated (if needed)

---

## 🔄 Rollback Plan

```bash
# If this fix causes issues, rollback with:
git revert <commit-hash>
# OR
git checkout <previous-working-commit>
```

---

## 📝 Additional Context

<!-- Screenshots, error logs, or other helpful information -->
