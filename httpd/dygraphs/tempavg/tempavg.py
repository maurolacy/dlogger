#!/usr/bin/env python3
import csv
import sys
from datetime import datetime
from bisect import bisect_right
from itertools import zip_longest
from math import isnan


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
    for ds in zip_longest(*data):
        i = 1
        while ds[0] is None:
            ds[0] = ds[i]
            i += 1
        # Follow the first dataset
        ts = ds[0][0]
        vs = []
        for i, d2 in enumerate(data, 1):
            v = lerp_array(d2, ts)
            if not isnan(v):
                vs.append(v)
            else:
                vs.append(ds[0][1])
        mean.append(('%s' % datetime.fromtimestamp(ts), min(vs), sum(vs)/len(vs), max(vs)))

    # TODO: Generate the (min, mean, max) bands

    return mean, header


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: %s <file1> <file2>" % sys.argv[0], file=sys.stderr)
        sys.exit(1)
    mean, header = tempavg(sys.argv[1], sys.argv[2])
    header = (header[0], 'mean_' + header[1])
    print('%s\t%s' % header)
    for m in mean:
        print('%s\t%.2f;%.2f;%.2f' % m)
