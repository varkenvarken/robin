; a program that start at 128K (i.e. the spram area)
start: 0x20000
    loadl   r2,#0x12345678
    loadl   r4,#storage
    storl   r2,r4,r0
    loadl   r3,r4,r0
    halt
storage:
    long    0
