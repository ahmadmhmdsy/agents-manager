'use strict';

const fs = require('node:fs');
const path = require('node:path');
const rules = require('./rules.js');

function lint(text) {
  const findings = [];
  for (const rule of rules) {
    rule.check(text, findings);
  }
  return findings;
}

if (require.main === module) {
  const file = process.argv[2];
  if (!file) {
    console.error('Usage: node src/linter.js <file>');
    process.exit(1);
  }
  const text = fs.readFileSync(path.resolve(file), 'utf8');
  const findings = lint(text);
  if (findings.length === 0) {
    console.log('OK');
    process.exit(0);
  }
  for (const f of findings) {
    console.log(`${f.line}:${f.col} [${f.rule}] ${f.message}`);
  }
  process.exit(1);
}

module.exports = { lint };
