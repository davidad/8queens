.PHONY: test

UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	FORMAT := macho64
	PERF := time
endif
ifeq ($(UNAME),Linux)
	FORMAT := elf64
	PERF := perf stat
endif
test: 8q_C_bluecalm 8q_x64_davidad 8q_C_anonymoushn
	$(PERF) ./8q_C_bluecalm    ; echo $$?
	$(PERF) ./8q_C_anonymoushn ; echo $$?
	$(PERF) ./8q_x64_davidad   ; echo $$?

8q_C_anonymoushn: 8q_C_anonymoushn.c
	gcc -O3 -march=corei7-avx $^ -o $@

8q_C_bluecalm: 8q_C_bluecalm.c
	gcc -O3 -march=corei7-avx $^ -o $@

8q_x64_davidad: 8q_x64_davidad.o
	ld -o $@ $^

8q_x64_davidad.o: 8q_x64_davidad.asm
	nasm $^ -DLOOPED=10000 -f $(FORMAT) -o $@

.PHONY: clean
clean:
	rm -rf *.o 8q_C_bluecalm 8q_x64_davidad 8q_C_anonymoushn
