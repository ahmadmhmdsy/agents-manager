'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { lint } = require('../src/linter.js');

test('clean markdown produces no findings', () => {
  const text = '# Title\n\nA paragraph with body.\n';
  assert.deepEqual(lint(text), []);
});

test('H1 as last line is flagged', () => {
  const text = 'A paragraph.\n\n# Title';
  const findings = lint(text);
  assert.equal(findings.length, 1);
  assert.equal(findings[0].rule, 'no-trailing-h1');
});
