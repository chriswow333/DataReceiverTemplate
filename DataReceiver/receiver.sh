#!/bin/sh

# Data Receiver
#
# chkconfig: 2345 20 80
# Description: start/stop  Data Receiver
# 
RETVAL=0

NOW=$(date +"%Y/%m/%d %T")
DATE=$(date +"%Y%m%d")


APPLICATION_HOME=/workspace
PYTHON_HOME=/package/python
PYTHON=${PYTHON_HOME}/bin
WORKSPACE_HOME=${APPLICATION_HOME}/workspace/DataReceiver
MODULE_HOME=${APPLICATION_HOME}/modules/librdkafka/lib

RUNAS=chris
GROUP=chris

NAME=DataReceiver


PIDFILE=${WORKSPACE_HOME}/$NAME.pid
LOGFILE=${WORKSPACE_HOME}/$NAME.log
SCRIPT="${PYTHON}/python3.7 ${WORKSPACE_HOME}/receiver.py -f ${WORKSPACE_HOME}/config.yml"
MASTER_SCRIPT="$SCRIPT -s MASTER"
BACKUP_SCRIPT="$SCRIPT -s BACKUP"



KEEPALIVED_STATE_LOG=${APPLICATION_HOME}/log/keepalived_state_transit.${DATE}.log
PROCESS_STATE_LOG=${WORKSPACE_HOME}/datareceiver.notify

Start()
{
  if [ -f $PIDFILE ]; then
    ps cax | grep $(cat $PIDFILE) > /dev/null
    if [ $? -eq 0 ]; then
      echo "$NAME already running, Trying to stop.." >&2
      Stop
    else
      rm -f "$PIDFILE"
      echo "$NAME is not running, starting a new In Receiver..."
    fi
  fi

  

  echo "Starting  Data Receiver... " >&2
  case "$1" in
    "MASTER")
      echo "Entering MASTER mode ..." >&2
      local cmd="$MASTER_SCRIPT &> \"$LOGFILE\" & echo \$!"
      su -c "$cmd" $RUNAS > "$PIDFILE"
      chown ${RUNAS}:${GROUP} $PIDFILE

    ;;
    "BACKUP")
      echo "Entering BACKUP mode ..." >&2
      local cmd="$BACKUP_SCRIPT &> \"$LOGFILE\" & echo \$!"
      su -c "$cmd" $RUNAS > "$PIDFILE"
      chown ${RUNAS}:${GROUP} $PIDFILE

    ;;
    *)
    ;;
  esac
}

Stop()
{
  if [ ! -f "$PIDFILE" ]; then
    echo ' Data Receiver is not running.' >&2
  else
    echo 'Stopping  Data Receiver...' >&2
    kill $(cat "$PIDFILE") || rm -f "$PIDFILE"
    rm -f "$PIDFILE"
    echo ' Data Receiver is stopped.' >&2
  fi
}


case "$1" in
  start)
    Start "MASTER"
    echo "MASTER" > ${PROCESS_STATE_LOG}
    ;;
  stop)
    Stop
    ;;
  restart)
    Stop
    Start
    ;;
  transit)
    if [ -z "$2" ]; then
      state="MASTER"
    else
      state="$2"
    fi
    Stop
    echo "Date: ${NOW} | State: Stopping | Message: The ${NAME} is stopping before transit state." >> ${KEEPALIVED_STATE_LOG}
    wait
    Start $state
    echo "Date: ${NOW} | State: Stopping | Message: The ${NAME} state is ${state} now." >> ${KEEPALIVED_STATE_LOG}
    echo $state > ${PROCESS_STATE_LOG}
esac
exit $RETVAL