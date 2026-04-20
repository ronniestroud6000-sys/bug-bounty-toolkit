# 03 — Tool Cheatsheet

Every tool in this toolkit, with the commands you'll actually use. Bookmark this page.

---

## subfinder — subdomain enumeration

```bash
# Basic — passive sources, silent output
subfinder -d target.com -silent

# All sources (slower but more complete)
subfinder -d target.com -silent -all

# Multiple targets from a file
subfinder -dL targets.txt -silent -all -o subdomains.txt

# Specific source (skip flaky ones)
subfinder -d target.com -sources crtsh,certspotter,virustotal
```

**Tips:**
- Configure API keys at `~/.config/subfinder/provider-config.yaml` for better coverage (SecurityTrails, Censys, Shodan)
- Run periodically — new subdomains appear constantly as companies deploy new services

---

## httpx — HTTP probe & fingerprint

```bash
# Basic: filter alive hosts
cat subdomains.txt | httpx -silent

# Rich output: status, title, tech, IP
cat subdomains.txt | httpx -silent -status-code -title -tech-detect -ip

# JSONL for piping
cat subdomains.txt | httpx -silent -json -o live.jsonl

# Probe specific ports
cat subdomains.txt | httpx -silent -ports 80,443,8000,8080,8443,8888,9000

# Match specific tech (find all WordPress sites)
cat subdomains.txt | httpx -silent -tech-detect | grep -i wordpress
```

**Tips:**
- Always rate-limit on programs with strict scope rules: `-rate-limit 50`
- Follow redirects: `-follow-redirects`
- Screenshot live hosts: add `-screenshot` flag (slower but great for triage)

---

## katana — web crawler

```bash
# Basic crawl
katana -u https://target.com -silent

# Deeper (default depth is 2, push to 5)
katana -u https://target.com -d 5 -silent

# JavaScript crawling (parse JS bundles for endpoints — CRUCIAL for SPAs)
katana -u https://target.com -jc -silent

# Crawl many hosts from a file
katana -list live.txt -silent -o crawl.txt

# Form filling (auto-fill forms to reach more states)
katana -u https://target.com -aff -silent

# Filter only interesting URLs
katana -u https://target.com -silent | grep -E '\.(php|asp|jsp|js|json)$'
```

**Tips:**
- `-jc` is the killer feature — finds hardcoded API endpoints inside JS
- Pipe into nuclei: `katana -u target.com -silent | nuclei -silent`
- Use `-rl` (rate limit) on live programs: `-rl 50`

---

## nuclei — template-based vulnerability scanner

```bash
# Basic scan against one host
nuclei -u https://target.com

# Scan a list of hosts
nuclei -list live.txt

# Only high/critical (fastest, highest signal)
nuclei -list live.txt -severity high,critical

# Use specific template directories
nuclei -list live.txt -t ~/Desktop/bug-bounty/nuclei-templates/cves/2024/
nuclei -list live.txt -t ~/Desktop/bug-bounty/nuclei-templates/http/exposures/

# Scan for specific tech
nuclei -list live.txt -tags wordpress
nuclei -list live.txt -tags apache,nginx,iis

# Output formats
nuclei -list live.txt -jsonl -o findings.jsonl  # JSONL
nuclei -list live.txt -me report/               # Markdown export

# Update templates (do this weekly)
nuclei -update-templates
```

**Must-know template categories:**
- `cves/` — known CVEs by year
- `http/exposures/` — leaked files (.git/, .env, backups)
- `http/misconfiguration/` — insecure configs (CORS, directory listing)
- `http/takeovers/` — subdomain takeovers (massive category)
- `http/vulnerabilities/` — common vuln patterns (SQLi, XSS, LFI)

**Tips:**
- Rate-limit: `-rate-limit 50 -c 10` (50 req/s, 10 concurrency)
- Silent mode: `-silent` (cleaner output)
- To avoid duplicate findings across subdomains: dedupe input with `sort -u`

---

## naabu — port scanner

