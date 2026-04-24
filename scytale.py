#!/usr/bin/python3

import argparse
import sys
import random

# Simple command line scytale encoder, for encoding resources/binary blobs/etc...
# python3 ./scytale.py /path/to/file.bin


def scytale_encode(data):

    complete = random.choice("0123456789ABCDEF") + random.choice("0123456789ABCDEF")
    i = 0
    while (i < len(data)):
        randskip = random.randint(0,7)
        complete += str(randskip)
        while (randskip):
            complete += random.choice("0123456789ABCDEF")
            randskip -= 1

        complete += str(f"{((data[i] & 0x0F) << 4) | ((data[i] & 0xF0) >> 4):02X}")
        i += 1

    return complete

def main():
    parser = argparse.ArgumentParser(description="Scytale Encoder")
    parser.add_argument("file", help="The file to encode")
    parser.add_argument("-o", "--output", help="Output file (defaults to stdout)")
    args = parser.parse_args()

    try:
        with open(args.file, "rb") as f:
            raw_data = f.read()
            
        if not raw_data:
            print("[-] Error: Input file is empty.")
            return

        encoded = scytale_encode(raw_data)

        if args.output:
            with open(args.output, "w") as f:
                f.write(encoded)
            print(f"[+] Encoded {len(raw_data)} bytes to {args.output}")
        else:
            print(encoded)

    except FileNotFoundError:
        print(f"[-] Error: File '{args.file}' not found.")
        sys.exit(1)

if __name__ == "__main__":
    main()
