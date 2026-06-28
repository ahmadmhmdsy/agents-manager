'use strict';

// Each rule: { name, check(text, findings) }
// findings.push({ rule, line, col, message })

const rules = [
  {
    name: 'no-trailing-h1',
    check(text, findings) {
      const lines = text.split('\n');
      const last = lines[lines.length - 1];
      if (last && /^# \S/.test(last)) {
        findings.push({
          rule: 'no-trailing-h1',
          line: lines.length,
          col: 1,
          message: 'H1 must not be the last line; add body or remove it.',
        });
      }
    },
  },
];

module.exports = rules;
