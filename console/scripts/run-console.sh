#!/bin/sh

export HOME=/tmp
export PATH=/tmp/.local/bin:$PATH

pip install -r /scripts/requirements.txt

cd /scripts
gunicorn --bind :5000 console:app
