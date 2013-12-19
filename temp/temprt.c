/*
 * accel.c - simple client to print accelerometer values
 *
 * Copyright 2010,2011   mauro@lacy.com.ar (Mauro Lacy)
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 ********/

/*
 * This client is meant to be used both interactively to check
 * that the accelerometer is working, and as a background process to convert accelerometer values
 * to textual strings.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <unistd.h>
#include <termios.h>
#include <errno.h>
#include <execinfo.h>

#include <pthread.h>
#include <time.h>
#include <math.h>

#include <rtdm/rtserial.h>

int init_serial();

inline int getSignal(int fd, unsigned int signal);
inline int getSignals(int fd);

inline int DTR(int, int);
int RTS(int, int);

float tension(int us);

void warn_upon_switch(int sig __attribute__((unused)));

float zero;
int w, x, y, z;

#define PRG_NAME "accelrt"
#define PRG_DATE "2011-01-02"

#define CTS 0
#define DCD 1
#define DSR 2
#define RI  3

#define SEC2NS   (1000000000) /* number of nanosecs per sec. */
#define SEC2US   (1000000) /* number of microsecs per sec. */
#define DELAY    (100000000) /* number of nanosecs between reads. */

const float Neg = 8.2;
const float Pos = 8.2;
 
char *prgname;

int accel_handler()
{
	int c[4];
//	double t;
//  struct timespec ts;

	c[0]=w;
	c[1]=x;
	c[2]=y;
	c[3]=z;

//	clock_gettime(CLOCK_REALTIME, &ts);
//	t=ts.tv_nsec/(float)SEC2NS;

  //printf("%d %d %d %d\n", c[0], c[1], c[2], c[3]);
  printf("%.2f %.2f %.2f %.2f\n", tension(c[0]), tension(c[1]), tension(c[2]), tension(c[3]));

  return 0;
}

#include <sys/mman.h>

#define PRIORITY (49) /* we use 49 as the PRREMPT_RT use 50
                            as the priority of kernel tasklets
                            and interrupt handler by default */

#define MAX_SAFE_STACK (8*1024) /* The maximum stack size which is
                                   guranteed safe to access without
                                   faulting */


void stack_prefault(void) {
        unsigned char dummy[MAX_SAFE_STACK];

        memset(&dummy, 0, MAX_SAFE_STACK);
        return;
}


unsigned int inline readCoord(int fd, unsigned int coord) {
  unsigned int v=0;
  struct timespec ts, tr;

  DTR(fd, 1);
  clock_gettime(CLOCK_REALTIME, &ts);

  while ( getSignal(fd, coord) == 1 && v < 50000 ) {
    clock_gettime(CLOCK_REALTIME, &tr);
    v=(tr.tv_sec-ts.tv_sec)*SEC2US+(tr.tv_nsec-ts.tv_nsec)/1000;
  }
  DTR(fd, 0);
  return v;
}

inline void readCoords(int fd, unsigned int *c) {

  unsigned int v=0, i, s;
  struct timespec ts, tr;

  DTR(fd, 1);
  clock_gettime(CLOCK_REALTIME, &ts);

  while ( ( s=getSignals(fd) ) > 0 && v < 50000 ) {
    clock_gettime(CLOCK_REALTIME, &tr);
    v=(tr.tv_sec-ts.tv_sec)*SEC2US+(tr.tv_nsec-ts.tv_nsec)/1000;
		for(i=CTS; i <= RI; i++)
			if ( (s & (1 << i)) )
				*(c+i)=v;
  }
  DTR(fd, 0);
}


/*
  procedure Ptzero;
  begin
  delay (500);
  zero := -(compteur(1)/ln(1-Neg/(Pos+Neg)));
  Delay (500);
  end;
*/
float ptzero(int fd) {
  float zz;
  struct timespec tr;
  tr.tv_sec=0;
  tr.tv_nsec=500000000;
  clock_nanosleep(CLOCK_REALTIME, 0, &tr, NULL);

  zz=-(readCoord(fd, 0)/logf(1-Neg/(Pos+Neg)));

  clock_nanosleep(CLOCK_REALTIME, 0, &tr, NULL);

  return zz;
}

