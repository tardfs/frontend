// centrix.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
unsigned long crc32(unsigned char *buf, int len) ;


int _tmain(int argc, _TCHAR* argv[])
{
	int k,n, rx_data, rx0, rx1, rx2, rx3, rx_valid ;
	char* szTmp = new char[1024] ;
	unsigned char * pBuf = new unsigned char[2048] ;
	FILE* f = fopen("stp1.csv", "rt") ;

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
							pBuf[k/2] = (rx_data << 4)&0xf0 ;
						}
						else
						{
							pBuf[k/2] |= (rx_data&0x0f) ;
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
	}
	delete szTmp ; szTmp = NULL ;
	f = fopen("frame.txt","w+t") ;
	int FrameSize = k/2 ;
	if (f)
	{
		for (n=0;n<FrameSize;n++)
		{
			fprintf(f,"x\"%02x\",",pBuf[n]) ;
			if ((n+1)%16==0)
			{
				fprintf(f,"\n") ;
			}
		}
		unsigned int crc = crc32(pBuf+8,FrameSize-8-4) ;
		fprintf(f,"\nframe_size: %4d, crc:%08x\n",FrameSize,~crc) ;
		fclose(f) ; f = NULL ;
	}
	delete pBuf ; pBuf = NULL ;
	return (0) ;
}

