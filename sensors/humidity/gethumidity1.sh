#!/bin/bash
#set -x

. /etc/dlogger.conf
LOG=$BASE/log/`basename $0 .sh`.log
ERR=$BASE/log/`basename $0 .sh`.err

DURATION=1 # seconds (Sampling duration. Defined by the reader interface)
INTERVAL=300 # seconds (Sampling interval. Defined by the reader interface)

#DRIVER="dht11"  # Kernel driver
#GPIO=4
#FORMAT=0
#DEV="/dev/$DRIVER"

USER_DRIVER="$SENSORS/humidity/userspace_driver/DHT11" # Userspace driver

# Configure kernel module and device
#insmod $SENSORS/humidity/kernel_driver/${DRIVER}.ko gpio_pin=$GPIO format=$FORMAT
#mknod $DEV c 80 0 
#sleep 1

[ -f "$LOG" ] && mv -f $LOG $LOG.bak
[ -f "$ERR" ] && mv -f $ERR $ERR.bak


R='OK'
while true
do
  L=$($USER_DRIVER)
  sleep 1
  [ "$L" = "." ] && continue
  H=`echo $L | cut -d\  -f5`
  H2=`echo $H | cut -d\. -f1`
  T=`echo $L | cut -d\  -f2`
  T2=`echo $T | cut -d\. -f1`
#  R=`echo $L | cut -d\  -f4`
#[ "$R" = "BAD" ] && continue
  [ $H2 -gt 100 ] && R="BAD"
#[ $T -gt 60 ] && R="BAD"

  D=`date '+%Y-%m-%d %H:%M:%S'`
  echo "$D $H $T $R" | tee -a $LOG

  mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`humidity\` (\`humidity\`, \`temperature\`, \`result\`, \`duration\`, \`interval\`) VALUES ('$H2', '$T2', '$R', '$DURATION', '$INTERVAL');
EOF
  sleep $INTERVAL
done 2>$ERR
