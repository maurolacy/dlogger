#!/usr/bin/env python3
import csv
import sys
from datetime import datetime
from bisect import bisect_right
from itertools import zip_longest


def tempavg(temp_file_1, temp_file_2):
    data = ([], [])
    for i, f in enumerate([temp_file_1, temp_file_2]):
        r = csv.reader(open(f), delimiter='\t')
        header = next(r)
        for date, value in r:
            # Convert to timestamps
            ts = datetime.strptime(date, "%Y-%m-%d %H:%M:%S").timestamp()
            v = float(value)
            data[i].append((ts, v))

    # Interpolate the values
    # Precise method, which guarantees v = v1 when t = 1
    def lerp(v0, v1, t):
        return (1 - t) * v0 + t * v1

    def lerp_array(data, ts):
        i = bisect_right(list(map(lambda e: e[0], data)), ts)
        if i in (0, len(data)):
            return float('nan')
        t = (ts - data[i-1][0])/(data[i][0] - data[i-1][0])

        interp = lerp(data[i-1][1], data[i][1], t)

        return interp

    # Generate the mean
    mean = []
    for d1, d2 in zip_longest(data[0], data[1]):
        if d1 is None:
            d1 = d2
        # Follow the first dataset
        ts = d1[0]
        v1 = d1[1]
        if d2 is not None and d2[0] <= ts:
            v2 = lerp_array(data[1], ts)
        else:
            v2 = v1
        mean.append((ts, round((v1+v2)/2, 2)))
    return mean, header

    # Generate the (min, mean, max) bands


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: %s <file1> <file2>" % sys.argv[0], file=sys.stderr)
        sys.exit(1)
    mean, header = tempavg(sys.argv[1], sys.argv[2])
    header = (header[0], 'mean_' + header[1])
    mean.insert(0, header)
    w = csv.writer(open('mean.csv', 'w'), delimiter='\t')
    w.writerows(mean)