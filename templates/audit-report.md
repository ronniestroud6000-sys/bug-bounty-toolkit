# Security Assessment Report — [Client Name]

**Prepared for:** [Client Name]
**Prepared by:** [Your Name / Company]
**Engagement dates:** [YYYY-MM-DD] – [YYYY-MM-DD]
**Report date:** [YYYY-MM-DD]
**Report version:** 1.0
**Classification:** Confidential

---

## Executive summary

This report documents a security assessment of [Client]'s [application / system name], conducted from [start date] through [end date]. The assessment covered [in-scope targets] and identified **[N] findings**: [N critical], [N high], [N medium], [N low], [N informational].

### Key findings

- **[Finding title 1]** — [One-sentence impact]. (Critical)
- **[Finding title 2]** — [One-sentence impact]. (High)
- **[Finding title 3]** — [One-sentence impact]. (High)
- *[...top 5 max in the exec summary]*

### Overall risk posture

[One paragraph. Even-handed. Examples:]

- *"The application demonstrates a mature security baseline — input validation, authentication, and session handling are correctly implemented in most areas. The findings below represent specific, remediable issues rather than systemic weaknesses."*
- *"The application has several serious security gaps that require prompt remediation before production deployment, including [high-level categories]. Addressing the critical and high findings should be prioritized."*

### Recommended next steps

1. [Immediate action, e.g., "Remediate the two critical findings within 7 days"]
2. [Medium-term, e.g., "Address high-severity findings in the next sprint"]
3. [Process, e.g., "Implement automated security scanning in CI pipeline"]
4. [Re-engagement, e.g., "Schedule a retest 30 days after remediation to validate fixes"]

---

## Scope

### In-scope assets

| Type | Identifier | Notes |
|------|-----------|-------|
| Web application | https://app.[client].com | Production (read-only testing only) |
| API | https://api.[client].com | Full testing permitted |
| Staging environment | https://staging.[client].com | Full testing permitted |
| Source code | Repository provided 2024-01-15 | Static analysis only |

### Out-of-scope assets

- [Third-party services, unrelated subdomains, specific excluded endpoints]
- DoS / stress testing
- Social engineering, phishing, physical access
- Production user data / PII exfiltration

### Methodology

The assessment followed industry-standard methodologies, including:
- OWASP Web Security Testing Guide (WSTG) v4.2
- OWASP API Security Top 10 (2023)
- Manual testing augmented by automated tooling ([nuclei], [semgrep], [katana], [subfinder], [ffuf])
- Both authenticated and unauthenticated testing perspectives

### Severity framework

Findings are rated using CVSS 3.1 with the following severity mapping:

| Severity | CVSS Score | Definition |
|----------|-----------|-----------|
| Critical | 9.0–10.0 | Immediate exploitation leading to severe business impact |
| High | 7.0–8.9 | Significant security impact, exploitable with moderate effort |
| Medium | 4.0–6.9 | Moderate impact, often requiring specific conditions |
| Low | 0.1–3.9 | Minor issues, limited real-world impact |
| Informational | N/A | Not directly exploitable but worth noting |

---

## Findings summary

| ID | Severity | Title | Status |
|----|----------|-------|--------|
| F-001 | Critical | [Title] | Open |
| F-002 | High | [Title] | Open |
| F-003 | High | [Title] | Open |
| F-004 | Medium | [Title] | Open |
| F-005 | Medium | [Title] | Open |
| F-006 | Low | [Title] | Open |
| F-007 | Informational | [Title] | Open |

---

## Detailed findings

### F-001 — [Finding Title]

**Severity:** Critical (CVSS 9.8 — AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
**Affected:** [specific endpoint / component]
**Status:** Open

#### Description

[Technical description of the vulnerability. 1-2 paragraphs. What is the bug? Why does it exist? What class does it belong to?]

#### Steps to reproduce

```
1. [Step-by-step reproduction]
2. [Copy-pasteable commands / payloads]
3. ...
```

#### Proof

[Screenshot or terminal output showing the vulnerability. Include in final PDF as embedded image.]

#### Impact

[Business impact. What does this let an attacker do? What's at risk?]

#### Recommendation

**Short-term (immediate):**
- [Specific code change or configuration update]

**Long-term:**
- [Systemic fix — process, testing, architecture]

#### References

- CWE-[ID]: [Title]
- OWASP: [Link]
- Patch reference (if a known CVE): [Link]

---

### F-002 — [Finding Title]

*(Repeat finding structure for each finding.)*

---

*(Continue for all findings. Group informational findings in a compact table at the end if there are many.)*

---

## Positive observations

Not everything found was a problem. Areas where [Client] demonstrated strong security practice:

- [Thing they did well, e.g., "Content Security Policy headers correctly configured on all pages"]
- [Another thing, e.g., "Password reset tokens expire appropriately and cannot be reused"]
- [etc.]

---

## Appendix A: Tools used

| Tool | Purpose |
|------|---------|
| nuclei | Template-based vulnerability scanning |
| subfinder / httpx / katana | Asset discovery and crawling |
| ffuf | Content and parameter discovery |
| semgrep | Static code analysis (SAST) |
| Burp Suite / Caido | Manual HTTP proxy testing |
| Custom scripts | [Any bespoke tooling built for this engagement] |

## Appendix B: Test account details

*(If applicable — or note "Test accounts provided by client, not reproduced here for confidentiality.")*

## Appendix C: Timeline

| Date | Activity |
|------|---------|
| [YYYY-MM-DD] | Kickoff call with [Client] |
| [YYYY-MM-DD] | Automated recon completed |
| [YYYY-MM-DD] | Manual testing phase 1 (unauthenticated) |
| [YYYY-MM-DD] | Manual testing phase 2 (authenticated) |
| [YYYY-MM-DD] | Code review phase |
| [YYYY-MM-DD] | Draft report delivered |
| [YYYY-MM-DD] | Final report delivered |

## Appendix D: Disclaimer

This report represents findings discovered during the testing period. Security is a moving target — new vulnerabilities may be introduced, and third-party dependencies may develop new issues over time. This report reflects the assessment scope and time-boxed effort as documented. [Your Name / Company] recommends periodic re-assessment.

---

**Prepared by:** [Your Name], [Title]
**Contact:** [email] / [phone]
**Report delivered:** [YYYY-MM-DD]
