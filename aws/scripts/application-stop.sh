#!/bin/bash
set -eou pipefail

APP_DIR=/home/ubuntu/backend_rds

cd "$APP_DIR" || exit
docker compose down
