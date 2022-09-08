#!/bin/sh

set -eu

apt-get update
apt-get -y install git

install -m 755 /scripts/load-sample-data.sh /docker-entrypoint-initdb.d/

set -x
exec /usr/local/bin/docker-entrypoint.sh "$@"
