#!/bin/sh

INITDIR=/docker-entrypoint-initdb.d

set -eu

apt-get update
apt-get -y install git

install -m 755 /scripts/load-sample-data.sh "${INITDIR}/"
install -m 644 /scripts/create-results-database.sql "${INITDIR}/"

set -x
exec /usr/local/bin/docker-entrypoint.sh "$@"
