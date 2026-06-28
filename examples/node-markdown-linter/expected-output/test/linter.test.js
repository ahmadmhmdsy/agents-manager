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

test('two consecutive H1 lines: second one flagged', () => {
  const text = '# First\n# Second\n';
  const findings = lint(text);
  assert.equal(findings.length, 1);
  assert.equal(findings[0].rule, 'no-consecutive-h1');
  assert.equal(findings[0].line, 2);
});

test('H1 followed by ## is NOT flagged (different header levels)', () => {
  const text = '# First\n## Second\n';
  assert.deepEqual(lint(text), []);
});

test('H1 followed by paragraph then H1 is NOT flagged (content between)', () => {
  const text = '# First\n\nBody paragraph.\n\n# Second\n';
  assert.deepEqual(lint(text), []);
});
