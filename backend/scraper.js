// scraper.js
// Pure scraping logic: launches Puppeteer, reads the ISX market table,
// and returns [{ name, price }]. Knows nothing about where the data
// gets saved — buildData.js handles that part.
//
// NOTE ON SELECTORS: update SELECTORS.* below to match the real ISX page
// markup. Open the live page in a browser, inspect the market-watch
// table, and adjust rowSelector / nameSelector / priceSelector. If the
// data loads inside an iframe, you'll need `page.frames().find(...)`
// instead of querying `page` directly (there's a commented example below).

const puppeteer = require('puppeteer');

const ISX_URL = process.env.ISX_URL || 'https://www.isx-iq.net/isxportal/portal/homepage.html';

const REAL_USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ' +
  '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

const SELECTORS = {
  rowSelector: 'table#marketWatchTable tbody tr', // one row per stock
  nameSelector: 'td:nth-child(2)',                // company name/symbol column
  priceSelector: 'td:nth-child(5)',                // last traded price column
};

async function scrapeOnce() {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();
    await page.setUserAgent(REAL_USER_AGENT);
    await page.setViewport({ width: 1366, height: 768 });

    await page.goto(ISX_URL, { waitUntil: 'networkidle2', timeout: 45000 });

    // If the table lives inside an iframe instead of the top-level page,
    // swap the two lines below for something like:
    //   const frame = page.frames().find((f) => f.url().includes('marketwatch'));
    //   await frame.waitForSelector(SELECTORS.rowSelector, { timeout: 20000 });
    //   const rows = await frame.$$eval(...)
    await page.waitForSelector(SELECTORS.rowSelector, { timeout: 20000 });

    const rows = await page.$$eval(
      SELECTORS.rowSelector,
      (trs, sel) => {
        return trs
          .map((tr) => {
            const nameEl = tr.querySelector(sel.nameSelector);
            const priceEl = tr.querySelector(sel.priceSelector);
            if (!nameEl || !priceEl) return null;
            const name = nameEl.textContent.trim();
            const priceText = priceEl.textContent.trim().replace(/,/g, '');
            const price = parseFloat(priceText);
            if (!name || Number.isNaN(price)) return null;
            return { name, price };
          })
          .filter(Boolean);
      },
      SELECTORS
    );

    if (rows.length === 0) {
      throw new Error('No rows parsed - selectors may be stale or page blocked us.');
    }

    return rows;
  } finally {
    await browser.close();
  }
}

module.exports = { scrapeOnce };
