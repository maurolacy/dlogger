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
#include <sys/time.h>

/* These are the hash definitions */
#define DSR 'D'+'S'+'R'
#define CTS 'C'+'T'+'S'
#define DCD 'D'+'C'+'D'
#define RI  'R'+'I'

int main(int argc, char *argv[])
{
  int fd;
  int status, oldstatus=1, pulse=0, minpulse=0, secs, oldusecs, inisecs, min=0;
  unsigned int whichSignal;
  struct timeval tv;

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

/* compute which serial port signal the user asked for
 * using a simple adding hash function
 */
  whichSignal = argv[2][0]  + argv[2][1] +  argv[2][2];

  // wait for a change of second
  gettimeofday(&tv, NULL);
  inisecs=secs=tv.tv_sec;
  while (secs==tv.tv_sec) {
  	gettimeofday(&tv, NULL);
  }
  secs++;
  inisecs=secs;
  oldusecs=tv.tv_usec;
 
while(1) {
/* get the serial port's status */
  ioctl(fd, TIOCMGET, &status);

//	printf("full: %d\n", status);

/* Here we AND the status with a bitmask to get the signal's state
 * These ioctl bitmasks are defined in /usr/include/bits/ioctl-types.h*/
// switch (whichSignal) {
//    case  DSR:
      status=status&TIOCM_DSR ? 0 : 1;
//      break;
//  printf("\n");
	if (status && ! oldstatus ) // falling edge
		pulse++;
	
	gettimeofday(&tv, NULL);
	fprintf(stderr, "delta usecs: %d\n", tv.tv_usec-oldusecs);
	oldusecs=tv.tv_usec;

	if (secs<tv.tv_sec) { // a sec has passed
		printf("%d: %d\n", tv.tv_sec-inisecs, pulse);
		minpulse+=pulse;
		pulse=0;
		secs++;
		if (((secs-inisecs) % 60) == 0 ) { // a min has passed
			min++;
			printf("%dm: %d\n", min, minpulse);
			minpulse=0;
			inisecs+=60;
		}
	}

	oldstatus=status;
}

/* close the device file */
  close(fd);
}
