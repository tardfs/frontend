// udpdump.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"

SOCKET  s ;
unsigned char rxBuf[2048] ;
//WSAEMSGSIZE

void dump_bytes(unsigned char* pBuf, int len) ;
int _tmain(int argc, _TCHAR* argv[])
{
	WSADATA wsd ;
    printf("Start networking...\n") ;
    if ( WSAStartup( MAKEWORD(2,1), &wsd ) != 0 )
    {
        printf("error WSAStartup()\n" ) ;
        return (-1) ;
    }
	s = socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP) ;
	if (s==INVALID_SOCKET)
	{
		printf("error socket()\n") ;
		return (-1) ;
	}

	sockaddr_in local ;
    memset(&local,0,sizeof(sockaddr_in)) ;
    local.sin_family = AF_INET ;
    local.sin_port = htons(0xc000) ;
    local.sin_addr.S_un.S_addr = htonl(INADDR_ANY) ;
    if (bind(s,(sockaddr*)&local,sizeof(sockaddr_in))==SOCKET_ERROR)
    {
		printf("bind() error\n") ;
        return (-1) ;
    }

	while(!kbhit())
	{
		int ret = 0 ;
		sockaddr_in peer ;
		int peerlen = sizeof(sockaddr_in) ;
		if ((ret=recvfrom(s, (char*)rxBuf, 2048, 0, (sockaddr*)&peer, &peerlen))<0)
		{ 
			printf("error recvfrom(): %08d\n",WSAGetLastError()) ;
			break ;
		}
		printf("%d bytes received:\n", ret ) ;
		dump_bytes(rxBuf,ret) ;
	}

    closesocket(s) ;
	WSACleanup() ;
	return (0) ;
}

void dump_bytes(unsigned char* pBuf, int len)
{
	for (int n=0;n<len;n++)
	{
		printf("%02x ",pBuf[n]) ;
		if ((n+1)%16==0)
		{
			printf("\n") ;
		}
	}
	printf("\n") ;
}

