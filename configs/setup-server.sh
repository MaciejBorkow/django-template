#!/bin/bash
# Run once on server setup to register the image auto-update cron job.
set -euo pipefail

# https://cookiecutter-django.readthedocs.io/en/latest/3-deployment/deployment-with-docker.html
# TODO: install docker, add user to docker group

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-image.sh"
LOG_FILE="$SCRIPT_DIR/update-image.log"
DOCKER_COMPOSE="$SCRIPT_DIR/../../docker-compose.production.yml"

CRON_JOB="* * * * * $UPDATE_SCRIPT >> $LOG_FILE 2>&1"

# run server
docker compose -f "$DOCKER_COMPOSE" build
docker compose -f "$DOCKER_COMPOSE" pull
docker compose -f "$DOCKER_COMPOSE" up -d
docker compose -f "$DOCKER_COMPOSE" exec django python manage.py migrate



# add cronjob to pull image and git repo
if crontab -l 2>/dev/null | grep -qF "$UPDATE_SCRIPT"; then
  echo "Cron job already registered, skipping."
else
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "Cron job added:"
  echo "  $CRON_JOB"
fi
