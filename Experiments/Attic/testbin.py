import sys
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
args = parser.parse_args()

for filename in args.files:
    print(filename)
    with open(filename,'rb') as f:
        data = f.read()
        print(" ".join("%02x"%b for b in data))
