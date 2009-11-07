#!/usr/bin/env python

import sys

def merge(filename1, filename2):
    ## ensure that f1 and f2 are both readable
    f1 = file(filename1).readlines()
    f2 = file(filename2).readlines()

    ## ensure that f1 has some lines
    last_line = f1[-1]

    candidates = [n for n, line in reversed(enumerate(f2)) if line == last_line]
    for n in candidates:
        if len(f1) < n+1: continue
        if f2[:n+1] == f1[-n-1]:
           new = f2[n+1:]
           break
    else:
        new = f2

    ## append to f1


if __name__ == "__main__":
    ## ensure that there are enough command line args
    merge(sys.argv[1], sys.argv[2])
