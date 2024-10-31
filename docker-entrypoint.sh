#!/bin/sh
set -eou pipefail

# echo "Collecting static files"
# python manage.py collectstatic --noinput

echo "Applying database migrations"
python manage.py migrate

# echo "Checking superuser"
# DJANGO_SUPERUSER_EMAIL=$(cat /run/secrets/django_superuser_email) && \
# DJANGO_SUPERUSER_USERNAME=$(cat /run/secrets/django_superuser_username) && \
# DJANGO_SUPERUSER_PASSWORD=$(cat /run/secrets/django_superuser_password) && \
# python manage.py createsuperuser --no-input --username "$DJANGO_SUPERUSER_USERNAME" --email "$DJANGO_SUPERUSER_EMAIL" || true

CPU_CORES=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
WORKERS=$(($CPU_CORES * 2 + 1))

echo "Starting server"
gunicorn backend_rds.wsgi:application --workers "$WORKERS" --bind 0.0.0.0:8000