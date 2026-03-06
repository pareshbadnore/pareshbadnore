#!/bin/bash
set -e

echo "--------------------------------------------"
echo "Starting TRIRIGA installation"
echo "--------------------------------------------"

cd /opt/tririga

ANT=tools/apache-ant-1.10.12/bin/ant

if [ ! -x "$ANT" ]; then
  echo "ERROR: ANT not found at $ANT"
  exit 1
fi

echo "Using ANT at $ANT"

echo "Step 1: Creating data schema user"
$ANT -f build.xml db-create-data-schema-user

echo "Step 2: Creating tablespaces"
$ANT -f build.xml db-create-data-schema-tablespace

echo "Step 3: Importing TRIRIGA platform data"
$ANT -f build.xml db-data-import

echo "Step 4: Deploying Liberty server configuration"
$ANT -f wlp-build.xml wlp-deploy

echo "Marking installation as completed"
touch /opt/tririga/.installed

echo "--------------------------------------------"
echo "TRIRIGA installation finished successfully"
echo "--------------------------------------------"
