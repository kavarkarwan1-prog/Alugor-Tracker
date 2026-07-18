// updateConfig.js
// Writes ../docs/config.json with IQD<->USD rate and gold/silver/diamond
// reference prices. Runs far less often than the stock scraper (e.g. a
// separate daily workflow, or manually) since these change slowly.
//
// Replace the MOCK_* values with a real FX-rate API and a metals-price
// API when you have one - both are free-tier friendly (e.g.
// exchangerate.host, metals-api.com) and need no server, just a fetch
// call from this script.

const fs = require('fs');
const path = require('path');

const CONFIG_FILE = path.join(__dirname, '..', 'docs', 'config.json');

const MOCK_USD_TO_IQD = 1310;
const MOCK_GOLD_PER_GRAM_USD = 82.5;
const MOCK_SILVER_PER_GRAM_USD = 0.98;
const MOCK_DIAMOND_PER_CARAT_USD = 4200;

function main() {
  const nowIso = new Date().toISOString();

  const config = {
    currency: {
      usdToIqd: MOCK_USD_TO_IQD,
      updatedAt: nowIso,
    },
    commodities: {
      goldPerGramUsd: MOCK_GOLD_PER_GRAM_USD,
      silverPerGramUsd: MOCK_SILVER_PER_GRAM_USD,
      diamondPerCaratUsd: MOCK_DIAMOND_PER_CARAT_USD,
      updatedAt: nowIso,
    },
  };

  fs.mkdirSync(path.dirname(CONFIG_FILE), { recursive: true });
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
  console.log(`Wrote ${CONFIG_FILE}`);
}

main();
