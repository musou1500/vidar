#!/usr/bin/env python3
import sys

if len(sys.argv) < 2:
    print("usage: font2c ./font.txt")

def gen_c_source(data):
    print("char font[] = {")
    print(",".join(data))
    print("};")


cur = 0
data = []
with open(sys.argv[1], "r") as f:
    for line in f:
        if line.startswith("*") or line.startswith("."):
            # read bytes
            line = line.replace("*", "1")
            line = line.replace(".", "0")
            data.append(hex(int("0b"+line, 0)))

    gen_c_source(data)
