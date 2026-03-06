#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

DB_HOST=${DB_HOST:-db2}
DB_PORT=${DB_PORT:-50000}
ANT_PATH="/opt/tririga/tools/apache-ant-1.10.12/bin/ant"

echo "--- Checking Database Readiness ---"
# Using the service name from your docker-compose
until (echo > /dev/tcp/${DB_HOST}/${DB_PORT}) >/dev/null 2>&1; do
  echo "Waiting for DB2 at ${DB_HOST}:${DB_PORT}..."
  sleep 5
done

echo "DB2 is reachable! Giving it a 10s 'settle' period..."
sleep 10

# Check if first-time installation is needed
if [ ! -f /opt/tririga/.installed ]; then
  echo "--- Starting First-Time TRIRIGA Installation ---"
  
  # Ensure Ant is executable
  chmod +x "$ANT_PATH"

  echo "Running: db-create-data-schema-user"
  $ANT_PATH -f build.xml db-create-data-schema-user
  
  echo "Running: db-create-data-schema-tablespace"
  $ANT_PATH -f build.xml db-create-data-schema-tablespace
  
  echo "Running: db-data-import (This may take a while...)"
  $ANT_PATH -f build.xml db-data-import
  
  echo "Running: wlp-deploy"
  $ANT_PATH -f wlp-build.xml wlp-deploy

  # Mark as installed
  touch /opt/tririga/.installed
  echo "--- TRIRIGA Installation Completed Successfully ---"
fi

echo "--- Launching Liberty Server ---"
# Using exec to pass signals to the process correctly
exec /opt/tririga/wlp/bin/server run tririgaServer