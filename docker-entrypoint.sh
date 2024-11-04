#!/bin/sh
set -eou pipefail

# echo "Collecting static files"
# python manage.py collectstatic --noinput

echo "Applying database migrations"
python manage.py migrate

CPU_CORES=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
WORKERS=$(($CPU_CORES * 2 + 1))

echo "Starting server"
gunicorn backend_rds.wsgi:application --workers "$WORKERS" --bind 0.0.0.0:8000