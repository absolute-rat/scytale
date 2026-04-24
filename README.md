# scytale

scytale is a low-entropy/lightweight stream encoder, implemented in pure x64 assembly.

## Pros

- Small footprint (154 bytes for both, and just 60 bytes for the decoder)
- Maintans a low entropy score (around ~4.0) no matter what data is being encoded
- Avoids predictable byte-distance pattern recognition

## Cons

- Overhead causes roughly a 6x size increase for any encoded data
- Linear decoding process


# Stream Architecture

The stream is comprised of two segments, a simple evasion header, and the repeating payload byte stream. The header is simply 2 random ASCII hex values, to avoid static detection/pattern recognition. The skip byte is a single byte, represented as a number between 1-9. This value determines the length of junk padding bytes that will follow the skip byte. Each padding byte is a random hex ASCII value (0-9,A-F). After the garbage padding, our associated payload byte will be represented by the actual little-endian 2 byte hex value, in ASCII (0x41 = 14). The stream repeats the skip byte/padding/payload byte for each byte in the real payload, and ends with a null terminator. 

The structure of a 2 byte payload with this method is shown here:

```
+--+-+-----+--+-+-----+--+--+
|AA|B|C...C|DD|B|C...C|DD|00|
+--+-+-----+--+-+-----+--+--+

A = HEADER
B = SKIP BYTE
C = PADDING
D = PAYLOAD BYTE
```


## Example

This is 'ABC' encoded in scytale:

2F3BBC14739DFBB1241E34

2F is our garbage header. 3 indicates 3 garbage characters (BBC) to skip. '14' is our 0x41. 9 is our next part of the stream, indicating 7 garbage characters (39DFBB1) to skip. '24' is our 0x42. 1 indicates a single garbage character (E) to skip, so '34' is our final byte, 0x43.


## Notes

The method could be altered rather trivially to include some basic new rules, without strongly impacting the general flow structure, which might make it easy enough to evade signatures. A key-based implementation would also be relatively easy to implement, if you didn't like leaving the full data in an accessible state for an analyst to access. You could create a new encoder to bias to lower skip byte values, if you really needed to fit a payload in a smaller space, but this will come at the cost of obfuscation. The absolute bare minimum you could get would be a 3x payload increase, which would lead to predictable payload byte-distance.

The skip byte is currently 0-7 just because it uses very few instructions, but I believe it should be sufficient. Any attempt to raise this to match the full range of hex values would require more size in the encoder itself, and a *significant* tax on payload size.
