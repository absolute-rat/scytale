[BITS 64]

SECTION .text
    GLOBAL scytale_decode
    GLOBAL scytale_encode

; unsigned char* scytale_decode(const char* encoded_payload, unsigned char* buf);
scytale_decode:
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
    ret

; scytale_encode(char* dest, const char* src, size_t len);
scytale_encode:
	ret		; in progress
