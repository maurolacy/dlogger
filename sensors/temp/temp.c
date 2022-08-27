/*
 * temo.c - simple client to print temperature value
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
 * This client is meant to be used interactively to register temperature values
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

int init_serial();

inline int getSignal(int fd, unsigned int signal);

inline int DTR(int, int);
int RTS(int, int);

float temp(int us);

void warn_upon_switch(int sig __attribute__((unused)));

int t;

#define PRG_NAME "temp"
#define PRG_DATE "2011-02-06"

#define CTS 0
#define DCD 1
#define DSR 2
#define RI  3


const float Neg = 8.2;
const float Pos = 8.2;
 
char *prgname;

int temp_handler()
{
	int c;
	c=t;
  //printf("%dus\n", c);
  printf("%.1f\n", temp(c));
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

#define SEC2NS   (1000000000) /* number of nanosecs per sec. */
#define SEC2US   (1000000) /* number of microsecs per sec. */
#define DELAY    (0) /* number of nanosecs between reads. */
#define DELAYS   (2) /* number of seconds between reads. */

/* we need a termios structure to clear the HUPCL bit */
struct termios tio, oldtio;

unsigned int inline readValue(int fd, unsigned int s) {
  unsigned int v=0;
  struct timespec ts, tr, tn;
	
	tn.tv_sec=0;
	tn.tv_nsec=1;

  DTR(fd, 0);
  clock_gettime(CLOCK_REALTIME, &ts);

  while ( getSignal(fd, s) == 1 && v < 500000 ) {
		//usleep(1);
		clock_nanosleep(CLOCK_REALTIME, 0, &tn, NULL);
  }
  clock_gettime(CLOCK_REALTIME, &tr);
  v=(tr.tv_sec-ts.tv_sec)*SEC2US+(tr.tv_nsec-ts.tv_nsec)/1000;
  DTR(fd, 1);
  return v;
}

/*
 *
Private Sub Temp()
  DTR 1
  REALTIME (True)
  TIMEINITUS
  While (DSR() = 0) And (TIMEREADUS() < 1500000)
  Wend
  T = TIMEREADUS()
  T = T * 1.0000000001
  R = 2200 + 7800 * (T - 76300) / (294600 - 76300)
  REALTIME (False)
  R = Int(R)
  Temp = 1 / (Log(R / 10000) / 4300 + 1 / 298) - 273
  Temp = Int(Temp * 10) / 10
  Label1.Caption = Str$(Temp) + "°C"
  'Temp = 32 + (Temp / 100 * 180)
  'Temp = Int(Temp * 10) / 10
  'Label1.Caption = Str$(Temp) + " F"
  DTR 0
End Sub

*/
float temp(int us) {
  float temp;
	//int r;
  //printf("us: %d\n", us);
	//temp = 2200.0 + 7800.0 * ( (float)us - 76300.0) / (294600.0 - 76300.0);
  temp = 2400.0 + 7800.0 * ( (float)us - 76300.0) / (294600.0 - 76300.0);
	//r=temp;
  temp = 1.0 / (logf(temp / 10000.0) / 4300.0 + 1.0 / 298.0) - 273.0;
  //printf("temp: %f\n", temp);
  return temp;
}

void *read_temp(void *arg)
{
  int fd;
  struct timespec tr;
  char buf[1];
	unsigned int c;

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
  DTR(fd, 1);
  RTS (fd, 0);
  buf[0]= '\0';
  if (write(fd, buf, 1) != 1 ) {
    perror("write failed");
    exit(-2);
  }

	/* Set context switch warning mode */
	//pthread_set_mode_np(0, PTHREAD_WARNSW);

	tr.tv_sec=DELAYS;
	tr.tv_nsec=DELAY;

  while (1)
  {
		clock_nanosleep(CLOCK_REALTIME, 0, &tr, NULL);

		c=readValue(fd, DSR);
		t=c;

		//printf("temp: %dus\n", c);
	}	
  tcsetattr(fd, TCSANOW, &oldtio);
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
  TIOCM_CTS,
  TIOCM_CAR,
  TIOCM_DSR,
  TIOCM_RNG
};

