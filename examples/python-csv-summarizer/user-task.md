Add a `mean` aggregation to `csv_summarizer.summarize`. It should work like `sum` and `count` but report the arithmetic mean of the bucket.

Specifically:
1. Update `summarize()` in `csv_summarizer.py` to accept `'mean'` in the `agg` parameter.
2. When `agg='mean'`, the output dict's value should include `mean` alongside `sum` and `count`.
3. Update the CLI `--agg` choices to include `mean`.
4. Add a pytest case `test_mean_aggregation` that verifies mean is `sum / count` for each bucket.
5. Existing tests must still pass (`pytest`).
