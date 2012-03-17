#pragma once

#include <pshpack1.h>
typedef unsigned int word32 ;
typedef unsigned short word16 ;
typedef unsigned char byte8 ;
struct ipv4
{
	word16   tos ;
	word16   len ;
	word16   id ;
	word16   offset ;
	byte8    ttl ;
	byte8    proto ;
	word16   crc16 ;
	word32   dst_ip ;
	word32   src_ip ;
} ;
struct udp
{
	word16 src_port ;
	word16 dst_port ;
	word16 len ;
	word16 crc16 ;
} ;
#include <poppack.h>

int make_udp_frame(byte8* pBuf, byte8* pData, int size) ;
unsigned int crc802(unsigned char *data, int len) ;
unsigned short ipcsum(unsigned short *buf, int nwords) ;

void dump_to_file(FILE* f, byte8* pBuf, int len) ;
