/*
    Temperature and Humidity Sensor (DHT11) With Raspberry Pi
    Author: Rahul Kar
    DHT11 is a 4 pin sensor which can measure temperatures ranging from 0-50°C
    & Relative Humidity ranging from 20-95%. 

    The sensor uses its own proprietary 1-wire protocol to communicate with
    Raspberry Pi and runs with 3.3V-5V.

    The timings must be precise and according to the datasheet of the sensor.

    Raspberry Pi initiates the data transmission process by pulling
    the data bus low for about 18ms, and keeps it HIGH for about 20-40μs
    before releasing it. Subsequently, the sensor responds to the Pi's
    data transfer request by pulling the data bus LOW for 80μs
    followed by 80μs of HIGH. At this point Pi is ready to receive data
    from the sensor.

    Data is sent in packets of 40 bits (5 bytes) via the data line
    with the MSB at the beginning.

    Data is transmitted in the following order:
        - Integer Part of Relative Humidity
        - Decimal Part of Relative Humidity
        - Integer Part of Temperature
        - Decimal Part of Temperature
        - Checksum.

    Checksum consists the last 8 bits of each part.
    Transmission of '0' & '1' is done by varying the width of the pulse.
    For transmitting '0' the data bus is held HIGH for 26-28μs,
    and 70μs for transmitting '1'.
    A delay of 50μs(LOW) is introduced before any new data bit is transmitted.
    After the transmission of last data-bit the data line is held LOW for 50μs
    and released.
*/ 

#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#define MAX_TIME 85
#define DHT11PIN 17

int dht11_val[5]={0,0,0,0,0};

void dht11_read_val()
{
  uint8_t lststate=HIGH;
  uint8_t counter=0;
  uint8_t j=0,i;
  float farenheit;
  for(i=0;i<5;i++)
     dht11_val[i]=0;
  pinMode(DHT11PIN,OUTPUT);
  digitalWrite(DHT11PIN,LOW);
  delay(18);
  digitalWrite(DHT11PIN,HIGH);
  delayMicroseconds(40);
  pinMode(DHT11PIN,INPUT);
  for(i=0;i<MAX_TIME;i++)
  {
    counter=0;
    while(digitalRead(DHT11PIN)==lststate){
      counter++;
      delayMicroseconds(1);
      if(counter==255)
        break;
    }
    lststate=digitalRead(DHT11PIN);
    if(counter==255)
       break;
    // top 3 transistions are ignored
    if((i>=4)&&(i%2==0)){
      dht11_val[j/8]<<=1;
      if(counter>16)
        dht11_val[j/8]|=1;
      j++;
    }
  }
  // verify cheksum and print the verified data
  if((j>=40)&&(dht11_val[4]==((dht11_val[0]+dht11_val[1]+dht11_val[2]+dht11_val[3])& 0xFF)))
  {
    farenheit=dht11_val[2]*9./5.+32;
    printf("Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",dht11_val[0],dht11_val[1],dht11_val[2],dht11_val[3],farenheit);
  }
  else
    printf("Invalid Data!!\n");
}

int main(void)
{
  printf("Interfacing Temperature and Humidity Sensor (DHT11) With Raspberry Pi\n");
  if(wiringPiSetup()==-1)
    exit(1);
  while(1)
  {
     dht11_read_val();
     delay(3000);
  }
  return 0;
}