```bash
# Scan top 100 ports (fast)
echo "target.com" | naabu -silent

# Top 1000 ports
echo "target.com" | naabu -silent -top-ports 1000

# Full port range (slow)
echo "target.com" | naabu -silent -p -

# Scan specific hosts from a file
naabu -list hosts.txt -silent -top-ports 1000

# Pipe into httpx to find which ports serve HTTP
echo "target.com" | naabu -silent -top-ports 1000 | httpx -silent
```

**Tips:**
- Requires root on Linux for SYN scan (default on macOS is CONNECT which is fine)
- Rate: `-rate 1000` packets/sec (tune down for stealth)
- For bug bounty web-app programs, top 100 ports is usually enough

---

## ffuf — content discovery / fuzzing

```bash
# Directory fuzzing
ffuf -u https://target.com/FUZZ -w wordlist.txt

# Filter by status code
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200,301,302,403

# Filter out false positives (hide responses of a specific size)
ffuf -u https://target.com/FUZZ -w wordlist.txt -fs 4242

# Parameter fuzzing
ffuf -u "https://target.com/page?FUZZ=value" -w params.txt -fs 4242

# Virtual host fuzzing
ffuf -u https://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fs 4242

# POST body fuzzing
ffuf -u https://target.com/login -X POST -d "user=admin&pass=FUZZ" -w passwords.txt
```

**Common wordlists:**
```bash
# Paths (directories & files)
~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/common.txt            # ~4k entries, fast
~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/big.txt               # ~20k entries
~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/raft-large-directories.txt

# APIs
~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/api/api-endpoints.txt

# Parameters
~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/burp-parameter-names.txt

# Subdomains
~/Desktop/bug-bounty/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
```

---

## semgrep — SAST (source code scanning)

If a program has open-source code or you have code access:

```bash
# Auto-config (recommended rules for language detected)
semgrep --config=auto /path/to/code

# Security audit
semgrep --config=p/security-audit /path/to/code

# OWASP Top 10
semgrep --config=p/owasp-top-ten /path/to/code

# Specific language
semgrep --config=p/python /path/to/python-code
semgrep --config=p/javascript /path/to/js-code

# Output JSON for parsing
semgrep --config=auto /path/to/code --json > findings.json
```

**Via Claude Code MCP:** Your Claude Code setup has the Semgrep MCP installed. Just ask Claude: "Run semgrep against this repo and summarize high-severity findings."

---

## jq / gron — JSON wranglers

Every tool above outputs JSON. Learn these two:

```bash
# jq — transform JSON
cat nuclei.jsonl | jq '.info.severity' | sort | uniq -c    # count by severity
cat nuclei.jsonl | jq 'select(.info.severity == "critical")' # filter

# gron — make JSON greppable
cat live.jsonl | gron | grep -i "admin"
```

---

## Combo patterns (the real power)

### The "one-liner" recon pipeline

```bash
subfinder -d target.com -silent \
  | httpx -silent -status-code -title -tech-detect \
  | tee live.txt \
  | nuclei -silent -severity high,critical
```

### Find admin panels

```bash
cat live.txt | httpx -silent -path /admin,/administrator,/manager,/login,/console -mc 200,401,403
```

### Find exposed `.git` directories (high-impact finding)

```bash
cat live.txt | nuclei -silent -t ~/Desktop/bug-bounty/nuclei-templates/http/exposures/configs/git-config.yaml
```

### Find subdomain takeovers (easy wins)

```bash
cat subdomains.txt | nuclei -silent -t ~/Desktop/bug-bounty/nuclei-templates/http/takeovers/
```

### Find exposed S3 buckets

```bash
for sub in $(cat subdomains.txt); do
    bucket=$(echo "$sub" | cut -d. -f1)
    curl -s -o /dev/null -w "%{http_code} $bucket.s3.amazonaws.com\n" "https://$bucket.s3.amazonaws.com/"
done | grep -v "^403\|^404"
```

---

## Next

[`04-bug-classes.md`](04-bug-classes.md) — once you've found the attack surface, what are you looking for?
