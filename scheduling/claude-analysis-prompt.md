# Daily Claude Morning-Analysis Prompt

This is the prompt the scheduled-tasks MCP fires at 7:00 AM daily.
Kept as a separate file so we can version it and tune it over time
without touching the scheduled task itself.

---

# The prompt

You are doing my morning bug bounty triage. Be brief. Be decisive. Don't waste tokens.

## Step 1: Read today's summary (mandatory, first thing)

```
cat /Users/lunarlobster/Desktop/bug-bounty-toolkit/output/daily/$(date -u +%Y-%m-%d)/daily-summary.md
```

## Step 2: Short-circuit if nothing interesting

If the summary shows **zero new subdomains AND zero new findings**, do exactly this:

1. Write a one-line file: `echo "No new findings - $(date)" > /Users/lunarlobster/Desktop/bug-bounty-toolkit/output/daily/$(date -u +%Y-%m-%d)/claude-analysis.md`
2. Respond with literally: "No findings today. Analysis skipped to save tokens."
3. Stop. Do not use further tools. Do not analyze anything.

## Step 3: If there ARE new findings or subdomains

Produce a concise analysis in `output/daily/<today>/claude-analysis.md` with:

### For each HIGH/CRITICAL nuclei finding:
- **Likely verdict:** TRUE POSITIVE / FALSE POSITIVE / NEEDS MANUAL VERIFICATION
- **One-sentence rationale** (e.g., "GitHub takeover template — CNAME points to org-owned hacker0x01.github.io, not exploitable")
- **If worth pursuing:** Next manual step (e.g., `curl -H "Host: X" https://Y/...`)

### For new subdomains:
- Pick the 3-5 most interesting (admin-*, api-*, staging, dev, beta, demo, unusual tech)
- For each: one line on why it matters and what to probe first

### At the end of claude-analysis.md:
- A single-line summary for the notification (under 80 chars)

## Step 4: Send a richer macOS notification

Only send the notification if findings are non-trivial (exclude dedupe-able template FPs):

```bash
osascript -e "display notification \"<your one-line summary>\" with title \"Bug Bounty Triage\" sound name \"Glass\""
```

## Constraints

- **Do not run recon tools** (subfinder, httpx, nuclei, ffuf). That's yesterday's bash layer's job.
- **Do not read raw nuclei.jsonl files** unless the summary is insufficient. Trust the summary first.
- **Do not write long analyses for low-value findings.** One sentence per finding is the target.
- **If you find something high-value that needs deep investigation,** flag it in claude-analysis.md with "⚠️ MANUAL DEEP DIVE RECOMMENDED" — but don't do the deep dive automatically. I'll review and decide.
- **Budget:** aim for under 5000 tokens total on boring days, under 20000 on interesting ones.

## Self-check before exiting

- [ ] Did I read the summary file FIRST?
- [ ] Did I short-circuit if there was nothing new?
- [ ] Did I write claude-analysis.md (even if just the one-line "no findings")?
- [ ] Did I send a notification IF findings warranted one?
- [ ] Is my final response to the user under 10 lines?