/*
function Tension(Voie:Integer):Real;
var u:Real;
begin
  U := (neg+Pos)*(1-exp(-compteur(Voie)/zero))-Neg;
  Tension := Round(U*100)/100;
  delay (150);
end;
*/

float tension(int us) {
  float voltage;
  voltage = (Neg+Pos)*(1.0-expf(-us/zero))-Neg;
  return voltage;
}

void *read_accel(void *arg)
{
  int fd;
  struct timespec tr;
  char buf[1];
	unsigned int coords[4];

  struct sched_param param;

  fd=init_serial();

  // RT
  param.sched_priority = PRIORITY;
  if(sched_setscheduler(0, SCHED_FIFO, &param) == -1) {
    perror("sched_setscheduler failed");
    exit(-1);
  }

  /* Pre-fault our stack */
  stack_prefault();

  /* set initial status */
  DTR(fd, 0);
  //RTS (fd, 1);
  buf[0]= '\0';
//  if (write(fd, buf, 1) != 1 ) {
	if (rt_dev_write(fd, buf, 1) != 1) {
    perror("write failed");
    exit(-2);
  }

  /* get zero */
  zero=ptzero(fd);
  //printf("zero: %f\n", zero);

	/* Set context switch warning mode */
	//pthread_set_mode_np(0, PTHREAD_WARNSW);
	//printf("WARN\n");

	tr.tv_sec=0;
	tr.tv_nsec=DELAY;

  while (1)
  {
		clock_nanosleep(CLOCK_REALTIME, 0, &tr, NULL);

		readCoords(fd, &coords[0]);

/*
	#define CTS 0, w
	#define DCD 1, y
	#define DSR 2, z
	#define RI  3, x
*/
		w=coords[CTS];
		x=coords[RI];
		y=coords[DCD];
		z=coords[DSR];

	}	
  close(fd);                    /* close the device file */
  return(NULL);
}


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

#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

unsigned int mask[] = {
//  TIOCM_CTS,
//	RTSER_MSR_DCTS,
	RTSER_MSR_CTS,
//  TIOCM_CAR,
//	RTSER_MSR_DDCD,
	RTSER_MSR_DCD,
//  TIOCM_DSR,
//	RTSER_MSR_DDSR,
	RTSER_MSR_DSR,
//  TIOCM_RNG
//	RTSER_MSR_TERI
	RTSER_MSR_RI
};

inline int getSignal(int fd, unsigned int signal)
{
  //int status;
	rtser_status_t status;

/* get the serial port's status */
  //ioctl(fd, TIOCMGET, &status);
	rt_dev_ioctl(fd, RTSER_RTIOC_GET_STATUS, &status);

  return ( status.modem_status & mask[signal] ) ? 0 : 1;
}

/*
	#define CTS 0, w
	#define DCD 1, y
	#define DSR 2, z
	#define RI  3, x
*/

inline int getSignals(int fd)
{
  //int status, i, ret=0;
  int i, ret=0;
	rtser_status_t status;

/* get the serial port's status */
  //ioctl(fd, TIOCMGET, &status);
	rt_dev_ioctl(fd, RTSER_RTIOC_GET_STATUS, &status);
	//printf("status: %d\n", status.modem_status);

	for(i=CTS; i <= RI; i++)
		ret = ret +( ( status.modem_status & mask[i] ) ? 0 : (1 << i) );

	//printf("ret: %d\n", ret);
	return ret;
}


/*
 * The original location of this source is
 * http://www.embeddedlinuxinterfacing.com/chapters/06/setSerialSignal.c
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
/* setSerialSignal
 * setSerialSignal sets the DTR and RTS serial port control signals.
 * This program queries the serial port status then sets or clears
 * the DTR or RTS bits based on user supplied command line setting.
 *
 * setSerialSignal clears the HUPCL bit. With the HUPCL bit set,
 * when you close the serial port, the Linux serial port driver
 * will drop DTR (assertion level 1, negative RS-232 voltage). By
 * clearing the HUPCL bit, the serial port driver leaves the
 * assertion level of DTR alone when the port is closed.
 */

