[BITS 64]

SECTION .text
    GLOBAL scytale_decode
    GLOBAL scytale_encode

scytale_decode:
    xchg rsi, rcx	; for math
    xchg rdi, rdx	
    lodsw		; hop over the fake header
    xor rbx, rbx	; zero rbx (string length)

.loop:
    lodsb		; read the skip byte
    test al, al		; did we hit a null?
    jz .done
    sub al, 0x30	; convert to int
    movzx rax, al	; fix the upper bits
    add rsi, rax	; skip ahead by the value of the skip byte
    lodsw		; grab the real bytes
    sub ax, 0x3030	; dual wield subtraction
    cmp ah, 9		; test high nibble
    jbe .high
    sub ah, 7
.high:
    shl ah, 4		; move high nibble to top 4 bits
    cmp al, 9		; test low nibble
    jbe .low
    sub al, 7
.low:
    or al, ah		; let our nibbles combine
    stosb               ; write the byte to buffer
    inc rbx             ; string length++
    jmp .loop

.done:
    xchg rax, rbx       ; return length
    ret


scytale_encode:
	ret		; in progress
