#!/bin/bash

set -euo pipefail

PROJECT_NAME="${1:-}"
IMAGE_REPO="ghcr.io/maciejb/${PROJECT_NAME}_django:prod"

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

uv tool install "cookiecutter>=1.7.0"
uvx cookiecutter https://github.com/cookiecutter/cookiecutter-django \
  --no-input \
  --config-file ./configs/config.yaml \
  --output-dir ../ \
  "project_name=$PROJECT_NAME"

cd "../$PROJECT_NAME"
uv sync
# debug enable in vscode
uv add --dev debugpy
echo -e "\n## DEBUG\nRun debug server in code https://github.com/microsoft/debugpy#waiting-for-the-client-to-attach  and then config lunch.json and connect VScode by 'Run and Debug'." >> README.md 
# CI
git init
cp ../django-template/configs/pre-commit .git/hooks/
cp ../django-template/configs/pre-push .git/hooks/
# TODO: mypy, typing django - w precommit i może naprawa przez agenta
# TODO: testy w pre-commit albo jakaś szyvka konmenda
# TODO: autonaprawa linteróœw przez agenta
# TODO: autonaprawa testów przez agenta
# CD - build image
cp ../django-template/configs/docker-image.yml .github/workflows/docker-image.yml #TODO uniwersalne nazwy Dockerfile, compose, build
sed -E -i '/^  django: &django$/,/^    volumes:$/ {
  /^    build:$/,/^    image: .*_production_django$/c\
    image: '"${IMAGE_REPO}"'
}' docker-compose.production.yml
# CD - pull image from server
cp ../django-template/configs/update-image.sh .
sed -E -i "s|^IMAGE=.*$|IMAGE=\"${IMAGE_REPO}\"|" update-image.sh
cp ../django-template/configs/setup-server.sh .
chmod +x update-image.sh setup-server.sh
# Observability
# grafana
#TODO
# sentry
# TODO