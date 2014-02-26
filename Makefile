.PHONY: test
test: 8q_C_bluecalm 8q_x64_davidad
	time ./8q_C_bluecalm  ; echo $$?
	time ./8q_x64_davidad ; echo $$?

8q_C_bluecalm: 8q_C_bluecalm.c
	gcc -O3 $^ -o $@

UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	FORMAT := macho64
endif
ifeq ($(UNAME),Linux)
	FORMAT := elf64
endif

8q_x64_davidad: 8q_x64_davidad.o
	ld -o $@ $^

8q_x64_davidad.o: 8q_x64_davidad.asm
	nasm $^ -DLOOPED=10000 -f $(FORMAT) -o $@

.PHONY: clean
clean:
	rm -rf *.o 8q_C_bluecalm 8q_x64_davidad
