%ifidn __OUTPUT_FORMAT__,elf64
  %define SYSCALL_WRITE 1
  %define SYSCALL_EXIT  60
%elifidn __OUTPUT_FORMAT__,macho64
  %define SYSCALL_WRITE 0x2000004
  %define SYSCALL_EXIT  0x2000001
%endif

default rel
section .text
global _start
_start:       ; OSX likes "_start"
global start
start:        ; Linux likes "start"
