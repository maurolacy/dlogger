#include <stdlib.h>
#include <stdio.h>

#include "rotaryencoder.h"

#define GPIO_A   22
#define GPIO_B   10

int main()
{

    if (wiringPiSetupGpio() < 0)
        exit(1); 

    struct encoder *encoder = setupencoder(GPIO_A, GPIO_B);

    for(; ;)
    {
        printf("%d\n", encoder->value>>2);
        usleep(1000000);
    }
}
