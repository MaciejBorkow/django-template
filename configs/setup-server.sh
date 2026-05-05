#!/bin/bash
# Run once on server setup to register the image auto-update cron job.
set -euo pipefail

# https://cookiecutter-django.readthedocs.io/en/latest/3-deployment/deployment-with-docker.html
# TODO: install docker, add user to docker group

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-image.sh"
LOG_FILE="$SCRIPT_DIR/update-image.log"

CRON_JOB="* * * * * $UPDATE_SCRIPT >> $LOG_FILE 2>&1"

if crontab -l 2>/dev/null | grep -qF "$UPDATE_SCRIPT"; then
  echo "Cron job already registered, skipping."
else
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "Cron job added:"
  echo "  $CRON_JOB"
fi
