# scytale

scytale is a low-entropy/lightweight stream encoder, implemented in pure x64 assembly.

## Pros

- Small footprint (<200 bytes)
- Maintans a low entropy score (~4.0) no matter what data is being encoded
- Avoids predictable byte-distance pattern recognition

## Cons

- Overhead causes roughly a 5x size increase for any encoded data
- Linear decoding process


# Stream Architecture

I originally got the idea from an old ancient greek cipher method of the same name. I had wondered what it might look like expressed in code, and it was quite unusable. However, the idea of a variable diameter 'rod' came to mind, which would solve the pattern recognition issues that the scytale faces. For the final version of the method, I embedded the 'key' into the encoding stream itself, so that there is no key necessary.

An example of a single byte encoding would be:

```
[Header][Skip Byte][Padding][Payload Word]
+--+-+-----+--+--+
|AA|B|C...C|DD|00|
+--+-+-----+--+--+
```

The stream is comprised of two segments, a simple evasion header, and the repeating payload byte stream. The header is simply 2 random ASCII hex values, to avoid static detection of any kind. The skip byte is a single byte, represented as a number between 1-9. This value determines the length of junk padding bytes that will follow the skip byte. Each padding byte is a random hex ASCII value (0-9,A-F). After the garbage padding, our associated payload byte will be represented by the actual little-endian 2 byte hex value, in ASCII (0x41 = 14). The stream repeats the skip byte/padding/payload byte for each byte in the real payload, and ends with a null terminator. 

## Example

This is 'ABC' encoded in scytale:

2F3BBC14939DFAB0B1241E34

2F is our garbage header. 3 indicates 3 garbage characters (BBC) to skip. '14' is our 0x41. 9 is our next part of the stream, indicating 9 garbage characters (39DFAB0B1) to skip. '24' is our 0x42. 1 indicates a single garbage character (E) to skip, so '34' is our final byte, 0x43.


## Notes

The method could be altered rather trivially to include some basic new rules, without strongly impacting the general flow architecture, which might make it easy enough to evade signatures. A key-based implementation would also not be too difficult to implement, if you didn't like leaving the full data in an accessible state for an analyst to access. I currently limit the skip byte to 1-9 purely for size reasons, as this already results in quite a large average encoded string.
