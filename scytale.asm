[BITS 64]

SECTION .text
    GLOBAL scytale_decode
    GLOBAL scytale_encode

; unsigned char* scytale_decode(const char* encoded_payload, unsigned char* buf);
scytale_decode:
	push rsi				; preserve rdi/rsi so we can use lod/sto
	push rdi
	mov rsi, rcx				; encoded_payload
	mov rdi, rdx				; buf
	lodsw					; skip 2-byte header
.dmainloop:
	lodsb					; grab the skip byte
	test al, al				; did we hit a null terminator?
	jz .ddone
	sub al, 0x30				; convert to int
	movzx rcx, al				; zero upper bits
	add rsi, rcx				; hop over the skip value
	lodsb					; get the first byte
	sub al, 0x30				; convert to int
	cmp al, 9				; <=9 ?
	jbe .first				; hop over
	sub al, 7				; get the letter
.first:
	mov r8b, al				; store the low nibble
	lodsb					; get the second byte
	sub al, 0x30				; convert to int
	cmp al, 9				; <=9 ?
	jbe .second				; hop over
	sub al, 7				; get the letter
.second:
	shl al, 4				; shift the bits over
	or al, r8b				; let our nibbles combine 
	stosb					; add to buf
	jmp .dmainloop				; all of this has happened before...

.ddone:
	mov rax, rdi				; set up the return pointer
	pop rdi					; cleanup
	pop rsi
	ret

; unsigned char* scytale_encode(char* dest, const char* src, size_t len);
scytale_encode:
	push rsi				; preserve rsi/rdi, so we can use lod/sto
	push rdi
	mov rdi, rcx				; pointer to the destination buffer
	mov rsi, rdx				; pointer to the source buffer
	rdtsc					; read the time stamp, for entropy
	call .converttohex			; store first byte of header garbage
	rdtsc					; get some more entropy
	call .converttohex			; store second byte of header garbage
.emainloop:
	rdtsc					; grab our entropy
	and rax, 7				; grab the last 3 bits (0-7)
	mov rcx, rax				; store the garbage loop counter
	call .converttohex			; store the skip byte
	jrcxz .continue				; if we have a 0 skip byte, no need to pad
.paddingloop:
	rdtsc					; load our entropy
	call .converttohex			; store the byte
	loop .paddingloop
.continue:
	lodsb					; load the byte from the string
	mov rdx, rax				; so we don't lose it
	shr rax, 4				; get the last 4 bits
	call .converttohex			; store the upper nibble
	mov rax, rdx				; move the lower nibble
	call .converttohex			; store the lower nibble
	dec r8					; loop counter
	jnz .emainloop
.edone:
	xor rax, rax				; create a null terminator
	stosb					; store it at the end
	xchg rax, rdi				; store the return pointer for the end of the string
	pop rdi					; cleanup
	pop rsi
	ret	
.converttohex:
	and al, 0x0F				; remove the top bits
	add al, 0x30				; convert to a character
	cmp al, 0x39				; is the value >9?
	jbe .hexdone				; then we're done
	add al, 7				; convert to the proper A-F
.hexdone:
	stosb					; store the value
	ret
	
