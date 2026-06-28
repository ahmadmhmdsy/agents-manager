from csv_summarizer import summarize


def test_sum_aggregation():
    rows = [
        {'cat': 'a', 'val': '10'},
        {'cat': 'a', 'val': '20'},
        {'cat': 'b', 'val': '5'},
    ]
    out = summarize(rows, 'cat', 'val', 'sum')
    assert out['a'] == {'sum': 30.0, 'count': 2}
    assert out['b'] == {'sum': 5.0, 'count': 1}
