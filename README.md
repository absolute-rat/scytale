# scytale

scytale is a low-entropy/lightweight transpositional stream encoding scheme, written entirely in x64 assembly.

## Pros

- Small footprint means it can potentially fit in shellcode
- Maintans a low entropy score (~4.0) no matter what data is being encoded
- Avoids predictable byte-distance pattern recognition

## Cons

- Overhead causes roughly a 5x size increase for any encoded data
- Linear decoding process


# Stream architecture

I originally got the idea from an old ancient greek cipher method of the same name. I had wondered what it might look like expressed in code, and it was quite unusable. However, the idea of a variable diameter 'rod' came to mind, which would solve the pattern recognition issues that the scytale faces. For the final version of the method, I embedded the 'key' into the encoding stream itself, so that there is no key necessary.

An example of a single byte encoding would be:

```
[Header][Skip Byte][Padding][Payload Byte]
+--+-+---+--+--+
|AA|B|CCC|DD|00|
+--+-+---+--+--+
```

The AA represents 2 random junk hex bytes, just to prevent any kind of pattern recognition. This is probably a bit overkill, since the first byte isn't a valuable byte, but this could make manual inspection a bit more confusing. B represents a 'skip' byte, which should be a value between 1-9. The skip byte indicates how many fake padded values of C that follow it. The C values are randomly generated hex values (0-9, A-F). Finally, DD holds our actual byte of the encoded string, in little endian. The BCDD streams repeat for each byte in the encoded string, and this follows until null termination. The method could be altered rather trivially to include some basic new rules, to avoid any signature that might happen, and could be altered to use a key-based encryption/decryption method instead.

## Example

This is 'ABC' encoded in scytale:

2F3BBC14939DFAB0B1241E34

2F is our garbage header. 3 indicates 3 garbage characters to skip. '14' is our 0x41. 9 is our next part of the stream, indicating 9 garbage characters to skip. '24' is our 0x42. 1 indicates a single garbage character to skip, so '34' is our final byte, 0x43.
