# Statement of Work — Security Assessment Engagement

> ⚠️ **LEGAL NOTICE:** This template is a starting point, not legal advice. Have a licensed attorney review before using for a real engagement, especially for engagements over $5,000 or involving sensitive industries (healthcare, finance, regulated data).

---

**Statement of Work #:** [SOW-NNN]
**Effective Date:** [YYYY-MM-DD]
**Between:** [Your Company / Legal Name] ("Contractor") and [Client Company / Legal Name] ("Client")

---

## 1. Engagement Overview

Client engages Contractor to perform a security assessment of the systems listed in **Section 2 (Scope)** during the period specified in **Section 3 (Timeline)**. Contractor will deliver the report described in **Section 5 (Deliverables)** for the fee described in **Section 6 (Compensation)**.

## 2. Scope

### 2.1 In-Scope Assets

Contractor is authorized to test the following systems:

| Asset Type | Identifier | Notes / Restrictions |
|-----------|-----------|---------------------|
| Web application | https://[domain] | [Production / Staging — specify] |
| API | https://api.[domain] | [Authenticated endpoints permitted: Y/N] |
| Mobile app | [iOS / Android — if applicable] | [Testing environment provided] |
| Source code | [Repository URL] | [Read-only access] |
| [Other] | [Other] | [Notes] |

### 2.2 Out-of-Scope Assets

The following are **explicitly excluded** from testing:

- Any system not listed in Section 2.1
- Third-party services (AWS infrastructure, Cloudflare, Auth0, Stripe, etc.) except where they expose Client misconfiguration
- Client's corporate network or internal systems
- Client's employees or personal accounts (no social engineering)
- Physical premises
- Production user data / PII exfiltration beyond what is minimally necessary to demonstrate impact

### 2.3 Permitted Testing Activities

- Automated scanning (nuclei, subfinder, httpx, ffuf, semgrep, equivalent)
- Manual HTTP-layer testing (Burp Suite, Caido, equivalent)
- Source code static analysis
- Authenticated testing using test accounts provided by Client
- Review of publicly-available assets (subdomains, public repositories, DNS)

### 2.4 Prohibited Testing Activities

- Denial-of-service attacks, stress testing, resource exhaustion
- Testing that modifies real customer data or sends real-world notifications (emails, SMS)
- Spam or bulk email / SMS sending
- Social engineering of Client employees
- Physical intrusion or evasion of physical security
- Exploitation beyond proof-of-concept necessary to demonstrate impact

## 3. Timeline

- **Engagement start:** [YYYY-MM-DD]
- **Testing period:** [YYYY-MM-DD] through [YYYY-MM-DD]
- **Draft report delivery:** [YYYY-MM-DD]
- **Final report delivery:** [YYYY-MM-DD]
- **Debrief call:** [Within N days of final report]

## 4. Authorization

Client hereby grants Contractor authorization to perform the activities described in Section 2.3 against the assets listed in Section 2.1 during the timeline described in Section 3. This authorization satisfies any "authorization" requirement under applicable computer access laws (including but not limited to the U.S. Computer Fraud and Abuse Act, 18 U.S.C. § 1030, and any state or international equivalents).

Client confirms that it has the authority to grant this authorization — i.e., Client owns or has explicit legal right to test all assets listed in Section 2.1.

**Client Testing Contact (for emergencies during testing):**
- Name: [Contact Name]
- Email: [email]
- Phone: [phone]
- Availability: [business hours / 24x7]

## 5. Deliverables

Contractor will deliver:

1. **Security Assessment Report (PDF)** containing:
   - Executive summary
   - Scope confirmation
   - Methodology summary
   - Detailed findings with severity ratings (CVSS 3.1), proof of concept, and remediation recommendations
   - Positive observations
   - Appendices (tools, timeline, test accounts used)

2. **Debrief call** (up to 1 hour) to walk Client through findings

3. **Retest** (included) of Critical and High findings — Client has [30 / 60] days post-delivery to request retest after implementing fixes. Retest produces a short update document confirming fix status of each retested finding.

Deliverables will be encrypted in transit (password-protected PDF or encrypted cloud share).

## 6. Compensation

**Fee:** $[X,XXX] (fixed price, USD)

**Payment Schedule:**
- **50%** ($[X,XXX]) on signing of this SOW
- **50%** ($[X,XXX]) on delivery of final report

**Payment method:** Via Upwork / direct invoice (net 15 from delivery)

**Expenses:** No expense reimbursement expected unless separately agreed in writing.

## 7. Confidentiality

Contractor will treat all information learned during the engagement as Confidential Information. Contractor will:

- Not disclose Client data to third parties
- Securely destroy all Client data within 60 days of engagement completion (except the report, which Contractor may retain for portfolio purposes in redacted form with Client approval)
- Not use Client findings for any purpose other than this engagement
- Maintain findings in confidence until publicly disclosed by Client or until 2 years post-engagement, whichever is sooner

Client may share the report internally without restriction. External sharing (to auditors, investors, customers) is permitted provided the report is shared as delivered (not modified).

## 8. Limitation of Liability

Contractor's total liability under this SOW shall not exceed the fees paid by Client under this SOW.

Contractor is not liable for:
- Business impact of discovered vulnerabilities
- Fixes implemented by Client based on report recommendations
- Vulnerabilities discovered outside the testing period
- Third-party claims arising from Client's fix or non-fix decisions

## 9. Indemnification

Client indemnifies Contractor against any claim, damage, or legal action arising from testing activities conducted within the scope and authorization granted in this SOW.

## 10. General Terms

- **Governing law:** [State / jurisdiction]
- **Modifications:** This SOW may only be modified in writing signed by both parties
- **Entire agreement:** This SOW is the entire agreement between the parties for the engagement described

---

## Signatures

**Contractor:**

Signature: ___________________________
Name: [Your Name]
Title: [Your Title]
Date: [YYYY-MM-DD]

**Client:**

Signature: ___________________________
Name: [Client Signatory]
Title: [Client Signatory Title]
Date: [YYYY-MM-DD]
