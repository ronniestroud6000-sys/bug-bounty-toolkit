# Upwork Proposal Templates

High-conversion proposal templates for security audit job postings.

**Rules for all proposals:**
- Under 250 words
- First sentence references something specific from their job post (proves you read it)
- No "I have X years of experience" — show, don't tell
- End with a question or call-to-action
- Send proposals within 2 hours of job posting whenever possible

---

## Template 1: Web Application Audit (most common)

> Hi [Client first name if visible, otherwise skip the greeting],
>
> I saw you're looking for a security assessment of [specific thing from their post — "your React + Node e-commerce platform", "your customer-facing SaaS API", etc.]. Happy to help.
>
> My approach for engagements like this:
>
> 1. **Recon & attack-surface mapping** (day 1-2) — I enumerate all in-scope assets, fingerprint the tech stack, and identify the highest-value testing targets.
> 2. **Manual testing** (days 3-5) — I work through the OWASP WSTG methodology: authentication, authorization, input handling, business logic. I use automated tools (nuclei, semgrep) to accelerate but never replace manual review.
> 3. **Report delivery** (day 6-7) — You receive a professional PDF report with an executive summary, prioritized findings, reproduction steps, CVSS scores, and specific remediation guidance your devs can act on.
>
> I'd like to understand a bit more before quoting exactly — specifically:
> - What's the primary driver for this audit? (Investor / customer due diligence / SOC 2 / general hardening?)
> - What's in scope beyond the main app? (APIs, admin panels, mobile apps?)
> - Do you have staging / test accounts you can provide, or do I test against production?
>
> Happy to jump on a quick 15-minute call to scope this properly. My typical engagements for this size land in the [$X,XXX–$Y,XXX] range depending on scope.
>
> Best,
> [Your Name]

---

## Template 2: Source Code Review

> Hi,
>
> Your post mentions [specific tech from their job — "a Django backend", "a Go microservice", etc.] needing a security review. Code review is my bread and butter for engagements like this.
>
> My process:
>
> 1. **SAST sweep** — I run semgrep with OWASP Top 10 rules plus language-specific security packs. This catches the baseline ~70% of issues fast.
> 2. **Manual review of the critical paths** — authentication, authorization, input validation, crypto usage, secrets handling, third-party integrations. These are where real vulnerabilities hide.
> 3. **Dependency audit** — CVE scan of third-party packages, flag outdated or abandoned deps.
> 4. **Report** — prioritized findings (file + line numbers), severity ratings, remediation code snippets where helpful.
>
> A few scoping questions:
> - How many lines of code? (Rough is fine — "<10k", "~50k", "~200k+")
> - Any specific areas you want prioritized, or a broad review?
> - Do you use CI? I can drop the semgrep rules into your pipeline for ongoing scanning as a bonus.
>
> Available to start within 48 hours. Happy to hop on a call to scope.
>
> [Your Name]

---

## Template 3: Low-budget / first client (<$500 range)

*Use this only when building initial portfolio. Skip once you have 3+ five-star reviews.*

> Hi,
>
> Your [app / site] jumped out — I'd love to do a security quick-check as a starter engagement.
>
> For this budget I'd scope it as:
>
> - Automated recon + vulnerability scan (nuclei, semgrep)
> - 4 hours of manual testing focused on the [specific feature from post] and authentication/authorization
> - A short, actionable findings report (4-8 pages)
>
> This is deliberately narrower than a full pentest, but it will catch common issues and give you a real baseline. I'm happy to offer this rate because I'm building my Upwork portfolio — in exchange, I'd ask for honest feedback and a review on completion.
>
> Turnaround: 3-4 days.
>
> Interested? Reply with access to the [site / app] and I can start tomorrow.
>
> [Your Name]

---

## Template 4: Follow-up / retainer pitch (for completed engagements)

*Send after delivering the final report, after the 5-star review is in the bag.*

> Hi [Name],
>
> Thanks again for the 5-star review on [engagement]. Quick thought:
>
> Security isn't a one-and-done — every feature release introduces new potential issues. A lot of my clients find it useful to have me on a monthly retainer for ongoing lightweight testing as you ship.
>
> Retainer would cover:
>
> - **~4 hours/month** of targeted testing on new features you release
> - **Unlimited async Slack/email questions** during the month
> - **One quarterly deeper review** (similar to this engagement)
> - **Quick turnaround on urgent questions** (within 24 hours business hours)
>
> Rate: $[X]/month, month-to-month with 30-day notice.
>
> The value for you is preventing issues before they ship rather than finding them after. The value for me is predictable, so I can prioritize your urgent asks.
>
> Worth exploring? Happy to do a free month first if that helps evaluate fit.
>
> [Your Name]

---

## Template 5: Red flags / passing on the job

Some jobs you should NOT bid on. Reply politely decline-or-redirect:

**Red flags:**
- Budget <$200 for "full pentest"
- "I need this done in 24 hours"
- Vague scope ("test my whole business")
- No willingness to sign a SOW
- Asks to test something they don't appear to own (e.g., "a competitor's site")

**Polite decline:**

> Hi,
>
> Thanks for the post. Based on the scope described, I don't think I'd be the right fit — a proper assessment of [what they're asking] typically requires [more time / broader access / signed authorization] than what's described in the post. I'd rather decline than under-deliver.
>
> If you'd like to revisit with a revised scope, happy to take another look. Best of luck finding a great match.
>
> [Your Name]

---

## Proposal send-time optimization

- Monday 9–11am buyer-local time has highest response rates
- Avoid Friday afternoon / weekend (even if the job just posted — hold until Monday)
- If the post is <2 hours old, send within 30 minutes; older posts have already been evaluated by buyers
