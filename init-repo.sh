#!/bin/bash

set -euo pipefail

PROJECT_NAME="${1:-}"

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

uv tool install "cookiecutter>=1.7.0"
uvx cookiecutter https://github.com/cookiecutter/cookiecutter-django \
  --no-input \
  --config-file ./config.yaml \
  --output-dir ../ \
  "project_name=$PROJECT_NAME"

cd "../$PROJECT_NAME"
uv sync
# debug enable in vscode
uv add debugpy
echo -e "\n## DEBUG\nRun debug server in code https://github.com/microsoft/debugpy#waiting-for-the-client-to-attach  and then config lunch.json and connect VScode by 'Run and Debug'." >> README.md 
# CI
git init
cp ../django-template/pre-commit .git/hooks/
cp ../django-template/pre-push .git/hooks/
# TODO: mypy, typing django - w precommit i może naprawa przez agenta
# TODO: testy w pre-commit albo jakaś szyvka konmenda
# TODO: autonaprawa linteróœw przez agenta
# TODO: autonaprawa testów przez agenta
# CD - build image
# TODO: naming uniwersalny Dockerfile, compose, .sh 
mkdir -p .github/workflows
cp ../django-template/docker-image.yml .github/workflows/deploy.yml #TODO uniwersalne nazwy Dockerfile, compose, build
# CD - pull image from server
cp ../django-template/update-image.sh . # TODO - uniwersalne nazwy pull, build
cp ../django-template/update-image.cron . # TODO - uniwersalne nazwy pull, build
# TODO add crontab command to pull image on server - nameing !!!!!
# Observability
# grafana
#TODO
# sentry
# TODO