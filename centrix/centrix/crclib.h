// (C) Samsung R&B center, Moscow
#ifndef _CRCLIB_H_
#define _CRCLIB_H_
/*
    ComputeCrc() - Function computes CRC for any polynom not greater than 33th order.
	It uses direct division algorithm. Purpose of this function is computing 
	reference result.

	pData      - pointer to data bytes (it can be not aligned to 8 bit bound) ;
	nInputBits - number of input bits ;
	uPolynom   - polynom value ;
	nPolyBits  - size of polynom in bits (order of polynom - 1) ;
	uInitReg   - initial value for crc ;
	uXorWith   - XOR result with ;
	refIn      - reflect bits in each input byte ;
	refOut     - reflect bits in output crc word ;
	zeroAug    - use zero augment (tail padding with '0') ;
	shortAlg   - type of algorithm used (=1 for most cases).
*/
unsigned int ComputeCrc(unsigned char* pData, int nInputBits, unsigned int uPolynom, 
						int nPolyBits, unsigned int uInitReg, unsigned int uXorWith, 
						int refIn, int refOut, int zeroAug, int shortAlg ) ;

/*
	ComputeLookupTable16() - function computes 256 short values.

	uPolynom   - polynom value ;
	nPolyBits  - size of polynom in bits (order of polynom - 1) ;
	uInitReg   - initial value for crc ;
	uXorWith   - XOR result with ;
	refIn      - reflect bits in each input byte ;
	refOut     - reflect bits in output crc word ;
	zeroAug    - use zero augment (tail padding with '0') ;
	shortAlg   - type of algorithm used (=1 for most cases).
*/
void ComputeLookupTable16(unsigned short* table, unsigned int uPolynom, 
						int nPolyBits, unsigned int uInitReg, unsigned int uXorWith, 
						int refIn, int refOut, int zeroAug, int shortAlg) ;

void ComputeLookupTable32(unsigned int* table, unsigned int uPolynom, 
						int nPolyBits, unsigned int uInitReg, unsigned int uXorWith, 
						int refIn, int refOut, int zeroAug, int shortAlg) ;

unsigned short fast_crc16(unsigned short init_crc, unsigned char* bytes, int cbSize,unsigned short* table) ;
unsigned short fast_crc16_ref(unsigned short init_crc, unsigned char* bytes, int cbSize,unsigned short* table) ;
unsigned int fast_crc24(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table) ;
unsigned int fast_crc24_ref(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table) ;
unsigned int fast_crc32(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table) ;
unsigned int fast_crc32_ref(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table) ;

// utils:
void dump_words(unsigned short* pwords, int cbSize) ;
void dump_dwords(unsigned int* pwords, int cbSize) ;

#endif