# Adler-32

The Adler-32 checksum is obtained by first calculating 2 16 bit checksums A and B, and concatenating their bits into a 32 bit integer. At the beginnning of an Adler-32 run, A is initialized to 1 while B is initialized to 0. The sums are done modulo 65521.

Adler32(D) = B * 65536 + A

D is the string of bytes for which the checksum is to be calculated.
