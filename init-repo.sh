#!/bin/bash

set -euo pipefail

PROJECT_NAME=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
GIT_USER=$(git remote get-url origin | sed -E 's#.*[:/]([^/]+)/[^/]+\.git#\1#' | tr '[:upper:]' '[:lower:]')
IMAGE_REPO="ghcr.io/${GIT_USER}/${PROJECT_NAME}_django:prod"

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

# init django project
uv tool install "cookiecutter>=1.7.0"
uvx cookiecutter https://github.com/cookiecutter/cookiecutter-django \
  --no-input \
  --config-file ./configs/config.yaml \
  --output-dir ../ \
  "project_name=$PROJECT_NAME"

cd "../$PROJECT_NAME"
uv sync

# enable debugpy in vscode
uv add --dev debugpy
echo -e "\n## DEBUG\nRun debug server in code https://github.com/microsoft/debugpy#waiting-for-the-client-to-attach  and then config lunch.json and connect VScode by 'Run and Debug'." >> README.md 

# CI
# CI - git
git init
cp ../django-template/configs/pre-commit .git/hooks/
uv run pre-commit install -t pre-push
echo -e "\njust test" >> .git/hooks/pre-push
# CI - test
 cat ../django-template/configs/justfile >> justfile
# TODO: mypy, typing django - w precommit i może naprawa przez agenta
# TODO: testy w pre-commit albo jakaś szyvka konmenda
# TODO: autonaprawa linteróœw przez agenta
# TODO: autonaprawa testów przez agenta

# CD
# CD - build image
cp ../django-template/configs/docker-image.yml .github/workflows/docker-image.yml #TODO uniwersalne nazwy Dockerfile, compose, build
sed -E -i '/^  django: &django$/,/^    volumes:$/ {
  /^    build:$/,/^    image: .*_production_django$/c\
    image: '"${IMAGE_REPO}"'
}' docker-compose.production.yml

# CD - pull image on production server
cp ../django-template/configs/update-image.sh ./compose/production/update-image.sh
sed -E -i "s|^IMAGE=.*$|IMAGE=\"${IMAGE_REPO}\"|" ./compose/production/update-image.sh
cp ../django-template/configs/setup-server.sh ./compose/production/setup-server.sh
chmod +x ./compose/production/setup-server.sh
echo -e "\n## PRODUCTION SERVER\nRun`./compose/production/setup-server.sh` on production server. It adds crontab to pull image and git." >> README.md 
# TODO auto setup for a server 

# Observability
# grafana
#TODO
# sentry
# TODO

# Local Build
docker compose -f docker-compose.local.yml down -v --rmi all --remove-orphans
docker compose -f docker-compose.local.yml build --no-cache
docker compose -f docker-compose.local.yml run --rm django uv lock
docker compose -f docker-compose.local.yml build
docker compose -f docker-compose.local.yml run --rm django python manage.py migrate
docker compose -f docker-compose.local.yml run --rm django python manage.py collectstatic
docker compose -f docker-compose.local.yml up -d

# check project generation
# pre-commit run --all-files
just test
# just type

# git init
git add .
git commit -m "Initial commit"