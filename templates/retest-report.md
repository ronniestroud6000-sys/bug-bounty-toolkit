# Retest Report — [Client Name]

**Original engagement:** [Original SOW #, dates]
**Retest date:** [YYYY-MM-DD]
**Prepared by:** [Your Name]

---

## Summary

A retest of findings from the [Original Engagement Date] security assessment was performed on [Retest Date]. Of the [N] findings retested, **[X] are confirmed remediated**, **[Y] are partially remediated**, and **[Z] remain open**.

| Status | Count |
|--------|-------|
| ✅ Remediated | X |
| 🟡 Partially remediated | Y |
| ❌ Open | Z |
| Not retested (out of scope) | W |

---

## Retested findings

### F-001 — [Original Finding Title]

- **Original severity:** [Critical / High / etc.]
- **Retest status:** ✅ **Remediated** / 🟡 **Partial** / ❌ **Open**
- **Retest date:** [YYYY-MM-DD]

**Original finding summary:**
[1-2 sentences of the original issue]

**Fix implemented:**
[What did the client do to remediate?]

**Verification:**
```
[Exact test performed to verify the fix — commands, payloads, expected vs actual result]
```

**Conclusion:**
[If remediated]: This finding is confirmed remediated. The original attack vector no longer succeeds; [specific technical reason].

[If partial]: This finding is partially remediated. [What was fixed]. However, [what remains]. Recommend: [specific next step].

[If open]: This finding remains open. The original attack still succeeds with [modified approach / same approach]. Recommend: [specific remediation].

---

### F-002 — [Original Finding Title]

*(Repeat structure for each retested finding.)*

---

## Findings NOT retested

| ID | Reason not retested |
|----|---------------------|
| F-00X | Out of retest scope (informational only) |
| F-00Y | Client confirmed accepted risk |

---

## New findings discovered during retest

*(Retesting sometimes surfaces new issues. If any, document here using the same structure as a new engagement finding.)*

None / [List findings here]

---

## Recommendations

1. [Actions for findings still open]
2. [Ongoing security hardening recommendations based on what you observed during retest]
3. [Suggestion for next engagement — quarterly retainer, retest in 6 months, etc.]

---

**Prepared by:** [Your Name]
**Contact:** [email]
**Report delivered:** [YYYY-MM-DD]
