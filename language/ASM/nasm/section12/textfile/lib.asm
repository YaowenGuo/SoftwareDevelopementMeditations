[SECTION .data]     ; Section containing initialised data  
  
[SECTION .bss]      ; Section containing uninitialized data  
  
[SECTION .text]     ; Section containing code  
  
extern printf       ; All of these are in the standard C library glibc    
extern rand   
extern srand  
extern time  
          
global seedit       ; Seeds the random number generator with a time value  
global pull31       ; Pulls a 31-bit random number  
global pull16       ; Pulls a 16-bit random number; in the range 0-65,535  
global pull8        ; Pulls an 8-bit random number; in the range 0-255  
global pull7        ; Pulls a 7-bit random number; in the range 0-127  
global pull6        ; Pulls a 6-bit random number; in the range 0-63  
global pull4        ; Pulls a (marginal) 4-bit random number; range 0-15  
global newline      ; Outputs a specified number of newlines to stdout  
  
pull31: mov ecx,0       ; For 31 bit random, we don't shift  
    jmp pull  
pull16: mov ecx,15      ; For 16 bit random, shift by 15 bits  
    jmp pull  
pull8:  mov ecx,23      ; For 8 bit random, shift by 23 bits  
    jmp pull  
pull7:  mov ecx,24      ; For 7 bit random, shift by 24 bits  
    jmp pull  
pull6:  mov ecx,25      ; For 6 bit random, shift by 25 bits  
    jmp pull  
pull4:  mov ecx,27      ; For 4 bit random, shift by 27 bits  
pull:   push ecx        ; rand trashes ecx; save shift value on stack  
    call rand       ; Call rand for random value; returned in eax  
    pop ecx         ; Pop stashed shift value back into ECX  
    shr eax,cl      ; Shift the random value by the chosen factor  
                ;  keeping in mind that part we want is in CL  
    ret         ; Go home with random number in eax  
      
seedit: push dword 0        ; Push a 32-bit null pointer to stack, since  
                ;  we don't need a buffer.   
    call time       ; Returns time_t value (32-bit integer) in eax  
    add esp,4       ; Clean up stack  
    push eax        ; Push time value in eax onto stack  
    call srand      ; Time value is the seed value for random gen.  
    add esp,4       ; Clean up stack  
    ret         ; Go home; no return values  
  
newline:  
    mov ecx,10      ; We need a skip value, which is 10 minus the  
    sub ecx,eax     ;  number of newlines the caller wants.  
    add ecx,nl      ; This skip value is added to the address of  
    push ecx        ;  the newline buffer nl before calling printf.  
    call printf     ; Display the selected number of newlines  
    add esp,4       ; Clean up the stack  
    ret         ; Go home  
nl  db 10,10,10,10,10,10,10,10,10,10,0  