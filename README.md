# scytale

Scytale is a lightweight custom encoding scheme, written entirely in x64 assembly.

## Pros

- Small footprint means it can potentially fit in shellcode
- Very low entropy (4.0)

## Cons

- Overhead causes roughly a 5x size increase for any encoded data
- Simple decryption process


# Details

I originally got the idea from an old ancient greek cipher method of the same name. I had wondered what it might look like expressed in code, and it was quite unusable. However, the idea of a variable diameter 'rod' came to mind, which would solve the pattern recognition issues that the scytale faces. For the final version of the method, I embedded the 'key' into the encoding stream itself, so that there is no key necessary.

An example of a single byte encoding would be:

```
+--+-+---+--+------+--+
|AA|B|CCC|DD|etc...|00|
+--+-+---+--+------+--+
```

The AA represents 2 junk bytes, just to prevent any kind of pattern recognition. B represents a 'skip' byte, which should be a value between 1-9. The skip byte indicates how many fake padded values of C that follow it. The C values are randomly generated hex values (0-9, A-F). Finally, DD holds our actual byte of the encoded string, in little endian. The BCDD streams repeat for each byte in the encoded string, and this follows until null termination.
