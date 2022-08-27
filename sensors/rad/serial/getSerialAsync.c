#include <termios.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/signal.h>
#include <sys/types.h>

//#define BAUDRATE B38400
#define BAUDRATE B57600
//#define BAUDRATE B115200
#define PORT "/dev/ttyUSB0"
#define _POSIX_SOURCE 1 /* POSIX compliant source */
#define FALSE 0
#define TRUE 1

volatile int STOP = FALSE;

void signal_handler_IO(int signal, siginfo_t *si, void *ctx);    /* definition of signal handler */
void signal_handler_INT(int status);
int wait_flag = TRUE;                  /* TRUE while no signal received */
struct termios oldtio;
int fd;

int main(int argc, char **argv)
{
  int opt, x=0, p=0, v=0, nsecs=60, nmins=0, res, i, restot=0, mintot=0, sec3=0, mins=0;
  time_t oldsecs, secs;
	struct tm t;
  struct termios newtio;
  struct sigaction saio;         /* definition of signal action */
  struct sigaction saint;
  char buf[255];
  struct timeval tv;

	while ((opt = getopt(argc, argv, "d:i:hpvx")) != -1) {
		switch (opt) {
 			case 'd':
        nsecs = atoi(optarg);
        break;
      case 'i':
        nmins = atoi(optarg);
        break;
      case 'x':
				x=1;
				break;
      case 'p':
				p=1;
				break;
      case 'v':
				v=1;
				break;
      case 'h':
      default: /* '?' */
		fprintf(stderr, "Usage: %s [-d nsecs] [-i nmins] [-p] [-v] [-x]\n", argv[0]);
		fprintf(stderr, "-d nsecs: number of seconds to collect (default 60)\n");
		fprintf(stderr, "-i nmins: rounded interval in minutes between samples\n");
		fprintf(stderr, "-h: this help\n");
		fprintf(stderr, "-p: print intermediate results(each 3 seconds)\n");
		fprintf(stderr, "-v: verbose output\n");
		fprintf(stderr, "-x: exit after collecting\n");
        exit(EXIT_FAILURE);
    }
  }

/* open the device to be non-blocking (read will return immediatly) */
  fd = open(PORT, O_RDWR | O_NOCTTY | O_NONBLOCK);
  if (fd < 0)
  {
      perror(PORT);
	  exit(-1);
  }

/* install the signal handler before making the device asynchronous */
  //saio.sa_handler = signal_handler_IO;
  saio.sa_sigaction = signal_handler_IO;
  //saio.sa_mask = 0;
  saio.sa_flags = SA_SIGINFO;
  saio.sa_restorer = NULL;

  sigaction(SIGIO, &saio, NULL);

  saint.sa_handler = signal_handler_INT;
  //saint.sa_mask = 0;
  saint.sa_flags = 0;
  saint.sa_restorer = NULL;
  sigaction(SIGINT|SIGTERM|SIGQUIT|SIGABRT, &saint, NULL);

/* Make the file descriptor asynchronous (the manual page says only
   O_APPEND and O_NONBLOCK, will work with F_SETFL...) */
	fcntl(fd, F_SETFL, FASYNC);

  tcgetattr(fd, &oldtio); /* save current port settings */
/* set new port settings for canonical input processing */
  //newtio.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD;
  //newtio.c_cflag = CRTSCTS | CREAD;
  //newtio.c_cflag = CREAD;
  newtio.c_cflag = BAUDRATE | CLOCAL | CREAD | CS7;
  //newtio.c_iflag = IGNPAR | ICRNL;
  newtio.c_iflag = IGNPAR;
  newtio.c_oflag = 0;
  //newtio.c_lflag = ICANON;
  newtio.c_lflag &= ~ICANON;
  //newtio.c_cc[VMIN] = 1;
  newtio.c_cc[VMIN] = 1;
  newtio.c_cc[VTIME] = 0;
  tcflush(fd, TCIFLUSH);
  tcsetattr(fd, TCSANOW, &newtio);

/* if nmins > 0, wait until a rounded number of minutes arrives */
	if (nmins > 0) {
		oldsecs=time(NULL);
		gmtime_r(&oldsecs, &t);
		// second to wait
		if (v)
			printf("%.2d:%.2d:%.2d\n", t.tm_hour, t.tm_min, t.tm_sec);
		oldsecs=((((t.tm_min+nmins) / nmins) * nmins)-t.tm_min)*60-t.tm_sec-1;
		if (v)
			printf("wait secs: %d\n", oldsecs+1);
		tcflush(fd, TCIFLUSH);
		while (oldsecs > 0 ) {
			if (oldsecs > 60) {
				sleep(60);
				oldsecs=oldsecs-60;
			} else {
				sleep(oldsecs);
				oldsecs=0;
			}
			tcflush(fd, TCIFLUSH);
		}
		oldsecs=time(NULL);
		gmtime_r(&oldsecs, &t);
		//printf("%.2d:%.2d:%.2d\n", t.tm_hour, t.tm_min, t.tm_sec);
		//printf("rounded mins: %d\n", t.tm_min+1);
		// now "busy" wait the last fraction of a second
		while ((secs=time(NULL)) && secs == oldsecs)
			usleep(1);
		// start registering pulses
		tcflush(fd, TCIFLUSH);
		oldsecs++;
	}
	secs=0;
	oldsecs=time(NULL);
	gmtime_r(&oldsecs, &t);
	if (v)
		printf("%.2d:%.2d:%.2d\n", t.tm_hour, t.tm_min, t.tm_sec);

/* now allow the process to receive SIGIO */
  fcntl(fd, F_SETOWN, getpid());
  while (STOP == FALSE)
  {
	  //usleep(100000);
	  usleep(1000);
  	gettimeofday(&tv, NULL);

    if (wait_flag == FALSE)
    {
      res = read(fd, buf, 255);
			buf[res]='\0';
			//for (i=0; i<res; i++)
			//	fprintf(stderr, "%.2X\n", buf[i]);
		  restot+=res;
        wait_flag = TRUE; // wait for new input
    }
	  if (tv.tv_sec >oldsecs+2) {
	  	if (p)
				printf("%d: %d\n", secs+=3, restot*nsecs/3);
			mintot+=restot;
			restot=0;
	  	oldsecs=tv.tv_sec;
			sec3++;
	  }
	  if (sec3*3 >= nsecs ) { // interval
			mins=mins+nsecs/60;
			if (p)
				printf("%dm: ", mins);
	  	printf("%d\n", mintot);
			if (x == TRUE)
				STOP=TRUE;
			else
				mintot=0;
			sec3=0;
	  }
  }
/* restore old port settings */
  tcsetattr(fd, TCSANOW, &oldtio);
	return 0;
}

/***************************************************************************
* signal handler. sets wait_flag to FALSE, to indicate above loop that     *
* characters have been received.                                           *
***************************************************************************/
void signal_handler_IO(int signal, siginfo_t *si, void *ctx)
{
//	printf("received signal: %d\n", signal);
//	printf("fd: %d\n", si->si_fd);
 	wait_flag = FALSE;
}

void signal_handler_INT(int status)
{
  printf("received signal: %d\n", status);

  // restore and close serial port
  tcsetattr(fd, TCSANOW, &oldtio);
  close(fd);
  exit(0);
}
