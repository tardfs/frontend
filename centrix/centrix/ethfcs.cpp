// http://www.faqs.org/faqs/compression-faq/part1/section-26.html
// http://www.soeberg.net/dev/VHDL/Ethernet%20FCS%20checker/Exercise%201-1.pdf

void init_crc32() ;
unsigned long crc32_table[256] = {0x00} ;
/* Initialized first time "crc32()" is called. If you prefer, you can
 * statically initialize it at compile time. [Another exercise.]
 */

unsigned long crc32(unsigned char *buf, int len)
{
        unsigned char *p;
        unsigned long  crc;

        if (!crc32_table[1])    /* if not already done, */
                init_crc32();   /* build table */
        crc = 0xffffffff;       /* preload shift register, per CRC-32 spec */
        for (p = buf; len > 0; ++p, --len)
                crc = (crc << 8) ^ crc32_table[(crc >> 24) ^ *p];
        return (~crc) ;            /* transmit complement, per CRC-32 spec */
}

/*
 * Build auxiliary table for parallel byte-at-a-time CRC-32.
 */
#define CRC32_POLY 0x04c11db7     /* AUTODIN II, Ethernet, & FDDI */

void init_crc32()
{
        int i, j;
        unsigned long c;

        for (i = 0; i < 256; ++i) {
                for (c = i << 24, j = 8; j > 0; --j)
                        c = c & 0x80000000 ? (c << 1) ^ CRC32_POLY : (c << 1);
                crc32_table[i] = c;
        }
}