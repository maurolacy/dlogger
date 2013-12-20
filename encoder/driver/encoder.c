#include <stdio.h>

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

/* forward declaration */

void encoderPulse(int gpio, int lev, uint32_t tick);

int main(int argc, char * argv[])
{
   int pos=0;

   if (gpioInitialise()<0) return 1;

   gpioSetMode(ENCODER_A, PI_INPUT);
   gpioSetMode(ENCODER_B, PI_INPUT);

   /* pull up is needed as encoder common is grounded */

   gpioSetPullUpDown(ENCODER_A, PI_PUD_UP);
   gpioSetPullUpDown(ENCODER_B, PI_PUD_UP);

   encoderPos = pos;

   /* monitor encoder level changes */

   gpioSetAlertFunc(ENCODER_A, encoderPulse);
   gpioSetAlertFunc(ENCODER_B, encoderPulse);

   while (1)
   {
      if (pos != encoderPos)
      {
         pos = encoderPos;
         printf("%d\n", pos);
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
