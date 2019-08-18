#!/bin/bash -e
#
# Check DataReceiver alived or not.
#
# Adapt the following lines to your configuration
#
# Return code: 0 is success, otherwise fail.
#


RETVAL=0

NOW=$(date +"%Y/%m/%d %T")
DATE=$(date +"%Y%m%d")

APPLICAPTION_PATH=/workspace
KEEPALIVED_CHECK_LOG=${APPLICAPTION_PATH}/script/log/datareceiver-check-${DATE}.log
SHARED_DISK_PATH=/data


CheckDataReceiver(){
  # Check Process exist.
  local pid_count=`ps -efw | grep SourceProcessor | grep -v grep | wc -l`
  return $pid_count
}

CheckSharedDiskAlived() {
  { # try
    `timeout 5 touch ${SHARED_DISK_PATH}/hearbeat.test` &&
    return 0
  } || { # catch
    return 1
  }
}

CheckDataReceiverAlived() {
  CheckDataReceiver
  local process_counts=$?
  CheckSharedDiskAlived
  local shared_disk_state=$?
  if [ "$process_counts" -eq "0" ]; then
    StartDataReceiver
    return $?
  elif [ "$process_counts" -gt "1" ]; then
    StopDataReceiver
    return $?
  elif [ "$shared_disk_state" -eq "1" ]; then
    return "1"
  else 
    return "0"
  fi
}

StartDataReceiver() {
  local process_state_log="$APPLICAPTION_PATH/script/log/process_state.notify"
  local process_state
  if [ -f $process_state_log ]; then
    process_state=$(cat $process_state_log)
  else
    process_state="FAULT"
  fi
  `$APPLICAPTION_PATH/SourceProcessor/source.sh transit ${process_state}`
  return "1"
}


StopDataReceiver() {
  processes=`ps -efw | grep SourceProcessor | grep -v grep | awk '{print $2}'`
  for process in ${processes}
  do
    kill ${process}
  done
  return "1"
}

# Start here.
CheckDataReceiverAlived
state=$?
if [ "$state" -eq "0" ]; then
  RETVAL=$state
else
  echo "Data receiver has failed, try to trigger keepalived..." >> ${KEEPALIVED_CHECK_LOG}
  RETVAL=$state
fi

exit $RETVAL

