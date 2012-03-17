// udpdump.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"

SOCKET  s ;
unsigned char rxBuf[2048] ;

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
		sockaddr_in peer ;
		int peerlen ;
		if (recvfrom(s, (char*)rxBuf, 100, 0, (sockaddr*)&peer, &peerlen)<0)
		{ 
			printf("error recvfrom()\n") ;
		}
		dump_bytes(rxBuf,100) ;
	}

    closesocket(s) ;
	WSACleanup() ;
	return (0) ;
}

void dump_bytes(unsigned char* pBuf, int len)
{
	for (int n=0;n<len;n++)
	{
		printf("x\"%02x\",",pBuf[n]) ;
		if ((n+1)%16==0)
		{
			printf("\n") ;
		}
	}
}


/*
	DWORD dwThreadId = 0 ;
    HANDLE hThread = CreateThread(NULL,0,CompletionRoutine,NULL,0,&dwThreadId) ;

int exit_req = 0 ;
DWORD WINAPI CompletionRoutine(LPVOID) ;
DWORD WINAPI CompletionRoutine(LPVOID Context)
HANDLE  hCompletionEvent ;
	hCompletionEvent = WSACreateEvent() ;
	WSAEventSelect(s,hCompletionEvent, FD_READ|FD_WRITE|FD_CLOSE ) ; 
{
	printf("start completion thread\n") ;
	while(!exit_req)
	{
        WSAWaitForMultipleEvents(
            1,
            &hCompletionEvent,
            FALSE,
            WSA_INFINITE,
            TRUE
            ) ;
		if (exit_req)
		{
			break ;
		}
		while (true)
		{
			WSANETWORKEVENTS ne ;
			WSAEnumNetworkEvents ( s, hCompletionEvent, &ne ) ;
			if (ne.lNetworkEvents==0)
			{
				// no more events
				break ;
			}
			if (ne.lNetworkEvents&FD_READ)
			{
                    int ret = 0 ;
                    while((ret=recv(s,(char*)rxBuf,2048,0))
                        ==SOCKET_ERROR)
                    {
                        if (WSAGetLastError()==WSAEMSGSIZE)
                        {
                            OnReceiveData(rxBuf,2048) ;
                        }
                        else
                        {
                            break ;
                        }
                    }
                    if (ret>0)
                    {
                        OnReceiveData(rxBuf,ret) ;
                    }
			}
		}
	}
}
*/