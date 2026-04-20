# Scheduling

Two-layer automation: free continuous monitoring + cheap surgical analysis.

## The two layers

```
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 1 — launchd at 06:00 (bash, $0 tokens)                   │
│  ─────────────────────────────────────────                      │
│  Runs: recon/daily-recon.sh                                     │
│  Does: subfinder → diff vs yesterday → httpx → nuclei (medium+) │
│  Writes: output/daily/YYYY-MM-DD/daily-summary.md               │
│  Notifies: macOS notification with raw counts                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 2 — scheduled-tasks MCP at 07:00 (Claude, ~1¢-20¢/day)   │
│  ─────────────────────────────────────────────────────────      │
│  Runs: Claude session with scheduling/claude-analysis-prompt.md │
│  Short-circuits if zero new subs AND zero findings (~1¢)        │
│  Otherwise: triages findings, verdicts FPs, writes analysis     │
│  Writes: output/daily/YYYY-MM-DD/claude-analysis.md             │
│  Notifies: richer "likely FP / manual dive" notification        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                      YOU review at 08:00
```

## Why this architecture

| Option | Tokens/run | Survives sleep | Survives reboot | Purpose |
|--------|-----------|---------------|-----------------|---------|
| **launchd** (Layer 1) | **$0** | ✅ | ✅ | Free continuous scanning |
| **scheduled-tasks MCP** (Layer 2) | **1¢–20¢** | depends | depends | Cheap conditional triage |
| cron | $0 | ⚠️ macOS-patchy | ✅ | Linux alternative to launchd |

The 6am bash layer is ALWAYS free. The 7am Claude layer short-circuits on boring days (~1¢ to read summary + respond "nothing new") and only spends real tokens when there's something worth analyzing.

## Install

### Layer 1 — launchd (bash scan at 6am)

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

### Layer 2 — Claude morning triage at 7am

The Claude triage task is registered via Claude Code's `scheduled-tasks` MCP and is specified in [`claude-analysis-prompt.md`](claude-analysis-prompt.md).

To register it (one-time, inside a Claude Code session):

1. Open a Claude Code chat
2. Ask Claude: `"Register the bug-bounty-morning-triage scheduled task using the prompt in scheduling/claude-analysis-prompt.md to run at 7am daily"`

Claude will create the task via the `mcp__scheduled-tasks__create_scheduled_task` tool. From then on, the task runs every morning at 7am and stores its analysis in `output/daily/YYYY-MM-DD/claude-analysis.md`.

To check it's scheduled: ask Claude to `"list scheduled tasks"`.
To remove it later: `"delete the bug-bounty-morning-triage scheduled task"`.

**You can skip Layer 2 entirely if you want pure-manual analysis** — just invoke Claude yourself when the 6am notification interests you. `triage.sh` has everything you need for zero-token filtering.

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
