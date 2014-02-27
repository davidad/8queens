## 8queens, C vs. ASM edition

After my [blog post](http://davidad.github.io/blog/2014/02/25/overkilling-the-8-queens-problem/) about this repository made it to [the front page of Hacker News](https://news.ycombinator.com/item?id=7301481), [a challenger appeared](https://news.ycombinator.com/item?id=7302005), wondering if their old C code was really 10 times faster than my handcrafted assembly. I believe we are all glad this is not actually the case, although it appeared so at first. Both my code and bluecalm's code have been tweaked in this branch to do nothing other than solve the 8-queens problem ten thousand times in a row, and return the count of solutions as the final answer. Anyone who wants to repeat the experiment on their own (Sandy Bridge or newer) hardware should be able to clone this branch of the repository as follows:

    $ git clone https://github.com/davidad/8queens.git
    $ cd 8queens
    $ git checkout +c_comparison

and, assuming you have a recent version of `nasm` installed, simply run 

    $ make

If you're on a Linux machine with `perf stat`, you should get a result like this:

```
gcc -O3 -march=corei7-avx 8q_C_bluecalm.c -o 8q_C_bluecalm
nasm 8q_x64_davidad.asm -DLOOPED=10000 -f elf64 -o 8q_x64_davidad.o
ld -o 8q_x64_davidad 8q_x64_davidad.o
gcc -O3 -march=corei7-avx 8q_C_anonymoushn.c -o 8q_C_anonymoushn
perf stat ./8q_C_bluecalm    ; echo $?
 Performance counter stats for './8q_C_bluecalm':
        830.017139 task-clock (msec)         #    0.997 CPUs utilized          
                94 context-switches          #    0.113 K/sec                  
                 0 cpu-migrations            #    0.000 K/sec                  
               110 page-faults               #    0.133 K/sec                  
     2,912,241,671 cycles                    #    3.509 GHz                    
     1,178,174,090 stalled-cycles-frontend   #   40.46% frontend cycles idle   
   <not supported> stalled-cycles-backend  
     2,807,622,408 instructions              #    0.96  insns per cycle        
                                             #    0.42  stalled cycles per insn
       481,514,866 branches                  #  580.126 M/sec                  
        62,609,541 branch-misses             #   13.00% of all branches        
       0.832742313 seconds time elapsed
92
perf stat ./8q_C_anonymoushn ; echo $?
 Performance counter stats for './8q_C_anonymoushn':
        304.620089 task-clock (msec)         #    0.998 CPUs utilized          
                 5 context-switches          #    0.016 K/sec                  
                 0 cpu-migrations            #    0.000 K/sec                  
               107 page-faults               #    0.351 K/sec                  
     1,117,751,645 cycles                    #    3.669 GHz                    
       486,915,203 stalled-cycles-frontend   #   43.56% frontend cycles idle   
   <not supported> stalled-cycles-backend  
     1,399,792,421 instructions              #    1.25  insns per cycle        
                                             #    0.35  stalled cycles per insn
       354,278,866 branches                  # 1163.019 M/sec                  
         9,608,603 branch-misses             #    2.71% of all branches        
       0.305083524 seconds time elapsed
92
perf stat ./8q_x64_davidad   ; echo $?
 Performance counter stats for './8q_x64_davidad':
        103.420555 task-clock (msec)         #    0.998 CPUs utilized          
                 0 context-switches          #    0.000 K/sec                  
                 0 cpu-migrations            #    0.000 K/sec                  
                 2 page-faults               #    0.019 K/sec                  
       368,324,397 cycles                    #    3.561 GHz                    
       149,556,455 stalled-cycles-frontend   #   40.60% frontend cycles idle   
   <not supported> stalled-cycles-backend  
       676,284,083 instructions              #    1.84  insns per cycle        
                                             #    0.22  stalled cycles per insn
       120,650,286 branches                  # 1166.599 M/sec                  
         2,760,927 branch-misses             #    2.29% of all branches        
       0.103599334 seconds time elapsed
92
```

bluecalm also suggests that you try replacing `-O3` with `-Ofast` if you have a version of gcc that supports it. (I don't yet.)
