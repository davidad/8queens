%include "os_dependent_stuff.asm"
  mov rdx, 0b11111111      ; all eight possibilities available
  mov r8, 0x000000000000 ; no squares under attack from anywhere
  movq xmm1, r8            ; maintain this state in xmm1
  mov r15, 0x000100010001  ; attack mask for one queen (left, right, and center)
  mov r14, 0xff            ; mask for low byte
  movq xmm7, r14           ; stored in xmm register
  mov r13, rsp             ; current stack pointer (if we backtrack here, then
  mov r14, rsp             ;   the entire solution space has been explored)
  sub r14, 2*8*7           ; this is where the stack pointer would be when we've
                           ;   completed a winning state
next_state:
  bsf rcx, rdx             ; find next available position in current level
  jz backtrack             ; if there is no available position, we need to go back
  btc rdx, rcx             ; mark position as unavailable
  cmp rsp, r14             ; check if we've done 7 levels already
  je win                   ; if so, we have a win state. otherwise continue
  movq r10, xmm1           ; save current state ...
  push rdx
  push r10                 ;   ... to stack
  mov rax, r15             ; set up attack mask
  shl rax, cl              ; shift into position
  movq xmm2, rax
  por xmm1, xmm2           ; mark as attacking in all directions
  vpsllw xmm2, xmm1, 1      ; shift entire state to left, place in xmm2
  vpsrlw xmm3, xmm1, 1      ; shift entire state to right, place in xmm3
  pblendw xmm1, xmm2, 0b100 ; only copy "left-attacking" word back from xmm2
  pblendw xmm1, xmm3, 0b010 ; only copy "right-attacking" word back from xmm3
  vpsrldq xmm2, xmm1, 4     ; shift state right 4 *bytes*, place in xmm2
  vpsrldq xmm3, xmm1, 2     ; shift state right 2 bytes, place in xmm3
  por xmm2, xmm3            ; collect bitwise ors in xmm2
  por xmm2, xmm1            
  vpandn xmm4, xmm2, xmm7   ; invert and select low byte
  movq rdx, xmm4            ; place in rdx
  jmp next_state           ; now we're set up to iterate

backtrack:
  cmp rsp, r13             ; are we done?
  je done
  pop r10                  ; restore last state
  pop rdx
  movq xmm1, r10
  jmp next_state           ; try again

win:
  inc r8                   ; increment solution counter
  jmp next_state           ; keep going

done:
  mov rdi, r8
  mov rax, SYSCALL_EXIT
  syscall
