# Recon Scripts

Automated recon pipelines for bug bounty and security audit engagements.

## Scripts

| Script | When to use | Time |
|--------|-------------|------|
| `quick-recon.sh` | New program just opened, want signal fast | 2-5 min |
| `full-recon.sh` | Standard engagement / daily workflow | 10-20 min |
| `full-recon.sh … --deep` | Thorough audit, time isn't tight | 30-60 min |
| `content-discovery.sh` | Fuzz specific hosts for hidden paths | 1-10 min |

## Quick start

```bash
# Run full recon
./full-recon.sh example.com

# Output lands in ../output/example.com/report.md
```

## How the pipeline works

```
  subfinder  →  httpx  →  katana  →  nuclei  →  report.md
  (passive      (live    (crawl    (scan for
   subdomain    hosts +    deeper   known
   enum)       tech)      URLs)    vulns)
```

Each stage feeds the next. Output is saved at every step so you can resume or re-run specific stages.

## Output files

After a run, `output/<target>/` contains:

- **`subdomains.txt`** — every subdomain `subfinder` found (passive sources: Certspotter, Censys, Shodan, etc.)
- **`live.txt`** — subdomains that actually respond to HTTP(S)
- **`live.jsonl`** — same, but with status codes, page titles, detected tech, IPs
- **`crawl.txt`** — URLs discovered by `katana` crawling the live hosts
- **`ports.txt`** — (deep mode only) open ports per host
- **`nuclei.jsonl`** — raw nuclei findings as NDJSON
- **`report.md`** — ← **the file you actually read** — summarized findings, top issues, next steps

## Tuning

### Rate limiting

The scripts default to `--rate-limit 150` for httpx and nuclei. If you're hitting bug bounty programs with explicit rate limits in their scope:

```bash
# Edit full-recon.sh and change:
nuclei -rate-limit 50 -c 10  # gentler
```

### More templates

Want to scan for a specific CVE or tech?

```bash
nuclei -l output/target/live.txt -t ~/Desktop/bug-bounty/nuclei-templates/cves/2024/
nuclei -l output/target/live.txt -t ~/Desktop/bug-bounty/nuclei-templates/http/exposures/
```

### Different wordlists for content discovery

```bash
./content-discovery.sh https://api.target.com/ api       # API endpoints
./content-discovery.sh https://target.com/ big           # larger common wordlist
./content-discovery.sh https://target.com/ raft          # exhaustive
```

## Authorization workflow

Before hitting a target, `full-recon.sh` prompts for authorization confirmation and records the approved target to `output/.authorized-targets`. Don't bypass this — the prompt is a reminder to re-verify scope.

## Manual follow-up after automated recon

Automation finds the easy stuff. Real wins come from manual work on the interesting outputs:

1. **Admin panels / login pages** — test default creds, credential stuffing, auth bypass
2. **API endpoints** (from `katana` + `content-discovery.sh api`) — IDOR, BOLA, broken auth
3. **Exposed files** (`.git/`, `.env`, backups, `/.well-known/`) — dig in
4. **Third-party services in tech detection** — known CVEs, misconfiguration
5. **Wildcard/staging subdomains** — often less hardened than production

See `../learning/04-bug-classes.md` for common things to look for by tech stack.
