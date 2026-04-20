# 07 — Ethics & Legal

This page is short because the rules are simple. Read it once. Then read it again.

## The core rule

**Never test systems you are not explicitly authorized to test.**

That's it. Authorization is the only thing separating legal security research from felony computer crime.

---

## What counts as authorization?

### ✅ Yes: Bug Bounty Program

The program's scope page IS your authorization, as long as:
- You test only in-scope assets
- You follow the rules (rate limits, prohibited techniques, disclosure timeline)
- The program is explicitly active (not an expired page)

**Screenshot the scope page at the start of your engagement.** If the program scope changes, you want proof of what was in-scope when you tested.

### ✅ Yes: Signed Statement of Work

A SOW (or engagement letter) with a specific grant of authorization.

**Required language (work with a lawyer for production use):**
> Client hereby authorizes Contractor to conduct security testing against the systems listed in Section X ("Target Systems"). This authorization is limited to the activities described in Section Y ("Permitted Activities") and valid for the period from [start date] to [end date]. Contractor agrees to hold all findings confidential. Client indemnifies Contractor against any claims arising from testing conducted within the bounds of this authorization.

Template: `../templates/engagement-letter.md`

### ✅ Yes: Your own systems

Stuff you own or have a lease/license explicitly granting you admin access. Your personal website, your homelab, your own cloud accounts.

### ✅ Yes: Intentionally vulnerable labs

- [PortSwigger Web Security Academy](https://portswigger.net/web-security) labs
- [HackTheBox](https://www.hackthebox.com/), [TryHackMe](https://tryhackme.com/)
- [Hacker101 CTF](https://ctf.hacker101.com/)
- [DVWA](https://github.com/digininja/DVWA), [OWASP Juice Shop](https://github.com/juice-shop/juice-shop), [WebGoat](https://owasp.org/www-project-webgoat/)

### ❌ No: "I think they won't mind"

Even if:
- It's a friend's company
- You know the CEO
- You've reported bugs to them before
- The system "seems abandoned"
- "Anyone could find this"

**Not without written authorization.** Verbal "yeah go ahead" does not hold up in court.

### ❌ No: Indirect testing

You can't test a target by testing its customers. Example:
- Target: BigCompany.com (out of scope)
- You test: LittleStartup.com (uses BigCompany's API)
- Your test against LittleStartup's BigCompany integration → probably unauthorized testing of BigCompany

Stay inside the explicit boundary.

---

## Specific landmines

### Production vs. staging

Bug bounty programs and SOWs often restrict testing to staging/test environments. Before blasting `full-recon.sh` at `app.target.com`, check if they've provided a `staging.target.com` or equivalent.

### Production data

Touching actual user data (PII) when the scope hasn't explicitly authorized it is a problem under GDPR, CCPA, HIPAA, and others. If you find a way to read/modify real user data, **stop, document the finding, report, move on.** Don't enumerate or exfiltrate more than necessary to prove impact.

### DoS / performance impact

Most programs explicitly prohibit DoS testing, stress testing, resource exhaustion, auto-scaling triggers. Your recon scripts default to conservative rate limits for this reason.

### Third-party services

Target uses AWS, Cloudflare, Auth0, Stripe, etc. **Those third parties are NOT in scope** unless the program explicitly says so. You can:
- ✅ Report a finding where the target misconfigures a third-party (e.g., publicly readable S3 bucket)
- ❌ Test the third-party service itself for vulnerabilities

### Social engineering / physical

Unless explicitly in scope (rare), **don't** phone employees, don't send phishing, don't tailgate into the office. These escalate to federal charges fast.

---

## Jurisdictional basics

### United States
- **CFAA** (18 U.S.C. § 1030): exceeds "authorized access" → felony. 5–10 years for serious cases.
- **DMCA** (17 U.S.C. § 1201): circumventing tech protection measures. Has a security research exception added in 2015 that helps, but narrow.
- **State laws**: most states have their own equivalents.
- **DOJ 2022 policy shift**: "good faith security research" specifically carved out as not-for-prosecution. Helps, but doesn't eliminate civil liability.

### United Kingdom
- **Computer Misuse Act 1990**: unauthorized access criminal offense.

### European Union
- **Cybercrime Directive (2013/40/EU)**: each member state implements locally. Germany's "Hackertool Paragraph" (§ 202c StGB) is especially broad.
- **GDPR**: if you touch personal data without authorization, additional liability beyond CFAA-equivalent.

### What to do for cross-border testing
If the target is in a different country than you:
- Check their local laws before testing
- Keep your evidence of authorization
- Consider carrying professional liability insurance (~$500–$1,500/yr for $1M coverage)

---

## Responsible disclosure norms

### When you find a bug in a bug bounty program
Submit to the program. Follow their disclosure timeline. Typical: wait until fixed + 30 days before public disclosure unless they approve earlier.

### When you find a bug out-of-band (no bounty program)
Process:
1. **Find the security contact**: `security@target.com`, `/.well-known/security.txt`, [disclose.io](https://disclose.io/) listing
2. **Email them a **concise** report**: "Reproducible security issue on [domain]. Technical details available upon receipt of acknowledgment. Happy to work with your team on disclosure timeline."
3. **Give them 90 days** to fix before public disclosure (Google Project Zero's standard)
4. **Don't ask for a bounty.** They'll either have a program or not. Asking sets the wrong tone.

### When they ignore you
Don't go public aggressively. Step up gradually:
1. Re-email after 2 weeks
2. Try LinkedIn outreach to CISO / VP Eng
3. If 60+ days with no response: inform them you'll disclose in 30 days
4. After 90 days total: publish only if the vulnerability is not uniquely exploitable by you (don't publish 0-day exploits that only you can trigger — that can revert to criminal liability)

### When testing reveals a crime
If you find evidence of active data breaches, CSAM, or other serious crimes during authorized testing:
- **Stop** immediately
- **Document** with timestamps
- **Report to law enforcement** (FBI IC3 in the US, NCA in the UK)
- **Inform the client** (if under SOW)

---

## Personal protection

### Document your authorization

Keep a folder per engagement:
- Signed SOW (PDF with timestamp)
- Screenshot of program scope page (date in the URL bar)
- Email authorizing testing (if applicable)

Keep this for 7 years minimum (statute of limitations).

### Use a dedicated IP / VPN

- Test from an IP range your client has allowlisted
- For bug bounty: note your source IP in the report — the program can verify testing happened from that IP

### Insurance

Professional liability insurance (E&O / tech errors and omissions) covers: client claims that your testing caused damage, legal defense costs, etc.

- **Hiscox, Next Insurance** offer tech E&O starting ~$500/yr
- Typical coverage: $1M per occurrence

Get this before you do >$50K/yr in security consulting.

### Company structure

Once you're consistently earning from security work, form an LLC or equivalent. It:
- Separates personal assets from business liability
- Makes it easier to contract with larger clients
- Gives you business insurance access at better rates

---

## One more time

**The only thing protecting you is authorization.**

Keep it in writing. Read the scope every time. When in doubt, ask first.

---

## Next

You've read all the learning content. Now:

- Run your first scan: `./recon/full-recon.sh <an-authorized-target>`
- Write your first practice report: use `../templates/vulnerability-report.md`
- Set up your Upwork profile: use `06-upwork-guide.md`
- Install the Claude Code agent: `cp ../agents/bug-bounty-hunter.md ~/.claude/agents/`

Good hunting.
