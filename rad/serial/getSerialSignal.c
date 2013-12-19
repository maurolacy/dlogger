/*
 * getSerialSignal v0.1 9/13/01
 * www.embeddedlinuxinterfacing.com
 *
 * The original  location of this source is
 * http://www.embeddedlinuxinterfacing.com/chapters/06/getSerialSignal.c
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

/* getSerialSignal
 * getSerialSignal queries the serial port's UART and returns
 * the state of the input control lines. The program requires
 * two command line parameters: which port and the input control
 * line (one of the following: DSR, CTS, DCD, or RI).
 * ioctl is used to get the current status of the serial port's
 * control signals. A simple hash function converts the control
 * command line parameter into an integer.
 */

/*
gcc -o getSerialSignal getSerialSignal.c
*/
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

/* These are the hash definitions */
#define DSR 'D'+'S'+'R'
#define CTS 'C'+'T'+'S'
#define DCD 'D'+'C'+'D'
#define RI  'R'+'I'

int main(int argc, char *argv[])
{
  int fd;
  int status;
  unsigned int whichSignal;

  if (argc != 3)
    {
    printf("Usage: getSerialSignal /dev/ttyS0|/dev/ttyS1 DSR|CTS|DCD|RI \n");
    exit( 1 );
    }

/* open the serial port device file */
  if ((fd = open(argv[1],O_RDONLY)) < 0) {
    printf("Couldn't open %s\n",argv[1]);
    exit(1);
  }

/* get the serial port's status */
  ioctl(fd, TIOCMGET, &status);

//	printf("full: %d\n", status);
/* compute which serial port signal the user asked for
 * using a simple adding hash function
 */
  whichSignal = argv[2][0]  + argv[2][1] +  argv[2][2];

/* Here we AND the status with a bitmask to get the signal's state
 * These ioctl bitmasks are defined in /usr/include/bits/ioctl-types.h*/
  switch (whichSignal) {
    case  DSR:
      status&TIOCM_DSR ? printf("0"):printf("1");
      break;
    case  CTS:
      status&TIOCM_CTS ? printf("0"):printf("1");
      break;
    case  DCD:
      status&TIOCM_CAR ? printf("0"):printf("1");
      break;
    case  RI:
      status&TIOCM_RNG ? printf("0"):printf("1");
      break;
    default:
      printf("signal  %s unknown, use DSR, CTS, DCD or RI",argv[2]);
      break;
  }
  printf("\n");

/* close the device file */
  close(fd);
}
