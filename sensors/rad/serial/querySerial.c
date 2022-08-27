/*
 * querySerial v0.1 9/17/01
 * www.embeddedlinuxinterfacing.com
 *
 * The original  location of this source is
 * http://www.embeddedlinuxinterfacing.com/chapters/06/querySerial.c
 *
 *
 * Copyright (C) 2001 by Craig Hollabaugh
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

/* querySerial
 * querySerial provides bash scripts with serial communications. This
 * program sends a query out a serial port and waits a specific amount
 * of time then returns all the characters received. The command line
 * parameters allow the user to select the serial port, select the
 * baud rate, select the timeout and the serial command to send.
 * A simple hash function converts the baud rate
 * command line parameter into an integer.  */

/*
gcc -o querySerial querySerial.c
*/


#include <stdio.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <termios.h>
#include <stdlib.h>
#include <string.h>

/* These are the hash definitions */
#define USERBAUD1200 '1'+'2'
#define USERBAUD2400 '2'+'4'
#define USERBAUD9600 '9'+'6'
#define USERBAUD1920 '1'+'9'
#define USERBAUD3840 '3'+'8'

struct termios tio;

int main(int argc, char *argv[])
{
  int fd, status, whichBaud, result;
  long baud;
  char buffer[255];

  if (argc != 5)
  {
    printf("Usage: querySerial port speed timeout(mS) command\n");
    exit( 1 );
  }

/* compute which baud rate the user wants using a simple adding
 * hash function
 */
  whichBaud = argv[2][0] + argv[2][1];

  switch (whichBaud) {
    case USERBAUD1200:
      baud = B1200;
      break;
    case USERBAUD2400:
      baud = B2400;
      break;
    case USERBAUD9600:
      baud = B9600;
      break;
    case USERBAUD1920:
      baud = B19200;
      break;
    case USERBAUD3840:
      baud = B38400;
      break;
    default:
      printf("Baud rate %s is not supported, ", argv[2]);
      printf("use 1200, 2400, 9600, 19200 or 38400.\n", argv[2]);
      exit(1);
      break;
  }

/* open the serial port device file
 * O_NDELAY - tells port to operate and ignore the DCD line
 * O_NOCTTY - this process is not to become the controlling
 *            process for the port. The driver will not send
 *            this process signals due to keyboard aborts, etc.
 */
  if ((fd = open(argv[1],O_RDWR | O_NDELAY | O_NOCTTY)) < 0)
  {
    printf("Couldn't open %s\n",argv[1]);
    exit(1);
  }

/* we are not concerned about preserving the old serial port configuration
 * CS8, 8 data bits
 * CREAD, receiver enabled
 * CLOCAL, don't change the port's owner
 */
  tio.c_cflag = baud | CS8 | CREAD | CLOCAL;

  tio.c_cflag &= ~HUPCL; /* clear the HUPCL bit, close doesn't change DTR */

  tio.c_lflag = 0;       /* set input flag noncanonical, no processing */

  tio.c_iflag = IGNPAR;  /* ignore parity errors */

  tio.c_oflag = 0;       /* set output flag noncanonical, no processing */

  tio.c_cc[VTIME] = 0;   /* no time delay */
  tio.c_cc[VMIN]  = 0;   /* no char delay */

  tcflush(fd, TCIFLUSH); /* flush the buffer */
  tcsetattr(fd, TCSANOW, &tio); /* set the attributes */

/* Set up for no delay, ie nonblocking reads will occur.
   When we read, we'll get what's in the input buffer or nothing */
  fcntl(fd, F_SETFL, FNDELAY);

/* write the users command out the serial port */
  result = write(fd, argv[4], strlen(argv[4]));
  if (result < 0)
  {
    fputs("write failed\n", stderr);
    close(fd);
    exit(1);
  }

/* wait for awhile, based on the user's timeout value in mS*/
  usleep(atoi(argv[3]) * 1000);

/* read the input buffer and print it */
  result = read(fd,buffer,255);
  buffer[result] = 0; // zero terminate so printf works
  printf("%s\n",buffer);

/* close the device file */
  close(fd);
}
