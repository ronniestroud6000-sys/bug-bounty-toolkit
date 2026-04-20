# Templates

Client-facing and submission-ready document templates. Fill in the brackets, delete the guidance notes, and deliver.

## When to use which

| Template | Use for |
|----------|--------|
| `vulnerability-report.md` | Submitting a single bug to HackerOne / Bugcrowd / Intigriti |
| `audit-report.md` | Delivering a completed security audit to a paying client |
| `retest-report.md` | Verifying prior findings were fixed |
| `upwork-proposal.md` | Bidding on Upwork security jobs |
| `scope-of-work.md` | Signing an engagement contract for >$3K work |
| `engagement-letter.md` | Lightweight authorization letter for <$3K work |

## Converting to PDF

Clients (especially on Upwork) expect polished PDFs. Convert markdown → PDF with pandoc:

```bash
# Install pandoc + a LaTeX engine (one-time)
brew install pandoc basictex

# Convert
pandoc audit-report.md -o audit-report.pdf \
    --pdf-engine=xelatex \
    --toc \
    -V geometry:margin=1in \
    -V fontsize=11pt \
    -V mainfont="Helvetica" \
    -V colorlinks \
    -V linkcolor=blue

# With a nice template (download a pandoc theme first):
pandoc audit-report.md -o audit-report.pdf \
    --template=eisvogel.latex \
    --listings
```

## Legal notice

The contracts (scope-of-work.md, engagement-letter.md) are **starting points, not legal advice**. Have a licensed attorney review them before using for real engagements above $5K or in regulated industries.
