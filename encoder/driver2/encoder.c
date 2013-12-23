#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <strings.h>

#include <pthread.h>

#define PORT 16001
#define MAXLINE 128
#define LISTENQ 1

#include <wiringPi.h>
#include "rotaryencoder.h"

#define ENCODER_A   22
#define ENCODER_B   10

static volatile int pos;

void *read_encoder(void *);

int main(int argc, char *argv[])
{
    pthread_t tid;
    int ret;

    pos=0;

    if ( (ret=wiringPiSetupGpio()) < 0)
        exit(ret);

//    encoderPos = pos;

    // server stuff
    int listenfd, connfd;
    struct sockaddr_in servaddr;

    char buff[16];

    listenfd = socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(PORT);

    if ( (ret=pthread_create(&tid, NULL, read_encoder, NULL)) )
    {
        fprintf(stderr, "%s: Can't create thread. Error %d\n", argv[0], ret);
        exit(ret);
    }

    // simple sequential server
    bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

    listen(listenfd, LISTENQ);
    for (; ;)
    {
        connfd = accept(listenfd, NULL, NULL);

        snprintf(buff, sizeof(buff), "%d\n", pos);
        write(connfd, buff, strlen(buff));
        close(connfd);
    }
    return 0;
}

void *read_encoder(void *arg)
{
    struct encoder *encoder = setupencoder(ENCODER_A, ENCODER_B);
    for(; ;)
    {
//        printf("%ld\n", encoder->value>>2);
        pos = encoder->value >> 2;
        usleep(10000);
    }
}
