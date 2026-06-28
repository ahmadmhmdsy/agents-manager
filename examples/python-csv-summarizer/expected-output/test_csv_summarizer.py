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


def test_mean_aggregation():
    rows = [
        {'cat': 'a', 'val': '10'},
        {'cat': 'a', 'val': '20'},
        {'cat': 'b', 'val': '5'},
    ]
    out = summarize(rows, 'cat', 'val', 'mean')
    assert out['a']['mean'] == 15.0
    assert out['b']['mean'] == 5.0
    # sum and count should still be present
    assert out['a']['sum'] == 30.0
    assert out['a']['count'] == 2
