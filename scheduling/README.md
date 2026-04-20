# Scheduling

Run `daily-recon.sh` automatically every morning so fresh attack surface is waiting for you over coffee.

## Why launchd (and not cron or Claude)

| Option | Tokens/run | Survives sleep | Survives reboot | Best for |
|--------|-----------|---------------|-----------------|----------|
| **launchd** (this) | **$0** | ✅ | ✅ | Daily recon ← |
| cron | $0 | ⚠️ | ✅ | Linux servers |
| Claude `CronCreate` | 💰 | depends | depends | When Claude must be in the loop |

The daily scan is pure bash + CLIs. Claude is never involved. Tokens are only spent when **you** decide to review findings with Claude's help.

## Install

```bash
# 1. Create your programs.txt (list of authorized targets)
cp programs.example.txt programs.txt
$EDITOR programs.txt

# 2. Install the launchd job
./scheduling/install-schedule.sh

# 3. Do a test run immediately (optional)
./recon/daily-recon.sh
```

That's it. Every morning at 6:00 local time, the script runs, diffs yesterday's assets, and writes a summary.

## Check it's working

```bash
# Confirm job is loaded
launchctl list | grep daily-recon

# Trigger it NOW (don't wait until tomorrow)
launchctl start com.bugbountytoolkit.daily-recon

# Tail the log
tail -f output/daily-recon.launchd.log

# Review today's summary
./recon/triage.sh today
```

## Uninstall

```bash
./scheduling/uninstall-schedule.sh
```

## Change the schedule

Edit `scheduling/com.bugbountytoolkit.daily-recon.plist.template` — the `StartCalendarInterval` dict controls when it runs. Then re-run `install-schedule.sh`.

Common patterns:

```xml
<!-- Every day at 06:00 (default) -->
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key><integer>6</integer>
    <key>Minute</key><integer>0</integer>
</dict>

<!-- Every 6 hours -->
<key>StartInterval</key>
<integer>21600</integer>

<!-- Every weekday at 07:30 — array of dicts -->
<key>StartCalendarInterval</key>
<array>
    <dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>7</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>7</integer><key>Minute</key><integer>30</integer></dict>
    <!-- ... -->
</array>
```

## Environment variables you can set

Edit the plist template to add `EnvironmentVariables` entries:

- `HUNTS_REPO=/path/to/private/hunts/repo` — auto-commit findings to a private git repo
- `NOTIFY_MIN_SEVERITY=high` — only notify on high/critical
- `HTTPX_RATE=50` — be more polite (default 100)
- `NUCLEI_RATE=50` — same
- `FULL_SCAN=1` — re-scan existing assets (not just new ones)

## Troubleshooting

**"Nothing happened at 6am"**
- Mac was asleep. launchd will fire on next wake — check later in the day.
- Log: `tail ~/Library/Logs/launchd.log` (may require admin)
- Our log: `tail output/daily-recon.launchd.log`

**"Command not found: subfinder"**
- The plist sets PATH to include `/opt/homebrew/bin` — if your brew is elsewhere, edit the template.

**"No programs.txt"**
- Script exits cleanly with a warning. Create programs.txt before relying on the schedule.

**"Job won't load"**
- `launchctl load -w ~/Library/LaunchAgents/com.bugbountytoolkit.daily-recon.plist` (the `-w` overrides disabled state)
- Check for XML syntax errors: `plutil -lint ~/Library/LaunchAgents/com.bugbountytoolkit.daily-recon.plist`
