#!/bin/bash

UI_SCREEN_NAME="aitoolkit-ui"
WORKER_SCREEN_NAME="aitoolkit-worker"


start() {
  if screen -ls | grep -q "$UI_SCREEN_NAME"; then
    echo "ERROR: UI screen session '$UI_SCREEN_NAME' is already running."
  else
    echo "Starting UI server in screen session '$UI_SCREEN_NAME'..."
    screen -dmS "$UI_SCREEN_NAME" bash -c 'next start --port 8675'
  fi

  # Check if Worker screen is already running
  if screen -ls | grep -q "$WORKER_SCREEN_NAME"; then
    echo "ERROR: Worker screen session '$WORKER_SCREEN_NAME' is already running."
  else
    echo "Starting worker in screen session '$WORKER_SCREEN_NAME'..."
    screen -dmS "$WORKER_SCREEN_NAME" bash -c 'node dist/worker.js'
  fi
  
  echo "---"
  sleep 1
  status
}

stop() {
  echo "Stopping screen sessions..."
  if screen -ls | grep -q "$UI_SCREEN_NAME"; then
    screen -X -S "$UI_SCREEN_NAME" quit
    echo "UI screen '$UI_SCREEN_NAME' stopped."
  else
    echo "UI screen was not running."
  fi

  if screen -ls | grep -q "$WORKER_SCREEN_NAME"; then
    screen -X -S "$WORKER_SCREEN_NAME" quit
    echo "Worker screen '$WORKER_SCREEN_NAME' stopped."
  else
    echo "Worker screen was not running."
  fi
}

status() {
  echo "--- STATUS ---"
  if screen -ls | grep -q "$UI_SCREEN_NAME"; then
    echo "UI screen '$UI_SCREEN_NAME' is RUNNING."
  else
    echo "UI screen is STOPPED."
  fi

  if screen -ls | grep -q "$WORKER_SCREEN_NAME"; then
    echo "Worker screen '$WORKER_SCREEN_NAME' is RUNNING."
  else
    echo "Worker screen is STOPPED."
  fi
  echo "----------------"
  echo "To view logs, run: bun run logs:ui"
  echo "Or manually attach: screen -r $UI_SCREEN_NAME"
}

logs() {
    TARGET_SCREEN=""
    if [ "$1" == "ui" ]; then
        TARGET_SCREEN=$UI_SCREEN_NAME
    elif [ "$1" == "worker" ]; then
        TARGET_SCREEN=$WORKER_SCREEN_NAME
    else
        echo "Usage: $0 logs {ui|worker}"
        exit 1
    fi

    if screen -ls | grep -q "$TARGET_SCREEN"; then
        echo "Attaching to screen '$TARGET_SCREEN'. Press Ctrl+A, then D to detach."
        screen -r "$TARGET_SCREEN"
    else
        echo "Error: Screen session '$TARGET_SCREEN' is not running."
    fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    stop
    sleep 1
    start
    ;;
  logs)
    logs "$2"
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|logs [ui|worker]}"
    exit 1
esac
