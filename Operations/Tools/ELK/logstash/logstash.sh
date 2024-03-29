#!/usr/bin/env bash
#
# logstash
#
# chkconfig:   - 57 47
# description: logstash
# processname: logstash


PIDDIR="/var/run/logstash"
export PIDFILE="/var/run/logstash-agent.pid"
export LS_HOME="/opt/logstash/agent"
export LS_HEAP_SIZE="256M"
export LOGSTASH_OPTS="agent -f /opt/logstash/agent/etc/conf.d/ -l /opt/logstash/agent/log/logstash.log -w 1"
LS_USER="logstash"
LS_LOG="logstash.log"
LOGDIR="."
export JAVA_OPTS="-server -Xms256M -Xmx256M -Djava.io.tmpdir=$LS_HOME/tmp/"
BIN_SCRIPT="/usr/bin/env $LS_HOME/bin/logstash $LOGSTASH_OPTS > $LS_LOG 2>&1 &  echo \$! > $PIDFILE"

if [ -f /etc/init.d/functions ] ; then
  . /etc/init.d/functions
fi

start() {
  if [ ! -d "$PIDDIR" ] ; then
    mkdir "$PIDDIR"
    chown $LS_USER:$LS_USER $PIDDIR
  fi

  if [ -f $PIDFILE ]; then
    echo -e "\033[31;1mPID file found in $PIDFILE, already running?\033[0m"
    ls_pid="$(cat $PIDFILE)"
    pid_running="$( ps ax | grep 'java' | grep $ls_pid )"

    if [ ! -z "$pid_running" ] ; then
      echo -e "\033[31;1mPID $ls_pid still alive, logstash is already running. Doing nothing\033[0m"
      return 1
    fi
  fi

  echo -e "\033[1mStarting logstash...\033[0m"
  pushd $LS_HOME  > /dev/null 2>&1
  su $LS_USER -c "$BIN_SCRIPT" > /dev/null 2>&1
  ls_pid=$!
  result=$?
  popd  > /dev/null 2>&1

  if [ $result -ne 0 ] ; then
    failure
    echo -e "Logstash did not start successfully"
    exit 1
  else
    success
    echo -e "Logstash started successfully"
  fi
}



function stop() {
  echo -n -e "\033[1mStopping logstash...\033[0m"

  if [ -z "$SHUTDOWN_WAIT" ]; then
    SHUTDOWN_WAIT=5
  fi

  if [ ! -z "$PIDFILE" ]; then
    if [ -f "$PIDFILE" ]; then
      kill -0 `cat $PIDFILE` >/dev/null 2>&1
      if [ $? -gt 0 ]; then
        echo "PID file ($PIDFILE) found but no matching process was found. Nothing to do."
        return 0
      fi
    else
      echo "\$PIDFILE was set ($PIDFILE) but the specified file does not exist. Is Logstash running? Assuming it has stopped and pro\
        ceeding."
      return 0
    fi
  fi

  kill `cat $PIDFILE` >/dev/null 2>&1

  if [ ! -z "$PIDFILE" ]; then
    if [ -f "$PIDFILE" ]; then
      while [ $SHUTDOWN_WAIT -ge 0 ]; do
        kill -0 `cat $PIDFILE` >/dev/null 2>&1
        if [ $? -gt 0 ]; then
          rm $PIDFILE
          break
        fi
        if [ $SHUTDOWN_WAIT -gt 0 ]; then
          sleep 1
        fi
        SHUTDOWN_WAIT=`expr $SHUTDOWN_WAIT - 1 `
      done
      # still not dead, we may need to resort to drastic measures
      if [ -f "$PIDFILE" ]; then
        kill -0 `cat $PIDFILE` >/dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo "Application still alive, sleeping for 20 seconds before sending SIGKILL"
          sleep 20
          kill -0 `cat $PIDFILE` >/dev/null 2>&1
          if [ $? -eq 0 ]; then
            kill -9 `cat $PIDFILE` >/dev/null 2>&1
            echo "Killed with extreme prejudice"
          else
            echo "Application stopped, no need to use SIGKILL"
          fi
          rm $PIDFILE
        fi
      fi
    fi
  fi
}

restart() {
  stop
  start
}

status() {
  # GOT PIDFILE?
  [ -f $PIDFILE ] && pid=$(cat $PIDFILE)

  # RUNNING
  if [[ $pid && -d "/proc/$pid" ]]; then
    success
    echo -e "Logstash is running with pid $pid"
  fi

  # NOT RUNNING
  if [[ ! $pid || ! -d "/proc/$pid" ]]; then
    echo "Logstash not running"
  fi

  # STALE PID FOUND
  if [[ ! -d "/proc/$pid" && -f $PIDFILE ]]; then
    echo -e "\033[1;31;40m[!] Stale PID found in $PIDFILE\033[0m"
  fi
}


case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status $2
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart|status [-v]|}"
    exit 1
esac

exit $?