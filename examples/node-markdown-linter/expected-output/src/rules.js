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
  {
    name: 'no-consecutive-h1',
    check(text, findings) {
      const lines = text.split('\n');
      lines.forEach((line, i) => {
        if (i > 0 && /^# \S/.test(line) && /^# \S/.test(lines[i - 1])) {
          findings.push({
            rule: 'no-consecutive-h1',
            line: i + 1,
            col: 1,
            message: 'H1 must not directly follow another H1; add body or remove one.',
          });
        }
      });
    },
  },
];

module.exports = rules;
