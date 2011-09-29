#include "stdafx.h"
#include "crclib.h"
#include <pshpack1.h>
struct EthHdr
{
	unsigned char dstAddr[6] ;
	unsigned char srcAddr[6] ;
	unsigned short ethType ;
} ;
#include <poppack.h>
unsigned char szBuf[256] ;
unsigned char pArpReq1[] = {
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x1a, 0x4d, 0x4a, 0x26, 0xb8, 0x08, 0x06, 0x00, 0x01,  
0x08, 0x00, 0x06, 0x04, 0x00, 0x01, 0x00, 0x1a, 0x4d, 0x4a, 0x26, 0xb8, 0x6a, 0x6d, 0x09, 0x64,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6a, 0x6d, 0x08, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
} ;

unsigned char pEthPack1[] = {
	0x00, 0x10, 0xA4, 0x7B, 0xEA, 0x80, 0x00, 0x12, 0x34, 0x56, 0x78, 0x90, 0x08, 0x00, 0x45, 0x00, 0x00, 0x2E, 0xB3, 0xFE, 0x00, 0x00, 0x80, 0x11,
	0x05, 0x40, 0xC0, 0xA8, 0x00, 0x2C, 0xC0, 0xA8, 0x00, 0x04, 0x04, 0x00, 0x04, 0x00, 0x00, 0x1A, 0x2D, 0xE8, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
	0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11,
	//0x00, 0x00, 0x00, 0x00
	//0xF8, 0x67, 0xF6, 0xA9 //F867F6A9 
	//0xE6, 0xC5, 0x3D, 0xB2
} ;
unsigned long crc32(unsigned char *buf, int len) ;

void dump(unsigned char *buf, int len)
{
	FILE* f = fopen("packet.vhd","wt") ;
	if (f)
	{
		// type frame_type is array (0 to 7) of std_logic_vector(7 downto 0) ;
		// signal eth_frame: frame_type := ( x"00", x"00", x"00") ;
		fprintf(f,"type frame_type is array (0 to %1d) of std_logic_vector(7 downto 0) ;\n",len-1) ;
		fprintf(f,"signal eth_frame: frame_type := (\n") ;
		for (int i=0;i<len;i++)
		{
			if (i==(len-1))
			{
				fprintf(f,"x\"%02x\"",buf[i]) ;
			}
			else
			{
				fprintf(f,"x\"%02x\",",buf[i]) ;
			}
			if (i<22)
			{
				if (i==6 || i==7 || i==13 || i==19 || i==21) //((i-1)%16)==0
				{
					fprintf(f,"\n") ;
				}
			}
			else if (i<len-5)
			{
				if (((i-21)%8)==0) //((i-1)%16)==0
				{
					fprintf(f,"\n") ;
				}
			}
			else if (i==len-5)
			{
				fprintf(f,"\n") ;
			}
		}
		fprintf(f,") ;\n") ;
		fclose(f) ;
	}
}

int _tmain(int argc, _TCHAR* argv[])
{
	unsigned int mem_crc32 = 0 ;
	// build eth frame
	/*
	printf("EthPack1 size is: %d bytes.\n", sizeof(pEthPack1)) ;
	r = ComputeCrc(pEthPack1,8*sizeof(pEthPack1),0x04c11db7,32,0xffffffff,0xffffffff,0,0,0,1) ;
	printf("CRC32 is 0x%08X\n", r ) ;
	r = crc32(pEthPack1,sizeof(pEthPack1)) ;
	printf("CRC32 is 0x%08X\n", r ) ;
	dump(pEthPack1,sizeof(pEthPack1)) ;
	*/
	szBuf[0] = 0x55 ;
	szBuf[1] = 0x55 ;
	szBuf[2] = 0x55 ;
	szBuf[3] = 0x55 ;
	szBuf[4] = 0x55 ;
	szBuf[5] = 0x55 ;
	szBuf[6] = 0x55 ;
	szBuf[7] = 0xd5 ;
	memcpy(szBuf+8,pEthPack1,sizeof(pEthPack1)) ;
	mem_crc32 = crc32(pEthPack1,sizeof(pEthPack1)) ;
	unsigned char* p_crc32 = (unsigned char*) &mem_crc32 ;
	szBuf[8+sizeof(pEthPack1)+0] = p_crc32[3] ;
	szBuf[8+sizeof(pEthPack1)+1] = p_crc32[2] ;
	szBuf[8+sizeof(pEthPack1)+2] = p_crc32[1] ;
	szBuf[8+sizeof(pEthPack1)+3] = p_crc32[0] ;
	dump(szBuf,8+sizeof(pEthPack1)+4) ;

	return (0) ;
}

