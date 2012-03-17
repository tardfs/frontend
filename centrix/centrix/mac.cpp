#include "StdAfx.h"
#include "mac.h"

unsigned char ethaddr_dst[] = {0xff,0xff,0xff,0xff,0xff,0xff} ;
unsigned char ethaddr_src[] = {0x00,0x24,0x54,0xcc,0xf8,0xae} ;
word32 ipaddr_dst = 0x0b01a8c0 ;
word32 ipaddr_src = 0x0a01a8c0 ;

word16 mac_htons(word16 data16)
{
	return ( ((data16&0xff)<<8) | ((data16>>8)&0xff)) ;
}

int make_udp_frame(byte8* pBuf,byte8* pdata, int data_size)
{
	memset(pBuf,0x55,7) ;
	pBuf[7] = 0xd5 ;
	memcpy(pBuf+8, ethaddr_dst, 6 ) ;
	memcpy(pBuf+14, ethaddr_src, 6 ) ;
	pBuf[20] = 0x08 ;
	pBuf[21] = 0x00 ;
	ipv4* ip = (ipv4*) (pBuf + 22) ;
	ip->tos = 0x0045 ;
	ip->len = mac_htons( sizeof(ipv4)+sizeof(udp)+data_size ) ;
	ip->id = mac_htons(1065) ;
	ip->offset = 0 ;
	ip->ttl = 128 ;
	ip->proto = 17 ; /* UDP */
	ip->dst_ip = ipaddr_dst ;
	ip->src_ip = ipaddr_src ;
	ip->crc16 = 0 ;
	ip->crc16 = ipcsum((word16*)ip,sizeof(ipv4)/sizeof(word16)) ;
	udp* pudp = (udp*) (ip+1) ;
	pudp->dst_port = mac_htons(1025) ;
	pudp->src_port = mac_htons(1025) ;
	pudp->len = mac_htons(sizeof(udp) + data_size) ;
	pudp->crc16 = 0x0000 ;
	memcpy(pudp+1,pdata,data_size) ;
	int frame_payload = 14+sizeof(ipv4)+sizeof(udp)+data_size ;
	word32 crc32 = crc802(pBuf+8, frame_payload ) ;
	pBuf[8+frame_payload+0] = (byte8) crc32&0xff ;
	pBuf[8+frame_payload+1] = (byte8) (crc32>>8)&0xff ;
	pBuf[8+frame_payload+2] = (byte8) (crc32>>16)&0xff ;
	pBuf[8+frame_payload+3] = (byte8) (crc32>>24)&0xff ;
	return (8+frame_payload+4) ;
}

unsigned int ethcrc_table[] =
{
0x4DBDF21C, 0x500AE278, 0x76D3D2D4, 0x6B64C2B0,
0x3B61B38C, 0x26D6A3E8, 0x000F9344, 0x1DB88320,
0xA005713C, 0xBDB26158, 0x9B6B51F4, 0x86DC4190,
0xD6D930AC, 0xCB6E20C8, 0xEDB71064, 0xF0000000
};

unsigned int crc802(unsigned char *data, int len)
{
	unsigned int n, crc=0 ;
	for (n=0; n<len; n++)
	{
		crc = (crc >> 4) ^ ethcrc_table[(crc ^ (data[n] >> 0)) & 0x0F];  /*lower nibble */
		crc = (crc >> 4) ^ ethcrc_table[(crc ^ (data[n] >> 4)) & 0x0F];  /*upper nibble */
	}
	return (crc) ;
}

unsigned short ipcsum(unsigned short *buf, int nwords)
{
	unsigned long sum;
	for(sum=0; nwords>0; nwords--)
	{
		sum += *buf++ ;
	}
	sum = (sum >> 16) + (sum &0xffff) ;
	sum += (sum >> 16) ;
	return ((unsigned short)(~sum)) ;
}

void dump_to_file(FILE* f, byte8* pBuf, int len)
{
	for (int n=0;n<len;n++)
	{
		fprintf(f,"x\"%02x\",",pBuf[n]) ;
		printf("x\"%02x\",",pBuf[n]) ;
		if ((n+1)%16==0)
		{
			fprintf(f,"\n") ;
			printf("\n") ;
		}
	}
}
