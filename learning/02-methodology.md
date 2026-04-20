# 02 — Recon Methodology

Recon is 80% of the game. Most people who "can't find bugs" haven't actually mapped the attack surface. This guide is the framework.

## The three phases

```
PASSIVE ────→ ACTIVE ────→ AUTHENTICATED
(quiet,        (probing     (logged-in as
 off-target)   the target)  a user)
```

Stay in passive mode as long as you can. Information gathered passively doesn't alert defenders or generate suspicious traffic.

## Phase 1: Passive recon

You're not touching the target yet. You're mining public sources.

### Subdomain enumeration (passive)

`subfinder` (in this toolkit) hits 30+ sources:
- Certificate transparency logs (crt.sh, Censys)
- DNS aggregators (VirusTotal, SecurityTrails, HackerTarget)
- Search engines, paste sites, Shodan

```bash
subfinder -d target.com -silent -all > subdomains.txt
```

### Certificate transparency

Certificates issued for a domain go into public CT logs. Query them:

```bash
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sort -u
```

### Git repositories, dorks, historical data

- **GitHub/GitLab dorks:** `"target.com" password`, `"target.com" api_key`, etc. — often leaks secrets developers commit accidentally.
- **Wayback Machine:** `curl -s "http://web.archive.org/cdx/search/cdx?url=*.target.com/*&output=text&fl=original&collapse=urlkey" > wayback.txt` — shows URLs that existed historically.
- **Shodan:** `hostname:target.com` — exposed services, often with versions.

### Public code / tech fingerprints

- Job postings → "Experience with React, AWS, MongoDB required" tells you the stack.
- LinkedIn eng team → tech blog posts, tools they talk about.
- Browser DevTools on the main site → bundles reveal routes, internal API paths.

## Phase 2: Active recon

You're probing the target directly — but still gathering info, not yet exploiting.

### Live host detection

```bash
cat subdomains.txt | httpx -silent -status-code -title -tech-detect -ip > live.jsonl
```

Gives you: which subdomains are alive, what tech runs on each, what the homepage says.

### Port scanning

```bash
cat live-hosts.txt | naabu -top-ports 1000 -silent
```

Web apps aren't the only target. Look for:
- Non-standard HTTP ports (8080, 8443, 9000) — often admin panels
- SSH (22), FTP (21), RDP (3389) — sometimes exposed admin
- Databases exposed (3306 MySQL, 5432 Postgres, 27017 MongoDB, 6379 Redis)

### Content discovery

For each live host, what paths exist?

```bash
# Using this toolkit's script:
./recon/content-discovery.sh https://target.com/

# Or manually:
ffuf -u https://target.com/FUZZ -w ~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/common.txt
```

**High-value paths to specifically look for:**
- `/admin`, `/administrator`, `/manager`, `/console`, `/dashboard`
- `/.git/config`, `/.env`, `/backup.sql`, `/wp-config.php.bak`
- `/api`, `/api/v1`, `/api/v2`, `/graphql`, `/swagger`, `/api-docs`
- `/.well-known/security.txt` — sometimes lists security contact + scope
- `/robots.txt`, `/sitemap.xml` — hand-curated listing of paths

### Crawling

```bash
katana -u https://target.com -d 3 -jc
```

`-jc` = JavaScript crawling — parses JS files to find API endpoints hardcoded in front-end code. This is **huge** for modern SPAs.

### JS file analysis

Modern webapps bundle everything into JS. Extract URLs, endpoints, and secrets from them:

```bash
# Get all JS files
katana -u https://target.com | grep '\.js$' > js-files.txt

# Pull URLs out
for url in $(cat js-files.txt); do
    curl -s "$url" | grep -oE 'https?://[a-zA-Z0-9./?=_&-]+' | sort -u
done
```

## Phase 3: Authenticated recon

You've made an account, you're logged in, now you map what you can see as a user.

### Start with Burp Suite Community / Caido

Install [Caido](https://caido.io) (free). Proxy all your browser traffic through it. Every request is captured. You'll find:

- Internal APIs
- Admin endpoints (if accidentally exposed)
- IDOR opportunities (sequential IDs in URLs: `/invoices/12345`)
- Authorization edges (what does the API accept from a user-role account?)

### Map the app as a user

Click every feature. Fill every form. Use every API. Watch the requests. Look for:

- User IDs in URLs → try another user's ID (IDOR)
- Role cookies / JWTs → decode them, look for `role: "user"`, try changing to `admin`
- Upload endpoints → test file type enforcement
- Password reset flows → can you reset another user's password?

### Repeat for every role

Many bugs live in role-transitions. If an app has `user`, `staff`, `admin` roles:
- Create one of each (or request test accounts from the program)
- Attempt staff-only actions as a user
- Attempt admin-only actions as staff
- Compare cookies/headers between roles

## Connecting this toolkit to the methodology

| Phase | Step | Tool in this toolkit |
|-------|------|--------------------|
| Passive | Subdomain enum | `recon/full-recon.sh` (step 1) |
| Passive | CT logs | Included in subfinder sources |
| Active | Live probing | `recon/full-recon.sh` (step 2) |
| Active | Port scan | `recon/full-recon.sh --deep` |
| Active | Crawling | `recon/full-recon.sh` (step 4) |
| Active | Content discovery | `recon/content-discovery.sh` |
| Active | Vuln scan | `recon/full-recon.sh` (step 5) |
| Auth'd | Manual testing | (you + Caido/Burp) |
| Auth'd | Code review | `semgrep` (SAST) — via MCP |

## Next

[`03-tool-cheatsheet.md`](03-tool-cheatsheet.md) — concrete commands for every tool.
