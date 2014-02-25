section .data

cursormove0:
db `\n\n\n\n\n\n\n\n\n\n\e[10A`

boardstart:

; board top
db `\u2553`
times 8 db `\u2500`
db `\u2556`

%define evenrow `\e[1;31;47m \e[m\e[1;31;40m \e[m`
%define oddrow  `\e[1;31;40m \e[m\e[1;31;47m \e[m`
%define rowend `\e[1B\e[10D`

db rowend

%rep 4
db `\u2551`
times 4 db evenrow
db `\u2551`
db rowend

db `\u2551`
times 4 db oddrow
db `\u2551`
db rowend
%endrep

boardbottom:
db `\u2559`
times 8 db `\u2500`
db `\u255c`
db rowend

cursormove1:
db `\e[10A\e[10C`
cursormove2:
db `\e[10B\e[80D`
boardend:db 0
boardlen0 equ cursormove2 - cursormove0
boardlen1 equ cursormove2 - boardstart
boardlen2 equ boardend - boardstart
dq boardlen1, boardlen2
firstsquare equ boardstart+0x34
colstride equ 0x0e
rowstride equ 0x7f
empty_byte: db ' '
queen_byte: db 'Q'

section .text
mov r12, firstsquare
movq r9, xmm8 ; fetch queen bitmap
mov rbx, empty_byte
xor rax, rax  ; clear rax
xor r11, r11  ; bit index = 0
format_loop:  ; unrolled loop
%assign i 0   ; these % directives are handled by nasm's preprocessor
%rep 8
  bt r9, r11
  setc al
  xlatb
  mov byte [r12+colstride*i], al
  inc r11
%assign i i+1
%endrep
  add r12, rowstride
  cmp r11, 8*8
  jl format_loop

mov rsi, boardstart
movq r11, mm0
inc r11
mov rdx, boardlen1
cmp r11, 8
jne check_one
mov rdx, boardlen2
mov r11, 0
jmp do_print
check_one:
cmp r11, 1
jne do_print
mov rsi, cursormove0
mov rdx, boardlen0

do_print:
movq mm0, r11
mov rax, SYSCALL_WRITE
syscall
