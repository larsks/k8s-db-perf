#!/bin/sh

set -eu

git clone https://github.com/datacharmer/test_db  /tmp/test_db

cd /tmp/test_db
set -x
mysql -u"root" -p"${MARIADB_ROOT_PASSWORD}" "${MARIADB_DATABASE}" < employees.sql
