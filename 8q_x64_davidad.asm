%include "os_dependent_stuff.asm"
%ifdef LOOPED
  %define NOPRETTY 1
  mov r10, LOOPED
%endif
  
solve:
  mov rbp, 0b11111111      ; all eight possibilities available
  mov rdi, 0x000000000000 ; no squares under attack from anywhere
  movq xmm1, rdi            ; maintain this state in xmm1
  mov r15, 0x000100010001  ; attack mask for one queen (left, right, and center)
  mov rsi, 0xff            ; mask for low byte
  movq xmm7, rsi           ; stored in xmm register
  mov r13, rsp             ; current stack pointer (if we backtrack here, then
  mov r14, rsp             ;   the entire solution space has been explored)
  sub r14, 2*8*7           ; this is where the stack pointer would be when we've
                           ;   completed a winning state
%ifndef NOPRETTY
  mov rdi, 1           ; stdout
  mov rcx, 0
  movq xmm8, rcx       ; bitmap of queens
  movq mm0, rcx        ; horizontal position of printer
%endif
  jmp next_state

align 16                   ; 16-byte-align jump targets
next_state:
  mov rax, rbp
  neg rax
  and rax, rbp               ; find next available position in current level
  jz backtrack             ; if there is no available position, we must go back
  xor ebp, eax               ; mark position as unavailable
%ifndef NOPRETTY
  pinsrb xmm8, ecx, 0  ; insert mask for this queen
%endif
  cmp rsp, r14             ; check if we've done 7 levels already
  je win                   ; if so, we have a win state. otherwise continue
%ifndef NOPRETTY
  pslldq xmm8, 1       ; shift bitmap to the left
%endif
  movq rbx, xmm1           ; save current state ...
  push rbp
  push rbx                 ;   ... to stack
  mul r15                  ; replicate attack mask into three words using r15, a
  movq xmm5, rax           ; constant, and then load into xmm5
  por xmm1, xmm5           ; mark as attacking in overall state
  vpsllw xmm2, xmm1, 1      ; shift entire state to left, place in xmm2
  pblendw xmm1, xmm2, 0b100 ; only copy "left-attacking" word back from xmm2
  vpsrlw xmm3, xmm1, 1      ; shift entire state to right, place in xmm3
  pblendw xmm1, xmm3, 0b010 ; only copy "right-attacking" word back from xmm3
  vpsrldq xmm2, xmm1, 4     ; shift state right 4 *bytes*, place in xmm2
  vpsrldq xmm3, xmm1, 2     ; shift state right 2 bytes, place in xmm3
  por xmm2, xmm3            ; collect bitwise ors in xmm2
  por xmm2, xmm1            
  vpandn xmm4, xmm2, xmm7   ; invert and select low byte
  movq rbp, xmm4            ; place in rbp
  jmp next_state           ; now we're set up to iterate

align 16
backtrack:
  cmp rsp, r13             ; are we done?
  je done
  pop rcx                  ; restore last state
  pop rbp
  movq xmm1, rcx
%ifndef NOPRETTY
  psrldq xmm8, 1       ; shift bitmap to the right
%endif
  jmp next_state           ; try again

align 16
win:
  inc rdi                   ; increment solution counter
%ifndef NOPRETTY
  %include "winprinter.asm"
%endif
  jmp next_state           ; keep going

align 16
done:
%ifdef LOOPED
  dec r10
  jnz solve
%endif
%ifndef NOPRETTY
  mov rax, SYSCALL_WRITE
  mov rsi, cursormove2
  mov rdx, boardend - cursormove2
  syscall
%endif
  mov rax, SYSCALL_EXIT    ; set system call to exit
  syscall                  ; this will exit with our solution count as status
