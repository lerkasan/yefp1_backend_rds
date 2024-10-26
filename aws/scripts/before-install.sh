#!/bin/bash
set -xe

# Delete the old  directory as needed.
if [ -d /home/ubuntu/app ]; then
    rm -rf /home/ubuntu/app/
fi

mkdir -vp /home/ubuntu/app/
chown -R ubuntu:ubuntu /home/ubuntu/app/

docker system prune -a