#include <sys/ioctl.h>
#include <fcntl.h>
#include <termios.h>
#include <stdio.h>
#include <stdlib.h>

/* we need a termios structure to clear the HUPCL bit */
struct termios tio;

/* TODO: pass as parameter */
#define SERIAL_PORT "rtser0"

int init_serial()
{
  int fd;

  //if ((fd = open(SERIAL_PORT,O_RDWR)) < 0)
	if ((fd = rt_dev_open(SERIAL_PORT, 0)) < 0)
  {
    printf("Couldn't open %s\n",SERIAL_PORT);
    exit(1);
  }
  tcgetattr(fd, &tio);          /* get the termio information */
  tio.c_cflag &= ~HUPCL;        /* clear the HUPCL bit */
  tcsetattr(fd, TCSANOW, &tio); /* set the termio information */

  return (fd);
}

inline int DTR(int fd, int value)
{
  int status, err;

  //ioctl(fd, TIOCMGET, &status); /* get the serial port status */
	err = rt_dev_ioctl(fd, RTSER_RTIOC_GET_CONTROL, &status);
	
	if (err < 0) {
    perror("rt_dev_ioctl failed");
		return err;
	}

  if ( value )      /* set the DTR line */
		status &= ~RTSER_MCR_DTR;
  else
    status |= RTSER_MCR_DTR;


  //return ioctl(fd, TIOCMSET, &status); /* set the serial port status */
  return rt_dev_ioctl(fd, RTSER_RTIOC_SET_CONTROL, status); /* set the serial port status */
}

int RTS(int fd, int value)
{
  int status, err;
  //ioctl(fd, TIOCMGET, &status); /* get the serial port status */
	err = rt_dev_ioctl(fd, RTSER_RTIOC_GET_CONTROL, &status);
	if (err <0) {
    perror("rt_dev_ioctl failed");
		return err;
	}

  if ( value )      /* set the RTS line */
		status &= ~RTSER_MCR_RTS;
  else
		status |= RTSER_MCR_RTS;

  //return ioctl(fd, TIOCMSET, &status); /* set the serial port status */
  return rt_dev_ioctl(fd, RTSER_RTIOC_SET_CONTROL, status); /* set the serial port status */
}

/*===================================================================*/
int usage(void)
{
   printf( "(" PRG_NAME ") , " PRG_DATE "\n" "Usage: %s\n",prgname);

   return 1;
}

  
int main(int argc, char **argv)
{
  pthread_t tid;
  int ret;

  prgname=argv[0];

  struct sched_param param;

  // Lock memory
  if(mlockall(MCL_CURRENT|MCL_FUTURE) == -1) {
    perror("mlockall failed");
    exit(-2);
  }
	//printf("after mlockall\n");
	
	/* Install SIGXCPU handler */
  signal(SIGXCPU, warn_upon_switch);

//if ( (ret=__real_pthread_create(&tid, NULL, cntl_servo, NULL)) ) {
  if ( (ret=pthread_create(&tid, NULL, read_accel, NULL)) ) {
    perror("pthread_create failed.");
    exit(ret);
  }
  // Declare read_accel as a real time task
  // XENOMAI
  param.sched_priority = PRIORITY;
  if(pthread_setschedparam(tid, SCHED_FIFO, &param) == -1) {
    perror("pthread_setschedparam failed");
    exit(-1);
  }
  usleep(1000000);

  /* itz Sun Mar 22 09:51:33 PST 1998 needed in case the output is a pipe */
  setvbuf(stdout, 0, _IOLBF, 0);
  setvbuf(stdin, 0, _IOLBF, 0);

  while(1){  /* forever */
    usleep(DELAY/500);
    accel_handler();
  } /*while*/

  exit(0);
}

void warn_upon_switch(int sig __attribute__((unused)))
{
    void *bt[32];
    int nentries;

    // Dump a backtrace of the frame which caused the switch to secondary mode:
    nentries = backtrace(bt,sizeof(bt) / sizeof(bt[0]));
    backtrace_symbols_fd(bt,nentries,fileno(stderr));
}
