#!/bin/bash
set -eou pipefail

APP_DIR=/home/ubuntu/backend_rds

# Delete the old  directory as needed.
if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
fi

mkdir -vp "$APP_DIR"
chown -R ubuntu:ubuntu "$APP_DIR"
