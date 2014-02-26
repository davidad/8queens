8queens
=======

**free-2x-speedup**: This version, inspired by a [Hacker News
comment](https://news.ycombinator.com/item?id=7302741), only searches half the
solution space, since it is a symmetric problem. This reduces the solution time
to under 5μs:
```
$ git checkout free-2x-speedup
Switched to branch 'free-2x-speedup'
$ make clean
rm -f *.o 8queens
$ make
./nasm 8queens.asm -DLOOPED=10000 -f macho64 -o 8queens.o -MD 8queens.dep
ld -o 8queens 8queens.o
===
time ./8queens ; echo $?

real	0m0.046s
user	0m0.044s
sys	0m0.000s
92
(looped 10,000 times)
```

* * *

x64 assembler solution to n-queens problem. Not tested for `n` other than 8.

```
$ git clone https://github.com/davidad/8queens.git
Cloning into '8queens'...
[snip]
$ cd 8queens
$ make
[snip]
nasm 8queens.asm -f macho64 -o 8queens.o
ld -o 8queens 8queens.o
===
./8queens; echo $?
92
$
```

Somewhat surprisingly, the very first time I tried to run this code, it successfully returned 92.
(Though it did take me about 3 hours of thinking and plenty of referencing the Intel 64 manual
before I could write it at all.)
