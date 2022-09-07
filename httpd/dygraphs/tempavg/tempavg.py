#!/usr/bin/env python3

from argparse import FileType, ArgumentParser
from bisect import bisect_right
import csv
from datetime import datetime
from itertools import zip_longest
from math import isnan
from sys import stderr


def init_args():
    p = ArgumentParser()

    p.add_argument('--append', '-a', action='store_true')
    p.add_argument('input_file_1', type=FileType('r'), help='Input file 1')
    p.add_argument('input_file_2', type=FileType('r'), help='Input file 2')
    p.add_argument('-o', '--output-file', dest='output_file', default='/dev/stdout', help='Output file. Default: /dev/stdout')

    return p.parse_known_args()[0]


def tempavg(temp_file_1, temp_file_2, output_file, append=False):
    last_date = None
    if append:
        with open(output_file, 'r', errors='ignore') as f:
            r = csv.reader(f, delimiter='\t')
            for data in r:
                last_date = data[0]
    print('Last date:', last_date, file=stderr)
    data = ([], [])
    for i, f in enumerate([temp_file_1, temp_file_2]):
        r = csv.reader(f, delimiter='\t')
        header = next(r)
        for date, value in r:
            if last_date and date <= last_date:
                continue
            print(date, value, file=stderr)
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
        if i == 0:
            return data[0][1]
        elif i == len(data):
            return data[i-1][1]
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
            vs.append(v)
        # Generate the (min, mean, max) bands
        mean.append(('%s' % datetime.fromtimestamp(ts), min(vs), sum(vs)/len(vs), max(vs)))
    return mean, header


if __name__ == '__main__':
    args = init_args()
    mean, header = tempavg(args.input_file_1, args.input_file_2, args.output_file, args.append)
    mode = 'a' if args.append else 'w' if args.output_file == '/dev/stdout' else 'x'
    with open(args.output_file, mode) as output_file:
        if not args.append:
            header = (header[0], 'mean_' + header[1])
            print('%s\t%s' % header, file=output_file)
        for m in mean:
            print('%s\t%.2f;%.2f;%.2f' % m, file=output_file)