inline int getSignal(int fd, unsigned int signal)
{
  int status;

/* get the serial port's status */
  ioctl(fd, TIOCMGET, &status);

  return ( status & mask[signal] ) ? 0 : 1;
}

/*
	#define CTS 0, w
	#define DCD 1, y
	#define DSR 2, z
	#define RI  3, x
*/

/*
 * setSerialSignal v0.1 9/13/01
 * www.embeddedlinuxinterfacing.com
 *
 *
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

/* TODO: pass as parameter */
#define SERIAL_PORT "/dev/ttyUSB0"
#define BAUDRATE B1200

int init_serial()
{
  int fd;

  if ((fd = open(SERIAL_PORT,O_RDWR)) < 0)
  {
    printf("Couldn't open %s\n", SERIAL_PORT);
    exit(1);
  }
  tcgetattr(fd, &oldtio); /* save current port settings */
  tcgetattr(fd, &tio);          /* get the termio information */
/* set new port settings for canonical input processing */
  //tio.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD;
  //tio.c_cflag = CRTSCTS | CREAD;
  //tio.c_cflag = CREAD;
  tio.c_cflag = BAUDRATE | CLOCAL | CREAD | CS8;
  tio.c_iflag = IGNPAR;
  //tio.c_oflag = 0;
  //tio.c_iflag = IGNPAR | ICRNL;
  tio.c_lflag = ICANON;
  //tio.c_lflag &= ~ICANON;
  //tio.c_cc[VMIN] = 1;
  //tio.c_cc[VMIN] = 1;
  //tio.c_cc[VTIME] = 0;
  tio.c_cflag &= ~HUPCL;        /* clear the HUPCL bit */
  tcflush(fd, TCIFLUSH);
  tcsetattr(fd, TCSANOW, &tio); /* set the termio information */

  return (fd);
}


inline int DTR(int fd, int value)
{
  int status;
  ioctl(fd, TIOCMGET, &status); /* get the serial port status */

  if ( value )      /* set the DTR line */
    status &= ~TIOCM_DTR;
  else
    status |= TIOCM_DTR;

  return ioctl(fd, TIOCMSET, &status); /* set the serial port status */
}

int RTS(int fd, int value)
{
  int status;
  ioctl(fd, TIOCMGET, &status); /* get the serial port status */
  if ( value )      /* set the RTS line */
    status &= ~TIOCM_RTS;
  else
    status |= TIOCM_RTS;

  return ioctl(fd, TIOCMSET, &status); /* set the serial port status */
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
	
	/* Install SIGXCPU handler */
  signal(SIGXCPU, warn_upon_switch);

  if ( (ret=pthread_create(&tid, NULL, read_temp, NULL)) ) {
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

//  while(1){  /* forever */
    usleep(DELAYS*SEC2US);
    temp_handler();
//  } /*while*/

//  tcsetattr(fd, TCSANOW, &oldtio);
// close(fd);                    /* close the device file */
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

/*
Private Sub Form_Load()
 i = OPENCOM("COM2,1200,N,8,1")
 If i = 0 Then
    i = OPENCOM("COM1,1200,N,8,1")
    Option1.Value = True
 End If
 If i = 0 Then MsgBox ("COM Interface Error")
 TXD 0
 RTS 0
 DTR 0
 Counter1 = 0
 Timer1.Interval = 2000
End Sub

Private Sub Timer1_Timer()
  DTR 1
  REALTIME (True)
  TIMEINITUS
  While (DSR() = 0) And (TIMEREADUS() < 1500000)
  Wend
  T = TIMEREADUS()
  T = T * 1.0000000001
  R = 2200 + 7800 * (T - 76300) / (294600 - 76300)
  REALTIME (False)
  R = Int(R)
  Temp = 1 / (Log(R / 10000) / 4300 + 1 / 298) - 273
  Temp = Int(Temp * 10) / 10
  Label1.Caption = Str$(Temp) + "°C"
  'Temp = 32 + (Temp / 100 * 180)
  'Temp = Int(Temp * 10) / 10
  'Label1.Caption = Str$(Temp) + " F"
  DTR 0
End Sub

*/
