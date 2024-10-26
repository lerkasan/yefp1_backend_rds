#!/bin/bash
set -xe

cd /home/ubuntu/app || exit
docker compose down
