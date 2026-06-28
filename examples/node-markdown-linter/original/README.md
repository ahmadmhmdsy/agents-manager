# markdown-linter

Tiny markdown linter. Currently enforces:

- `no-trailing-h1` — no `# Title` as the last line (titles should not sit at end of file)

## Run

```
npm test
```

## Use

```
node src/linter.js path/to/file.md
```
