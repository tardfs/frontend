// centrix.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "crclib.h"
unsigned long crc32(unsigned char *buf, int len) ;
unsigned int crc322(unsigned char *data, int len) ;

int _tmain(int argc, _TCHAR* argv[])
{
	int k,n, rx_data, rx0, rx1, rx2, rx3, rx_valid ;
	char* szTmp = new char[1024] ;
	unsigned char * pBuf = new unsigned char[2048] ;
	FILE* f = fopen("data\\stp2.csv", "rt") ;

	k = 0 ;
	if (f)
	{
		while (!feof(f))
		{
			if (fgets(szTmp,1023,f))
			{
				if (szTmp[0]!=';')
				{
					sscanf(szTmp,"%d,%x,%d,%d,%d,%d,%d",
						&n, &rx_data, &rx0, &rx1, &rx2, &rx3, &rx_valid ) ;
					if (rx_valid)
					{
						if (k%2==0)
						{
							pBuf[k/2] = (rx_data&0x0f) ;
						}
						else
						{
							pBuf[k/2] |= (rx_data << 4)&0xf0 ;
						}
						k++ ;
					}
				}
			}
		}
		fclose(f) ;
	}
	else
	{
		printf("can't open file\n") ;
		return (-1) ;
	}
	delete szTmp ; szTmp = NULL ;
	f = fopen("frame.txt","w+t") ;
	int FrameSize = k/2 ;
	if (f)
	{
		for (n=0;n<FrameSize;n++)
		{
			fprintf(f,"x\"%02x\",",pBuf[n]) ;
			printf("x\"%02x\",",pBuf[n]) ;
			if ((n+1)%16==0)
			{
				fprintf(f,"\n") ;
				printf("\n") ;
			}
		}
		unsigned int crc = crc322(pBuf+8,FrameSize-8-4) ;

		fprintf(f,"\nframe_size: %4d, crc: %08x\n",FrameSize,crc) ;
		fclose(f) ; f = NULL ;
		printf("\nframe_size: %4d\ncrc: %08x\n\n",FrameSize,crc) ;

		for (unsigned char c=0;c<16;c++)
		{
	    unsigned int crc2 = ComputeCrc(pBuf+8,FrameSize-8-4,
			                  0x04c11db7,32,0xffffffff,0x0,(c>>3)&0x01,(c>>2)&0x01,(c>>1)&0x01,c&1) ;
		printf("crc: %08x\n", crc2) ;
		}
	}
	delete pBuf ; pBuf = NULL ;
	return (0) ;
}

