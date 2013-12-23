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

#define PORT 16001
#define MAXLINE 128
#define LISTENQ 1

#include <wiringPi.h>
#include "rotaryencoder.h"

#define ENCODER_A   22
#define ENCODER_B   10

int main(int argc, char *argv[])
{
    int ret;

    if ( (ret=wiringPiSetupGpio()) < 0)
        exit(ret);

    struct encoder *encoder = setupencoder(ENCODER_A, ENCODER_B);

    // server stuff
    int listenfd, connfd;
    struct sockaddr_in servaddr;

    char buff[16];

    listenfd = socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(PORT);

    // simple sequential server
    bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

    listen(listenfd, LISTENQ);
    for (; ;)
    {
        connfd = accept(listenfd, NULL, NULL);

        snprintf(buff, sizeof(buff), "%ld\n", encoder->value >> 2);
        write(connfd, buff, strlen(buff));
        close(connfd);
    }
    return 0;
}
