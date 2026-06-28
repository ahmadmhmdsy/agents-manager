"""CSV summarizer — aggregate a numeric column by category."""
import argparse
import csv
import sys
from collections import defaultdict


def summarize(rows, group_col, value_col, agg):
    buckets = defaultdict(list)
    for row in rows:
        buckets[row[group_col]].append(float(row[value_col]))
    out = {}
    for key, vs in buckets.items():
        entry = {'sum': sum(vs), 'count': len(vs)}
        if agg == 'mean':
            entry['mean'] = sum(vs) / len(vs)
        out[key] = entry
    return out


def main():
    p = argparse.ArgumentParser()
    p.add_argument('csvfile')
    p.add_argument('--group', required=True)
    p.add_argument('--value', required=True)
    p.add_argument('--agg', choices=['sum', 'count', 'mean'], required=True)
    args = p.parse_args()

    with open(args.csvfile, newline='') as f:
        rows = list(csv.DictReader(f))
    result = summarize(rows, args.group, args.value, args.agg)
    for k, v in result.items():
        line = f'{k}\t{v["sum"]}\t{v["count"]}'
        if 'mean' in v:
            line += f'\t{v["mean"]}'
        print(line)


if __name__ == '__main__':
    main()
