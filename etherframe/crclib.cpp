// CRC library
// (C) Samsung R&B center, Moscow
#include "stdafx.h"
#include "crclib.h"

unsigned char ReflectByte(unsigned char in)
{
	unsigned char out = 0 ;
	for (int i=0;i<8;i++)
	{
		out |= ((in>>(7-i))&1)<<i ;
	}
	return (out);
}

unsigned int ReflectBits(unsigned int in,int bitNum)
{
	unsigned int out = 0 ;
	for (int i=0;i<bitNum;i++)
	{
		out |= ((in>>(bitNum-1-i))&1)<<i ;
	}
	return (out) ;
}

unsigned int ReflectDwordBytes(unsigned int in)
{
	unsigned int out = 0 ;
	out |= ReflectByte(((unsigned char)(in&0xff))) ;
	out |= ReflectByte(((unsigned char)((in>>8)&0xff)))<<8 ;
	out |= ReflectByte(((unsigned char)((in>>16)&0xff)))<<16 ;
	out |= ReflectByte(((unsigned char)((in>>24)&0xff)))<<24 ;
	return (out) ;
}

/*
    ComputeCrc() - Function computes CRC for any polynom not greater than 33th order.
	It uses direct division algorithm. Purpose of this function is computing 
	reference result.
*/
unsigned int ComputeCrc(unsigned char* pData, int nInputBits, unsigned int uPolynom, 
						int nPolyBits, unsigned int uInitReg, unsigned int uXorWith, 
						int refIn, int refOut, int zeroAug, int shortAlg )
{
	unsigned int uReg = uInitReg ;
	int nNumBit = 0 ;
	unsigned char shiftedBit = 0 ;
	while(nNumBit<nInputBits+nPolyBits*zeroAug)
	{
		unsigned char inpBit = 0 ;
		if (nNumBit<nInputBits)
		{
			if (refIn)
			{
				// LSB first
				inpBit = ((pData[nNumBit>>3])>>(nNumBit%8))&0x01 ;
			}
			else
			{
				// MSB first
				inpBit = ((pData[nNumBit>>3])>>(7-nNumBit%8))&0x01 ;
			}
		}
		if (shortAlg)
		{
			shiftedBit = ((uReg>>(nPolyBits-1))^inpBit)&1 ;
			uReg = (uReg<<1) ;
		}
		else
		{
			shiftedBit = (uReg>>(nPolyBits-1))&1 ;
			uReg = (uReg<<1)|inpBit ;
		}
		if (shiftedBit)
		{
			uReg = uReg ^ uPolynom ;
		}
		//printf("  >%08X\n",uReg) ;
		nNumBit++ ;
	}
	unsigned long mask = -1 ;
	if (nPolyBits<32)
	{
		mask = (1<<nPolyBits)-1 ;
	}
	unsigned int crc = (uReg^uXorWith)&mask ;
	if (refOut)
	{
		crc = ReflectBits(crc,nPolyBits) ;
	}
	return (crc) ;
}

void ComputeLookupTable16(unsigned short* table, unsigned int uPolynom, 
						int nPolyBits, unsigned int uInitReg, unsigned int uXorWith, 
						int refIn, int refOut, int zeroAug, int shortAlg)
{
	unsigned char bytev = 0 ;
	for (int i=0;i<256;i++)
	{
		bytev = (unsigned char)i ;
		table[i] = ComputeCrc( &bytev, 8, uPolynom, nPolyBits,
			uInitReg, uXorWith, refIn, refOut, zeroAug, shortAlg ) ;
	}
}

void ComputeLookupTable32(unsigned int* table, unsigned int uPolynom, 
						int nPolyBits, unsigned int uInitReg, unsigned int uXorWith, 
						int refIn, int refOut, int zeroAug, int shortAlg)
{
	unsigned char bytev = 0 ;
	for (int i=0;i<256;i++)
	{
		bytev = (unsigned char)i ;
		table[i] = ComputeCrc( &bytev, 8, uPolynom, nPolyBits,
			uInitReg, uXorWith, refIn, refOut, zeroAug, shortAlg ) ;
	}
}

unsigned short fast_crc16(unsigned short init_crc, unsigned char* bytes, int cbSize,unsigned short* table)
{
	unsigned short crc = init_crc ;
	for (int i=0;i<cbSize;i++) 
	{
		crc = (crc << 8) ^ table[((crc>>8)^ bytes[i]) & 0xff] ;
	}
	return (crc) ;
}

unsigned short fast_crc16_ref(unsigned short init_crc, unsigned char* bytes, int cbSize,unsigned short* table)
{
	unsigned short crc = init_crc ;
	for (int i=0;i<cbSize;i++) 
	{
		crc = (crc >> 8) ^ table[(crc ^ bytes[i]) & 0xff] ;
	}
	return (crc) ;
}

unsigned int fast_crc24(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table)
{
	unsigned int crc = init_crc ;
	for (int i=0;i<cbSize;i++) 
	{
		crc = (crc << 8) ^ table[((crc>>16) ^ bytes[i]) & 0xff] ;
	}
	return (crc&0xffffff) ;
}

unsigned int fast_crc24_ref(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table)
{
	unsigned int crc = init_crc ;
	for (int i=0;i<cbSize;i++) 
	{
		crc = (crc >> 8) ^ table[(crc ^ bytes[i]) & 0xff] ;
	}
	return (crc&0xffffff) ;
}

unsigned int fast_crc32(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table)
{
	unsigned int crc = init_crc ;
	for (int i=0;i<cbSize;i++) 
	{
		crc = (crc << 8) ^ table[((crc>>24) ^ bytes[i]) & 0xff] ;
	}
	return (crc) ;
}

unsigned int fast_crc32_ref(unsigned int init_crc, unsigned char* bytes, int cbSize,unsigned int* table)
{
	unsigned int crc = init_crc ;
	for (int i=0;i<cbSize;i++) 
	{
		crc = (crc >> 8) ^ table[(crc ^ bytes[i]) & 0xff] ;
	}
	return (crc) ;
}

void dump_words(unsigned short* pwords, int cbSize)
{
	for (int k=0;k<cbSize/2;k++)
	{
		if (k!=0 && k%8==0)
		{
			printf("\n") ;
		}
		printf("0x%04x, ",pwords[k]) ;
	}
	printf("\n") ;
}

void dump_dwords(unsigned int* pwords, int cbSize)
{
	for (int k=0;k<cbSize/4;k++)
	{
		if (k!=0 && k%8==0)
		{
			printf("\n") ;
		}
		printf("0x%08x, ",pwords[k]) ;
	}
	printf("\n") ;
}

