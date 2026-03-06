#!/bin/bash
set -e

echo "Waiting for DB2..."

until nc -z db2 50000; do
  echo "DB2 not ready yet..."
  sleep 5
done

echo "DB2 is ready."

cd /opt/tririga
rm -f /opt/ibm/wlp/usr/servers/defaultServer/apps/ibm-tririga.war.xml
echo "Deploying TRIRIGA to Liberty..."

tools/apache-ant-1.10.12/bin/ant -f wlp-build.xml wlp-deploy-container

echo "Starting Liberty server..."

exec /opt/tririga/wlp/bin/server run tririgaServer