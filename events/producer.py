#!/usr/bin/env python3
import sys, pandas as pd, numpy as np; typesNames = pd.read_csv("TypesAndNames.csv")

for _ in range(int((len(sys.argv) - 1) and int(sys.argv[1]))) : print(
    ",".join((
        "2018-01-%02d %02d:%02d:%02d" % (
            np.random.randint(1, 7+1), np.random.randint(0, 23+1), *np.random.randint(0, 59+1, size=2)
        ),
        ".".join(tuple(
            map(lambda x: str(int(x)), np.random.randint(0x01000001, 0xdfffffff+1, dtype=np.uint32).tobytes())
        )),
        *typesNames.values[np.random.choice(typesNames.shape[0])][::-1],
        "%.4f" % np.random.normal(25, 5)
    ))
)
