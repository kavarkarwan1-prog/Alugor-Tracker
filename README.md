# Iraqi Borsa Tracker (free, no billing account required)

Read-only Iraqi Stock Exchange (ISX) price tracker. No Firebase, no
credit card, no billing account — the backend is a **scheduled GitHub
Actions workflow** that scrapes prices and commits static JSON files,
served free via **GitHub Pages**. The Flutter app polls that JSON every
60 seconds. No trading, no order placement — display only.

Start here: **[SETUP_GUIDE.md](./SETUP_GUIDE.md)**

## How it works

```
GitHub Actions (cron, every ~10 min)
  → runs backend/buildData.js (Puppeteer scrape)
  → writes docs/stocks.json, docs/meta.json
  → commits + pushes back to the repo

GitHub Pages (serves the docs/ folder for free)
  → https://yourname.github.io/yourrepo/stocks.json

Flutter app
  → polls that URL every 60s with plain HTTP GET
  → StreamBuilder-driven UI, same as if it were "real-time"
```

## Folders

- `backend/` — scraper + JSON writer (`buildData.js`, `scraper.js`,
  `updateConfig.js`)
- `.github/workflows/` — the two scheduled jobs (stocks, currency/metals)
- `docs/` — the static JSON files GitHub Pages serves (seeded with empty
  placeholders so the site works before the first scrape runs)
- `flutter_app/` — the app (stock list, details + chart, IQD→shares
  calculator, favorites, IQD↔USD converter, gold/silver/diamond prices)

## Trade-offs vs. the Firebase version

- Update cadence is roughly every 10 minutes (GitHub's practical cron
  minimum, and it can run a few minutes late), not a true 60-second
  push. The app still polls every 60s, so it always shows the latest
  committed data as soon as it's available.
- No live push — the app polls instead of subscribing to a stream, but
  it looks the same to the user.
- Zero cost, no card, no billing account, ever — GitHub Actions and
  Pages are free for public repos within generous usage limits.
