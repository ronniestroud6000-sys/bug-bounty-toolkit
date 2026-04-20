# 06 — Upwork Guide: From Bounty Hunter to Paid Security Auditor

Bug bounty pays per bug. Upwork pays per engagement. Upwork is more reliable income, and **most Upwork buyers are way less sophisticated than HackerOne triagers** — which means the bar to deliver value is actually lower if you've hunted bugs.

This guide is the playbook.

---

## Positioning: what to sell

### Service tiers that convert on Upwork

**Tier 1: Security Audit / Pentest** — $1,500–$8,000 (Upwork sweet spot for solos)
- Web application assessment
- 1-week to 2-week engagement
- Deliverable: a professional PDF report (use `../templates/audit-report.md`)
- Clients: startups needing it for SOC 2 / customer due diligence / funding round

**Tier 2: Source Code Review** — $1,000–$5,000
- Client provides repo access
- You run Semgrep + manual review
- Deliverable: findings report + remediation guidance
- Clients: devs who want a sanity check before shipping

**Tier 3: Security Consultation** — $100–$300/hr
- Advisory, Q&A, architecture review
- Hourly, no deliverable required
- Clients: technical founders who want advice

**Tier 4: Retainer** — $500–$3,000/month
- Ongoing monthly testing, new features as they ship
- Repeat client after a successful one-off audit
- Highest-value relationship on Upwork

### What NOT to offer (at first)

- **Network / infrastructure pentest** — requires separate skillset + licenses (pentesting OS, often Cobalt Strike, legal complexity)
- **Red team** — mature engagement, needs experience
- **Compliance audits** (SOC 2, ISO 27001, PCI-DSS) — these are audit-firm territory, not individual contractor work
- **Incident response** — don't take these jobs until you've run a few

Stick to web app + code review as your bread and butter.

---

## Your Upwork profile

### Title

**Bad:** "Cybersecurity Expert"
**Bad:** "Security Engineer | Pentester | Bug Hunter | 5+ Years Exp"
**Good:** "Web App Security Auditor — Bug Bounty Hunter — Professional PDF Reports"

The title should instantly tell a founder-buyer: this person does X and gives me Y.

### Overview (first 3 lines — Upwork truncates here)

Lead with value, not biography.

> I audit web applications for security flaws and deliver professional reports that satisfy customer due diligence, SOC 2 readiness, and investor requirements. My engagements follow OWASP methodology and result in a documented, prioritized findings list your devs can fix. Recent engagements: [X], [Y], [Z].

Don't open with "I'm a passionate cybersecurity professional..." — every Upwork seller writes that.

### Portfolio items

Even with zero Upwork history, you can populate portfolio with:
- **Redacted** practice engagement (use the `audit-report.md` template, test one of your own sites, screenshot the report cover + table of contents + sample finding)
- Disclosed bug bounty reports (screenshot from HackerOne Hacktivity)
- Sample code review output (Semgrep findings on an open-source project with your added prioritization)

### Rate

- **Getting started (0–5 jobs):** $45–$75/hr or $1,500–$2,500 fixed-price audits
- **Established (5–20 jobs, 5-star rating):** $75–$150/hr or $3,000–$6,000 audits
- **Top rated plus:** $150–$300/hr, premium clients

Don't undercut too far. Buyers equate price with quality. Going to $15/hr flags you as "cheap outsource" not "professional auditor."

---

## Getting your first client

### Where to find jobs

- Search "security audit", "pentest", "web application security", "vulnerability assessment"
- Filter: Fixed-price jobs $1,000+ (filters out low-ball budgets)
- Newly-posted jobs (< 2 hours old) — less competition

### The winning proposal structure

Every proposal should hit these 4 points in <250 words:

