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
#define LISTENQ	1

#include <pigpio.h>

/*
   Rotary encoder connections:

   Encoder A      - gpio 22 (pin P1-15)
   Encoder B      - gpio 10  (pin P1-19)
   Encoder Common - Pi ground (pin P1-20)
*/

#define ENCODER_A 22
#define ENCODER_B 10

static volatile int encoderPos;
static volatile int pos;

void *read_encoder(void *);
void encoderPulse(int gpio, int lev, uint32_t tick);

int main(int argc, char *argv[])
{
    pthread_t tid;
    int ret;

    pos=0;

    if ( (ret=gpioInitialise()) < 0)
        exit(ret);

    encoderPos = pos;

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
    gpioSetMode(ENCODER_A, PI_INPUT);
    gpioSetMode(ENCODER_B, PI_INPUT);

    /* pull up is needed as encoder common is grounded */
    gpioSetPullUpDown(ENCODER_A, PI_PUD_UP);
    gpioSetPullUpDown(ENCODER_B, PI_PUD_UP);

    /* monitor encoder level changes */
    gpioSetAlertFunc(ENCODER_A, encoderPulse);
    gpioSetAlertFunc(ENCODER_B, encoderPulse);

    for(; ;)
    {
        if (pos != encoderPos)
        {
            pos = encoderPos;
            printf("pos=%d\n", pos);
        }
        gpioDelay(10000); /* check pos 100 times per second */
    }
    gpioTerminate();
}

void encoderPulse(int gpio, int level, uint32_t tick)
{
    /*

             +---------+         +---------+      0
             |         |         |         |
   A         |         |         |         |
             |         |         |         |
   +---------+         +---------+         +----- 1

       +---------+         +---------+            0
       |         |         |         |
   B   |         |         |         |
       |         |         |         |
   ----+         +---------+         +---------+  1

     */

    static int levA=0, levB=0, lastGpio = -1;

    if (gpio == ENCODER_A) levA = level; else levB = level;

    if (gpio != lastGpio) /* debounce */
    {
        lastGpio = gpio;

        if ((gpio == ENCODER_A) && (level == 0))
        {
            if (!levB) ++encoderPos;
        }
        else if ((gpio == ENCODER_B) && (level == 1))
        {
            if (levA) --encoderPos;
        }
    }
}
