import fileinput

cycles = []
for line in fileinput.input():
    if line.startswith("04"):
        results = line.strip().split(' ')
        cycles.extend(int(v,16) for v in results[1:])
ins = ("mark",
       "move", "mover",
       "load", "loadl", "load #", "loadl #",
       "stor", "storl",
       "push", "pop",
       "jal", "setbra (true)", "setbra (false)",
       "alu", "divs (worst)")

for k in zip (ins,cycles):
    print("%-15s %d"%k)