1. **Show you read the job** (reference specifics from their post)
2. **Credentialize quickly** (1 sentence on why you're qualified)
3. **Propose the approach** (show methodology — this differentiates you)
4. **Call to action** (invite a 15-min call)

**Template: see `../templates/upwork-proposal.md`**

### Proposal anti-patterns

- ❌ Generic "I have 5 years of experience in cybersecurity..." (screams template)
- ❌ Unprompted resume dump
- ❌ Listing 20 tools you know (buyers don't know what Nuclei is, they don't care)
- ❌ Lowest-price positioning ("I can do this for $100!")
- ❌ No questions — good auditors always have clarifying questions

---

## The engagement flow

```
1. Proposal → client replies
2. Short call (15 min)     ← win or lose here
3. Statement of Work signed ← always get this signed
4. Client provides access   ← staging URL, test accounts, IP allowlist
5. You run recon + audit    ← this toolkit
6. You draft report         ← template
7. Deliver report + review call
8. Offer retainer           ← this is where repeat money lives
```

### The 15-minute call: what to ask

Write these down, ask every client:

1. **What are you worried about?** (surface the real motivation — "investor asked" vs "had an incident" vs "compliance" vs "customer asked" → each implies different report style)
2. **What's in scope?** (domains, subdomains, APIs, mobile apps)
3. **What's out of scope?** (third-party services, production data, DoS testing)
4. **What's your preferred severity framework?** (CVSS? Their own? None?)
5. **Who's the audience for the report?** (dev team? board? auditor?)
6. **What's the timeline?** (gives you the deadline to plan against)
7. **Deliverable preference?** (PDF? Google Doc? Notion? Jira tickets?)

These questions **signal professionalism** and get you paid at higher rates.

### Statement of Work

Use `../templates/scope-of-work.md`. Get signed before starting. Covers:
- In-scope assets
- Out-of-scope assets
- Testing dates
- Authorization grant (legal protection!)
- Deliverable
- Payment terms (50% upfront, 50% on delivery is standard on Upwork)
- Retest inclusion

---

## Running the engagement

### Day 1: kickoff + recon

- Confirm scope in writing
- Run `./recon/full-recon.sh target.com --deep`
- Note: 2+ hour timer — plan dinner/walk during the scan

### Days 2–4: manual testing

- Prioritize hosts by `report.md` output
- Test each interesting host against the `04-bug-classes.md` checklist
- Keep a private notes doc per host — you'll refer back

### Days 5–6: code review (if in scope)

```bash
# Clone their repo
git clone <repo>
cd <repo>

# Run via the Semgrep MCP:
# In Claude Code: "Run semgrep with p/security-audit, p/owasp-top-ten, and the appropriate language pack. Summarize all high-severity findings with file paths and line numbers."

# Or CLI:
semgrep --config=auto --config=p/owasp-top-ten .
```

### Day 7: report drafting

Use `../templates/audit-report.md`. The template has sections pre-built so you're filling in, not starting from blank.

### Day 8: final review + delivery

- Re-verify every finding is reproducible (the embarrassment of a finding that's wrong is career-ending)
- Export to PDF (`pandoc report.md -o report.pdf`)
- Schedule a 30-min review call

### Delivery call: how to end strong

Two objectives:
1. Walk the client through findings (they can ask questions live)
2. **Offer the retainer** — "Would you like me to re-test after you've implemented fixes? I also offer monthly ongoing testing at $X/month."

Roughly 30% of one-off clients convert to retainer if offered during delivery.

---

## Avoiding legal landmines

**Always:**
- Get written authorization (SOW or email) before touching any system
- Stay strictly in scope
- Don't test production data (use staging / test accounts)
- Don't use DoS / destructive techniques without explicit permission
- Carry professional liability insurance if you're doing >$10K in revenue/year

**US:** CFAA (Computer Fraud and Abuse Act) protects clients. Authorization is your shield.
**EU:** GDPR adds data-protection requirements if you touch personal data — discuss before the engagement.
**UK:** Computer Misuse Act.

**Templates with protective language:** `../templates/engagement-letter.md` has indemnification language. Have a lawyer review before using for your first high-value engagement.

---

## Scaling from solo to small firm

Path most Upwork auditors take:

1. **Months 1–6:** solo, 1-2 audits/month, $3K–$10K/month revenue
2. **Months 6–12:** 3-4 audits/month + a retainer or two, $10K–$25K/month
3. **Year 2:** productize (fixed scope / fixed price), add an associate for scalable hours
4. **Year 3+:** stop using Upwork for lead gen, direct clients only

Upwork is a **starting platform**, not a career. Once you have 5+ successful engagements, start:
- Building direct-client relationships
- Writing public content (blog posts on findings you've disclosed, talks at local meetups)
- Getting referrals

---

## Next

[`07-ethics-and-legal.md`](07-ethics-and-legal.md) — the rules that keep you out of prison.
