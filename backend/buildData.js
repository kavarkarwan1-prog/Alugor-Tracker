// buildData.js
// Runs once per GitHub Actions invocation (the workflow's cron schedule
// is what replaces the old "loop every 60s" behavior). It:
//   1. Scrapes the current prices (with a couple of in-run retries for
//      transient blocks - if this run fails, the NEXT scheduled run
//      acts as the real retry).
//   2. Merges them into ../docs/stocks.json, computing change vs. the
//      previously stored price and appending a capped price-history array.
//   3. Writes ../docs/meta.json with run status, for the app's
//      "last updated" indicator.
//
// This always exits 0 (even on scrape failure) so the workflow can still
// commit an updated meta.json showing the failure - useful for noticing
// when ISX has changed its page layout.

const fs = require('fs');
const path = require('path');
const { scrapeOnce } = require('./scraper');

const DOCS_DIR = path.join(__dirname, '..', 'docs');
const STOCKS_FILE = path.join(DOCS_DIR, 'stocks.json');
const META_FILE = path.join(DOCS_DIR, 'meta.json');

const MAX_HISTORY_POINTS = 50;
const IN_RUN_RETRIES = 2;
const RETRY_DELAY_MS = 10_000;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function symbolFromName(name) {
  return name
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 80);
}

function readJsonSafe(filePath, fallback) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return fallback;
  }
}

function writeJson(filePath, data) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

async function scrapeWithRetries() {
  let lastError;
  for (let attempt = 1; attempt <= IN_RUN_RETRIES; attempt++) {
    try {
      return await scrapeOnce();
    } catch (err) {
      lastError = err;
      console.error(`Attempt ${attempt} failed: ${err.message}`);
      if (attempt < IN_RUN_RETRIES) await sleep(RETRY_DELAY_MS);
    }
  }
  throw lastError;
}

async function main() {
  const nowIso = new Date().toISOString();
  const previous = readJsonSafe(STOCKS_FILE, { lastUpdated: null, stocks: [] });
  const previousBySymbol = new Map(previous.stocks.map((s) => [s.symbol, s]));

  let rows;
  try {
    rows = await scrapeWithRetries();
  } catch (err) {
    console.error('All attempts failed for this run:', err.message);
    const prevMeta = readJsonSafe(META_FILE, {});
    writeJson(META_FILE, {
      lastRunAt: prevMeta.lastRunAt || null,
      lastRunSuccess: false,
      stocksUpdated: 0,
      lastErrorAt: nowIso,
      lastError: err.message,
    });
    // Leave stocks.json untouched - the app keeps showing the last good data.
    return;
  }

  const mergedStocks = rows.map(({ name, price }) => {
    const symbol = symbolFromName(name);
    const prev = previousBySymbol.get(symbol);
    const previousPrice = prev ? prev.price : price;
    const change = price - previousPrice;
    const changePercent = previousPrice !== 0 ? (change / previousPrice) * 100 : 0;

    const history = prev?.history ? [...prev.history] : [];
    history.push({ price, timestamp: nowIso });
    while (history.length > MAX_HISTORY_POINTS) history.shift();

    return {
      symbol,
      name,
      price,
      previousPrice,
      change,
      changePercent,
      direction: change > 0 ? 'up' : change < 0 ? 'down' : 'flat',
      history,
    };
  });

  writeJson(STOCKS_FILE, {
    lastUpdated: nowIso,
    stocks: mergedStocks,
  });

  writeJson(META_FILE, {
    lastRunAt: nowIso,
    lastRunSuccess: true,
    stocksUpdated: mergedStocks.length,
    lastErrorAt: null,
    lastError: null,
  });

  console.log(`Wrote ${mergedStocks.length} stocks to ${STOCKS_FILE}`);
}

main();
