#!/bin/sh

# Data Keepalived

# chkconfig: 2345 20 80
# Description: start/stop Keepalived
# 
RETVAL=0

APPLICATION_HOME=/workspace

RUNAS=chris
WORKSPACE_HOME=${APPLICATION_HOME}/keepalived
NAME=Keepalived
PIDFILE=${WORKSPACE_HOME}/$NAME.pid
LOGFILE=${WORKSPACE_HOME}/$NAME.log
SCRIPT="${WORKSPACE_HOME}/sbin/keepalived -f ${WORKSPACE_HOME}/etc/keepalived/keepalived.conf"


start()
{
  if [ -f $PIDFILE ]; then
    ps cax | grep $(cat $PIDFILE) > /dev/null
    if [ $? -eq 0 ]; then
      echo "$NAME Processor already running" >&2
      return 1
    else
      rm -f "$PIDFILE"
      echo "Processor is not running, starting a new Unzip processor..."
    fi
  fi
  echo 'Starting processor...' >&2
  local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
  echo 'Processor started' >&2
}

stop()
{
  if [ ! -f "$PIDFILE" ]; then
    echo 'Processor is not running.'
    return 1
  fi
  echo 'Stopping Unzip Processor...'
  kill $(cat "$PIDFILE") || rm -f "$PIDFILE"
  rm -f "$PIDFILE"
  echo 'Processor is stopped.' >&2
}


case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
esac
exit $RETVAL