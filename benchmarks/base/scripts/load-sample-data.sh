#!/bin/sh

set -eu

git clone https://github.com/datacharmer/test_db  /tmp/test_db

cd /tmp/test_db
echo "start loading data"
mysql -u"root" -p"${MARIADB_ROOT_PASSWORD}" "${MARIADB_DATABASE}" < employees.sql
echo "finished loading data"
