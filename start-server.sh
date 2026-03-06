#!/bin/bash
set -e

DB_HOST=${DB_HOST:-tririga-db2}
DB_PORT=${DB_PORT:-50000}

wait_for_db2() {
  echo "Waiting for DB2 at ${DB_HOST}:${DB_PORT}..."

  until nc -z "${DB_HOST}" "${DB_PORT}"; do
    echo "DB2 not ready yet..."
    sleep 5
  done

  echo "DB2 is reachable. Waiting 10s for DB2 to finish internal startup..."
  sleep 10
}

install_tririga_if_needed() {
  if [ -f /opt/tririga/.installed ]; then
    echo "TRIRIGA installation marker found. Skipping first-time install."
    return
  fi

  echo "First-time install required. Running install-tririga.sh..."
  /opt/tririga/install-tririga.sh
}

start_liberty() {
  echo "Starting Liberty server..."
  exec /opt/tririga/wlp/bin/server run tririgaServer
}

wait_for_db2
install_tririga_if_needed
start_liberty
