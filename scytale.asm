[BITS 64]

SECTION .text
    GLOBAL scytale_decode
    GLOBAL scytale_encode

; unsigned char* scytale_decode(const char* encoded_payload, unsigned char* buf);
scytale_decode:
	push rsi		; startup preservation
	push rdi
	mov rsi, rcx		; encoded_payload
	mov rdi, rdx		; buf
	lodsw			; skip 2-byte header

.main_loop:
	lodsb			; grab the skip byte
	test al, al		; did we hit a null terminator?
	jz .done
	sub al, 0x30		; convert to int
	movzx rcx, al		; zero upper bits
	add rsi, rcx		; hop over the skip value
	lodsb			; get the first byte
	sub al, 0x30		; convert to int
	cmp al, 9		; <=9 ?
	jbe .first		; hop over
	sub al, 7		; get the letter
.first:
	mov r8b, al		; store the low nibble
	lodsb			; get the second byte
	sub al, 0x30		; convert to int
	cmp al, 9		; <=9 ?
	jbe .second		; hop over
	sub al, 7		; get the letter
.second:
	shl al, 4		; shift the bits over
	or al, r8b		; let our nibbles combine 
	stosb			; add to buf
	jmp .main_loop		; all of this has happened before...

.done:
	mov rax, rdi		; set up the return pointer
	pop rsi			; cleanup
	pop rdi
	ret


; unsigned char* scytale_encode(char* dest, const char* src, size_t len);
; gross clanker version - will refactor later, but just needed to validate output, and make project functional
scytale_encode:
    push rsi
    push rdi
    push rbx
    mov rdi, rcx
    mov rsi, rdx
    mov r10, r8
    mov rbx, 2
.e_header:
    rdtsc
    call .to_hex_stosb
    dec rbx
    jnz .e_header

.e_main:
    test r10, r10
    jz .e_done
    lodsb
    mov r9b, al
    dec r10
    rdtsc
    xor edx, edx
    mov ecx, 9
    div ecx
    inc edx
    mov al, dl
    add al, 0x30
    stosb    
    movzx rcx, dl
.e_garbage:
    rdtsc
    call .to_hex_stosb
    loop .e_garbage
    mov al, r9b
    and al, 0x0F        
    call .to_hex_stosb 
    mov al, r9b
    shr al, 4           
    call .to_hex_stosb 
    jmp .e_main

.to_hex_stosb:
    and al, 0x0F
    add al, 0x30
    cmp al, 0x39
    jbe .w_h
    add al, 7
.w_h:
    stosb
    ret

.e_done:
    xor al, al
    stosb
    mov rax, rdi
    pop rbx
    pop rdi
    pop rsi
    ret
