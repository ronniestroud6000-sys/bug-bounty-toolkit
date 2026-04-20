# 01 — Start Here

Welcome. If you're new to bug bounties and security auditing, read this front-to-back. It's the fastest path from "I installed some tools" to "I got paid for finding a bug."

## What is a bug bounty?

A **bug bounty program** is a company publicly saying: "If you find a security flaw in our systems and report it responsibly, we'll pay you." Programs are hosted on platforms like:

- **[HackerOne](https://hackerone.com)** — largest, most programs (Uber, Shopify, GitHub, DoD, etc.)
- **[Bugcrowd](https://bugcrowd.com)** — #2 platform
- **[Intigriti](https://intigriti.com)** — strong EU presence
- **[YesWeHack](https://yeswehack.com)** — EU-focused
- **[Synack](https://synack.com)** — invite-only, pays well, higher bar

Each program has a **scope page** listing:
- Which domains/apps you're allowed to test (in scope)
- What kinds of bugs they pay for (SQL injection, XSS, auth bypass, etc.)
- What's excluded (DoS, social engineering, physical attacks, usually)
- Payout ranges per severity

**Read the scope page carefully every single time.** Testing out-of-scope systems can get you banned from the platform, or worse.

## What does a bug bounty pay?

Typical ranges (HackerOne 2024-ish data):
- **Low:** $50–$250 — things like missing security headers, self-XSS, mild info disclosure
- **Medium:** $250–$2,000 — reflected XSS, CSRF with impact, IDOR with limited data
- **High:** $2,000–$10,000 — stored XSS, SQL injection, SSRF to internal systems, auth bypass
- **Critical:** $10,000–$100,000+ — RCE, full account takeover, mass data exposure

Expectations for someone starting out: your first few bounties will be in the $100–$500 range. You're competing with people who have years of experience, so the quick wins go fast. Focus on:
- Newly launched programs (less saturated)
- Programs with wide scope (more attack surface)
- Programs with a lot of subdomains (use this toolkit's recon pipeline)

## What is a security audit engagement (freelance)?

Different from bug bounty: a **client pays you a fixed fee** to audit *their* systems and deliver a report. Common engagement types:

- **Web app pentest:** $3,000–$15,000 (1-3 weeks) — test a single web application
- **Infrastructure audit:** $5,000–$30,000 (2-4 weeks) — network/cloud pentest
- **Code review:** $2,000–$10,000 (1-2 weeks) — review source for vulnerabilities (Semgrep helps a lot)
- **Retest:** $500–$2,000 — verify prior findings are fixed

**Upwork opportunity:** Most Upwork buyers aren't sophisticated security buyers. They want a professional-looking report showing issues and fixes. Deliver that consistently and you'll have repeat clients.

See `06-upwork-guide.md` for the full playbook.

## How the bug bounty workflow goes

```
1. Pick a program         → Read scope, understand tech
2. Recon                  → Find every asset in scope (this toolkit!)
3. Triage / prioritize    → Which hosts are interesting?
4. Manual testing         → Actually hunt for bugs
5. Exploit / validate     → Prove impact, screenshot everything
6. Write report           → Clear, reproducible, impact-focused
7. Submit, wait, fix back-and-forth
8. Get paid               → $$$
```

Most first-timers under-invest in steps 1 and 6.
- **Step 1 (scope reading):** saves you from out-of-scope reports and duplicates.
- **Step 6 (reporting):** your report IS your product. A great finding in a bad report gets "not applicable" or underpaid.

## Your first 30 days: a realistic plan

### Days 1–3: Learn the foundation

- **[PortSwigger Web Security Academy](https://portswigger.net/web-security)** — free, excellent. Do the **Apprentice** tier for all labs in these categories: SQL injection, XSS, Authentication, Access control, SSRF.
- **[Hacker101](https://www.hacker101.com/)** — HackerOne's free training with CTF labs.

### Days 4–7: Pick your first program

Criteria:
- **Wide scope** (e.g., `*.target.com`) — more to find
- **Recently launched** (check HackerOne's "newly launched" filter)
- **Good response rating** (≥90% on HackerOne)
- **Pays reasonably** (minimum bounty ≥$100)

Good practice targets:
- **[Public HackerOne programs](https://hackerone.com/directory/programs?type=team&order_direction=DESC&order_field=resolved_report_count)** with "wide scope" tag
- **[Bug bounty village labs](https://www.bugcrowd.com/resources/levelup/)** for safe practice

### Days 8–14: Run recon on one program

```bash
./recon/full-recon.sh yourtarget.com
```

Spend time reading the `report.md`. Look for:
- Admin panels (anything with `/admin`, `/dashboard`, `/staff`, `/portal`)
- Staging/dev subdomains (`dev.`, `staging.`, `test.`, `uat.`)
- API subdomains (`api.`, `graphql.`, `mobile-api.`)
- Unusual tech stacks in the `tech` column

### Days 15–21: Manual testing

Pick 3–5 interesting hosts and manually test them. See `04-bug-classes.md` for what to try. Spend at least 4 hours per host.

### Days 22–30: Your first report

Even if you don't find a bounty-worthy bug, write up a **detailed recon report** of the attack surface you mapped. Practice writing professionally — this muscle is what makes the next bug pay.

If you found something: use `../templates/vulnerability-report.md`.

## How to learn fast (meta)

1. **Read disclosed reports.** [HackerOne Hacktivity](https://hackerone.com/hacktivity) shows you real bug reports. Read 5+ per day.
2. **Follow these people on Twitter/X:** @NahamSec, @STÖK, @InsiderPhD, @Jhaddix, @LiveOverflow (YouTube too). They share daily learnings.
3. **Do PortSwigger Academy daily** until you finish Apprentice + Practitioner tiers.
4. **Always write up your findings,** even for practice targets. The skill of explaining is what pays.

## Don't skip this: ethics & legal

**Unauthorized testing is illegal.** Before touching any system:

✅ **Safe:** Public bug bounty programs where you've read the scope and you're within it.
✅ **Safe:** A client has signed a Statement of Work with testing authorization.
✅ **Safe:** Your own systems, or labs you control (HackTheBox, TryHackMe, PortSwigger labs).

❌ **Not safe:** Anything else. Even "small" tests against unauthorized systems.

See `07-ethics-and-legal.md` for detail. This isn't optional paranoia — it's career-ending mistakes.

## Ready?

Next: [`02-methodology.md`](02-methodology.md) — the recon methodology framework.
