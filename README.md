8queens
=======

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
