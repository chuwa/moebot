#!/bin/zsh

### BEGIN INIT INFO
# Provides:          hubot
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the hubot service
# Description:       starts the Hubot bot for the Campfire rooms
### END INIT INFO

NAME="Hubot"
HUBOT_HOME="/home/mike/apps/moebot"
LOGFILE="$HUBOT_HOME/hubot.log"
PIDFILE="$HUBOT_HOME/hubot.pid"
DAEMON="$HUBOT_HOME/bin/hubot"
DAEMON_OPTS="-a hipchat -n moebot"
set -e

case "$1" in
  start)
        echo -n "Starting $NAME: "
        start-stop-daemon --start -v --chdir $HUBOT_HOME --pidfile $PIDFILE -c mike:mike --make-pidfile --background --exec $DAEMON -- $DAEMON_OPTS
        echo $PIDFILE
        ;;
  stop)
        echo -n "Stopping $NAME: "
        start-stop-daemon --stop --pidfile $PIDFILE
        echo $PIDFILE
        ;;

  restart)
        echo -n "Restarting $NAME: "
        start-stop-daemon --stop --pidfile $PIDFILE
        start-stop-daemon --start -v --chdir $HUBOT_HOME --pidfile $PIDFILE -c mike:mike --make-pidfile --background --exec $DAEMON -- $DAEMON_OPTS
        echo $PIDFILE
        ;;

    *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop}" >&2
        exit 1
        ;;
    esac
    exit
