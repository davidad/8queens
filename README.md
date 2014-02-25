8queens
=======

x64 assembler solution to n-queens problem. Not tested for `n` other than 8.

```
$ git clone https://github.com/davidad/8queens.git
Cloning into '8queens'...
$ cd 8queens
$ make
mkdir download
curl "http://www.nasm.us/pub/nasm/releasebuilds/2.11\
/macosx/nasm-2.11-macosx.zip" -o download/nasm-osx.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1219k  100 1219k    0     0   638k      0  0:00:01  0:00:01 --:--:--  639k
test `git hash-object download/nasm-osx.zip` = dae69c310bedc02f07501adef71795d46e8c2a18
cd download \
&& cpio -id --quiet nasm-2.11/nasm < nasm-osx.zip \
&& mv nasm-2.11/nasm ../nasm \
&& rmdir -p nasm-2.11/
ls -l nasm
-rwxrwxrwx  1 davidad  staff  1814656 Feb 25 02:55 nasm
./nasm -v
NASM version 2.11 compiled on Dec 31 2013
nasm 8queens.asm -f macho64 -o 8queens.o
ld -o 8queens 8queens.o
ld: warning: -macosx_version_min not specified, assuming 10.7
===
./8queens; echo $?
92
$
```
