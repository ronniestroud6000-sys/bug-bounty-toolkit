# 04 — Common Bug Classes

For each class: **what it is**, **how to find it**, **typical bounty**, **proof-of-concept template**.

This is a field guide, not a textbook. For deep theory, do [PortSwigger Academy](https://portswigger.net/web-security).

---

## 1. IDOR (Insecure Direct Object Reference) / BOLA

**The bug:** The app uses a user-supplied ID to look up data, but doesn't verify the logged-in user is authorized to access *that* ID.

**Example:** `GET /api/invoices/12345` returns your invoice. Try `GET /api/invoices/12346`. If you get someone else's invoice, IDOR.

**How to find it:**
- Proxy traffic through Caido/Burp
- Note every URL with a numeric or UUID ID (`/users/42`, `/orders/abc123`)
- Try: incrementing/decrementing numeric IDs, using another account's IDs, negative numbers, very large numbers
- Check all HTTP methods: GET, PUT, PATCH, DELETE — sometimes GET is protected but DELETE isn't

**Typical bounty:** $500–$5,000 depending on what data is exposed

**PoC template:**
```
1. Create two accounts: AccountA, AccountB
2. As AccountA, view your profile: GET /api/users/111 → returns AccountA data
3. As AccountA, access AccountB's data: GET /api/users/222 → returns AccountB data (IMPACT)
4. Impact: any user can read/modify any other user's profile, invoices, etc.
```

---

## 2. SQL Injection (SQLi)

**The bug:** User input is concatenated into a SQL query. Attacker injects SQL syntax to read/modify the database.

**How to find it:**
- Put a single quote `'` in any parameter. Error? Possible SQLi.
- Try payloads from PayloadsAllTheThings/SQL Injection
- Automated: `nuclei -tags sqli`, `sqlmap -u "https://target.com/page?id=1"`
- **Blind SQLi** (no error shown): time-based payloads like `' OR SLEEP(5)--`

**Typical bounty:** $2,000–$20,000 — always high-impact

**PoC template:**
```
Endpoint: GET /api/search?query=TEST
Payload: ' UNION SELECT version(),NULL,NULL--
Result: Response body contains "PostgreSQL 14.5..."
Impact: Attacker can read entire database, possibly achieve RCE via functions like COPY ... TO PROGRAM
```

---

## 3. Cross-Site Scripting (XSS)

**The bug:** User input is reflected into HTML/JS without proper escaping. Attacker injects JS that runs in other users' browsers.

**Three flavors:**
- **Reflected:** payload in URL, victim clicks a crafted link
- **Stored:** payload saved in DB, runs for anyone who views that page
- **DOM-based:** front-end JS unsafely handles user input (often `innerHTML`, `document.write`)

**How to find it:**
- Put `"><script>alert(1)</script>` in every input field
- Try `javascript:alert(1)` in URL fields
- Check every place user input is shown back (comments, profiles, search queries)
- Use the **PortSwigger XSS cheat sheet:** https://portswigger.net/web-security/cross-site-scripting/cheat-sheet

**Typical bounty:** Reflected $250–$1,500; Stored $500–$10,000

**PoC template:**
```
1. Submit comment with body: <img src=x onerror=alert(document.domain)>
2. Any user viewing the comment triggers the JS
3. Impact: attacker can steal session cookies, perform actions as victim
4. Escalated PoC:
   fetch('/api/account', {method:'POST', body:JSON.stringify({password:'pwned'})})
   → full account takeover
```

---

## 4. Server-Side Request Forgery (SSRF)

**The bug:** App takes a URL from the user and makes a request to it. Attacker provides an *internal* URL, pivoting through the server.

**Classic targets:** `?url=`, `?image=`, webhook endpoints, PDF generators, "import from URL" features.

**How to find it:**
- Find a feature that fetches a URL
- Replace with: `http://169.254.169.254/latest/meta-data/` (AWS metadata)
- Or: `http://localhost:8080/`, `http://127.0.0.1:3306/`, `http://[::1]/`
- Or: your own Burp Collaborator / Interactsh endpoint to confirm outgoing request

**Typical bounty:** $1,000–$15,000 (higher if you reach AWS metadata → cloud credentials)

**PoC template:**
```
Endpoint: POST /api/import-image {"url": "..."}
Payload: {"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}
Response: IAM role name
Follow-up: http://169.254.169.254/latest/meta-data/iam/security-credentials/<role>
Response: AccessKeyId + SecretAccessKey + Token (cloud compromise)
```

---

## 5. Auth / Authorization bugs

A whole family:

- **Weak password reset:** predictable tokens, token reuse, no expiration, no rate limit → bruteforce reset codes
- **JWT vulnerabilities:** `alg: none` accepted, weak secret, algorithm confusion (RS256 → HS256)
- **Session fixation:** session ID doesn't rotate on login
- **2FA bypass:** response-manipulation, race condition, or the 2FA endpoint doesn't actually enforce
- **OAuth misconfig:** `redirect_uri` not strictly validated → token theft

**Where to find:** login, signup, password reset, profile edit, 2FA enrollment.

**Typical bounty:** $1,000–$25,000

**Tool:** [jwt_tool](https://github.com/ticarpi/jwt_tool) for JWT analysis.

---

## 6. CSRF (Cross-Site Request Forgery)

**The bug:** App accepts authenticated actions via simple forms from cross-origin pages.

**How to find it:**
- Find a state-changing action (password change, email change, money transfer)
- Check: is there a CSRF token? Is it validated? Does it rotate?
- Check: is `SameSite=Strict` on the session cookie?
- Check: does changing the request method (POST → GET) work?

**Typical bounty:** $500–$5,000 — higher if it affects billing or critical actions

**Modern caveat:** Most browsers now default to `SameSite=Lax`, so classic CSRF is harder. Focus on:
- Login CSRF (log victim into attacker's account to capture their searches)
- CSRF on endpoints that accept JSON without preflight
- Subdomain CSRF (if cookies aren't scoped to subdomain)

---

## 7. XML External Entity (XXE)

**The bug:** App parses XML with external entities enabled. Attacker reads files / performs SSRF.

**How to find it:** Anywhere the app accepts XML (SOAP APIs, SAML, RSS import, SVG upload, DOCX upload).

**PoC:**
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<foo>&xxe;</foo>
```

**Typical bounty:** $2,000–$10,000

---

## 8. Subdomain Takeover

**The bug:** A CNAME points to a cloud service (Heroku, S3, Azure, Shopify) that no longer exists. Attacker claims the service with their account → serves content from the victim's subdomain.

**How to find it:**
```bash
cat subdomains.txt | nuclei -t ~/Desktop/bug-bounty/nuclei-templates/http/takeovers/
```

**Typical bounty:** $500–$5,000 (high impact because cookies leak to the attacker's controlled subdomain)

---

## 9. Sensitive data exposure

**The bug:** The server is leaking files / info it shouldn't.

**Where to look:**
- `/.git/config` — entire git history often downloadable
- `/.env`, `/.env.prod` — credentials
- `/backup.sql`, `/db.sqlite`, `/*.bak`
- `/server-status` (Apache), `/manager/html` (Tomcat)
- `/api/debug`, `/api/metrics` — sometimes leak internal info
- `/.DS_Store` on macOS-hosted servers — lists directory contents

**Automated:**
```bash
cat live.txt | nuclei -t ~/Desktop/bug-bounty/nuclei-templates/http/exposures/
```

**Typical bounty:** $250–$5,000 (depends on what's leaked)

---

## 10. Race conditions

**The bug:** Two operations that shouldn't happen simultaneously happen because the app doesn't lock. Example: redeem a one-time coupon twice in parallel.

**How to find:** Any "once per user" action. Use Burp's Turbo Intruder or ffuf to send 20+ requests in 50ms window.

**Typical bounty:** $500–$15,000 (great for monetary features)

---

## 11. Business logic flaws

**The bug:** The app works "as designed" but the design is exploitable. Examples:
- Negative quantity in cart → receive money when "paying"
- Step skipping in checkout → buy item without paying
- Type confusion: `{"amount": "0"}` vs `{"amount": 0}` behaves differently
- Concurrent operations that shouldn't be concurrent

**How to find:** Read the app carefully. Think: "What would break the business model?"

**Typical bounty:** Highly variable, often the highest ($5,000–$50,000+ when they affect money directly)

---

## Quick decision tree: "where do I start?"

```
Found this in recon?           → Try this first:

Admin panel                    → Default creds, weak 2FA, auth bypass
Exposed .git or .env           → Download, check for secrets
API with numeric IDs           → IDOR
Login/signup page              → Password reset flow, JWT analysis
File upload                    → XXE (if XML), SSRF via SVG, path traversal
URL-fetching feature           → SSRF → AWS metadata → cloud takeover
Search functionality           → SQLi, then XSS on results page
E-commerce checkout            → Race conditions, business logic
JWT in cookies                 → alg:none, weak secret, RS/HS confusion
Webhook / OAuth callback       → SSRF, open redirect, token theft
```

---

## Next

[`05-writing-reports.md`](05-writing-reports.md) — you found a bug. Now write it up so it pays.
