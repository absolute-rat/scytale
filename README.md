# scytale

Scytale is a lightweight custom encoding scheme, written entirely in x86-64 assembly.

## Pros

- Small footprint means it can potentially fit in shellcode
- Very low entropy (4.0)

## Cons

- Overhead causes roughly a 5x size increase for any encoded data
- Once the method is known, all encoded data is compromised
