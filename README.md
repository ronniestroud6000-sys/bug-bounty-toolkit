# Bug Bounty Toolkit

A complete, opinionated toolkit for running bug bounty programs and selling security audits as a freelancer. Designed for **learners who want to go pro fast**.

## What's in here

```
bug-bounty-toolkit/
├── setup.sh                  # One command to install all the tools
├── recon/                    # Automated recon pipelines
│   ├── full-recon.sh         # Manual deep scan on a single target
│   ├── quick-recon.sh        # Fast recon variant
│   ├── content-discovery.sh  # ffuf wrapper for URL fuzzing
│   ├── daily-recon.sh        # ★ Diff-aware daily monitor (scheduled)
│   └── triage.sh             # ★ Local jq filters — $0 tokens
├── scheduling/               # ★ launchd job for automatic daily runs
├── templates/                # Client-ready deliverable templates
├── learning/                 # Progressive learning path (start here)
├── agents/                   # Claude Code agent for bug bounty work
├── programs.example.txt      # ★ Copy to programs.txt, add your targets
└── docs/                     # Methodology notes & cheat sheets
```

## 60-second quick start

```bash
# 1. Install all the tools (idempotent — safe to re-run)
./setup.sh

# 2. Run recon against a target
./recon/full-recon.sh example.com

# 3. Review findings
open output/example.com/report.md
```

## Daily autopilot (token-frugal)

Want fresh attack surface delivered to you every morning? Set up the scheduler:

```bash
# 1. Create your target list (authorized programs ONLY)
cp programs.example.txt programs.txt
$EDITOR programs.txt

# 2. Install the daily launchd job (fires at 06:00 local time)
./scheduling/install-schedule.sh

# 3. Every morning, check what's new
./recon/triage.sh today        # Full daily summary
./recon/triage.sh high         # Only high/critical findings
./recon/triage.sh interesting  # Admin panels, staging, APIs
```

**Cost model:** Scans are pure bash + CLIs, so they cost **$0 tokens**. Claude only gets involved when YOU decide a finding is worth deeper analysis. See [`scheduling/README.md`](scheduling/README.md) for the full architecture.

## Who this is for

- **Aspiring bug bounty hunters** — you want to find real vulnerabilities and get paid
- **Freelance security auditors** — you want to sell services on Upwork / to direct clients
- **Developers** — you want to audit your own apps before they ship

If you have zero security experience, **[start with `learning/01-START-HERE.md`](learning/01-START-HERE.md)**. It will get you producing findings within a week.

## What this toolkit includes

### 🔍 Recon automation
Battle-tested pipelines built on [ProjectDiscovery](https://projectdiscovery.io) tools:
- **Passive + active subdomain enumeration**
- **Live host detection & tech fingerprinting**
- **Content discovery & crawling**
- **CVE & misconfiguration scanning**
- **Auto-triaged markdown reports**

### 📄 Client-ready templates
Everything you need to sell security work:
- Upwork proposal templates (high-conversion)
- Scope of Work / Engagement Letter (legally sound starting points — have a lawyer review for production)
- Professional audit report template (the deliverable clients pay for)
- HackerOne / Bugcrowd vulnerability report template
- Retest report template

### 📚 Learning path
Seven progressive guides:
1. Start Here — what bug bounties are, how they pay
2. Recon Methodology — the "passive → active → authenticated" framework
3. Tool Cheat Sheet — one-pager for every installed CLI
4. Bug Classes — XSS, SQLi, SSRF, IDOR, auth bypass, etc. with real examples
5. Writing Reports — how to write findings that pay / don't get duped
6. Upwork Guide — positioning, pricing, proposal writing, getting your first client
7. Ethics & Legal — scope, authorization, when NOT to test

### 🤖 Custom Claude Code agent
A `@bug-bounty-hunter` agent tuned for this workflow — recon orchestration, vuln triage, report drafting. Drop into `~/.claude/agents/` and invoke by name.

## Prerequisites

- macOS or Linux
- Homebrew (installer script will set this up if missing)
- Basic comfort with the terminal

No Python knowledge required. No "hacker" background required. Just willingness to read and practice.

## Safety & ethics

**Only test systems you are authorized to test.** This toolkit is designed for:
- Bug bounty programs where you have explicit program scope
- Clients who have signed a Statement of Work granting authorization
- Your own systems

Unauthorized testing is illegal (CFAA in the US, Computer Misuse Act in the UK, equivalents worldwide). See [`learning/07-ethics-and-legal.md`](learning/07-ethics-and-legal.md) for the rules of engagement.

## License

MIT — use this however you want, including for commercial work. No warranty.

## Credits

Built on top of open-source giants: [ProjectDiscovery](https://projectdiscovery.io) (nuclei, subfinder, httpx, katana, naabu), [Daniel Miessler's SecLists](https://github.com/danielmiessler/SecLists), [swisskyrepo's PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings), [HackTricks](https://github.com/HackTricks-wiki/hacktricks). These folks did the hard work — this toolkit just composes their tools into a workflow.
