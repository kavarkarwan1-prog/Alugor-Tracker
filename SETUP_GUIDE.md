# Setup Guide — Iraqi Borsa Tracker (Free, No Billing Account)

## 1. Create the GitHub repo

1. Go to https://github.com/new
2. Name it anything, e.g. `isx-tracker`. **Public** repo (GitHub Pages is
   free for public repos; private repos need a paid plan for Pages).
3. Push this whole project folder to that repo:
   ```bash
   cd isx_tracker
   git init
   git add .
   git commit -m "initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/isx-tracker.git
   git push -u origin main
   ```

## 2. Enable GitHub Pages

1. In your repo on GitHub: **Settings → Pages**.
2. Under "Build and deployment", set **Source: Deploy from a branch**.
3. Branch: **main**, folder: **/docs**. Save.
4. GitHub will give you a URL like:
   ```
   https://YOUR_USERNAME.github.io/isx-tracker/
   ```
   It can take a minute or two to go live the first time.

## 3. Point the Flutter app at your Pages URL

Open `flutter_app/lib/main.dart` and replace:
```dart
const String kDataFeedBaseUrl = 'https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME';
```
with your actual Pages URL **without a trailing slash**, e.g.:
```dart
const String kDataFeedBaseUrl = 'https://yourname.github.io/isx-tracker';
```

## 4. Let the scraper run

The workflow at `.github/workflows/scrape.yml` is already scheduled to
run every ~10 minutes automatically once it's on GitHub. To test it
immediately instead of waiting:

1. Go to your repo's **Actions** tab.
2. Click **"Scrape ISX prices"** in the left sidebar.
3. Click **Run workflow** (this is the `workflow_dispatch` trigger) →
   **Run workflow** again to confirm.
4. Watch it run. If it succeeds, check `docs/stocks.json` in your repo —
   it should now have real data, and the workflow will have auto-committed
   that change.

Do the same for **"Update currency & commodity prices"** to seed
`docs/config.json` (or just wait — it's scheduled every 6 hours too).

### Before it works against the real ISX site

Open the ISX site in a real browser, inspect the market-watch table,
and update `SELECTORS.rowSelector`, `SELECTORS.nameSelector`, and
`SELECTORS.priceSelector` in `backend/scraper.js` to match the real
HTML. Public exchange sites often load data inside an iframe or via
JavaScript after the initial page load — there's a comment in
`scraper.js` showing how to switch to querying an iframe's `Frame`
object instead of the page directly if that's the case here.

If a run fails, check the **Actions** tab for the log, and check
`docs/meta.json` — it'll show `lastError` with what went wrong (most
commonly: stale selectors, or the site temporarily blocking automated
traffic).

## 5. Run the Flutter app

```bash
cd flutter_app
flutter pub get
flutter run
```

The app polls `stocks.json` and `config.json` every 60 seconds. On
first run before any scrape has completed, the list will show an empty
state message — that's expected until the first workflow run commits data.

## 6. Production checklist

- [ ] Confirm the repo is **public** (required for free GitHub Pages).
- [ ] Confirm `kDataFeedBaseUrl` in `main.dart` matches your real Pages
      URL exactly (no trailing slash, correct username/repo).
- [ ] Re-check the scraper's CSS selectors periodically — if ISX
      redesigns their site, `docs/meta.json`'s `lastError` field will
      start showing failures.
- [ ] Keep an eye on GitHub Actions' usage limits if this repo is ever
      made private — public repos get generous free minutes, private
      repos have a smaller free quota per month.
- [ ] Replace the mock values in `backend/updateConfig.js` with a real
      FX-rate API and a metals-price API if you want live currency/gold/
      silver numbers instead of manually-set placeholders.
- [ ] If you outgrow the ~10-minute cadence and later get access to a
      card/billing (or a free-tier VM elsewhere, like Oracle Cloud's
      always-free tier or a Raspberry Pi at home), you can drop back in
      the original always-on Node.js loop for true 60-second updates —
      the Flutter `DataService` just needs its `baseUrl` swapped for
      wherever that JSON ends up being hosted instead.

## Folder reference

```
isx_tracker/
├── .github/workflows/
│   ├── scrape.yml          # every ~10 min: scrape → commit docs/stocks.json
│   └── update-config.yml   # every 6h: refresh docs/config.json
├── backend/
│   ├── scraper.js          # pure Puppeteer scrape function
│   ├── buildData.js        # merges scrape results into docs/stocks.json
│   ├── updateConfig.js     # writes docs/config.json
│   └── package.json
├── docs/                   # served by GitHub Pages
│   ├── index.html
│   ├── stocks.json
│   ├── meta.json
│   └── config.json
└── flutter_app/
    ├── lib/
    │   ├── main.dart                     # set kDataFeedBaseUrl here
    │   ├── models/stock.dart
    │   ├── services/data_service.dart    # polls the JSON feed
    │   ├── services/favorites_service.dart
    │   ├── theme/app_theme.dart
    │   ├── widgets/stock_tile.dart
    │   ├── widgets/last_updated_bar.dart
    │   └── screens/
    │       ├── stock_list_screen.dart
    │       ├── stock_details_screen.dart
    │       ├── calculator_screen.dart
    │       ├── favorites_screen.dart
    │       ├── currency_converter_screen.dart
    │       └── commodities_screen.dart
    └── pubspec.yaml
```
