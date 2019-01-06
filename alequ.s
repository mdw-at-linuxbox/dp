*
pool dsect
alsave ds 18f
alalloc ds 6h
alfree ds 6h
freelist ds 1f
firstp ds 1f
lastp ds 1f
poolsize ds 1f
freesize ds 1f
grow ds 1f
alnew ds 2f
alreg1 ds 7f
alreg2 ds 7f
poollen equ *-pool
