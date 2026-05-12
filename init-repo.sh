#!/bin/bash

set -euxo pipefail

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
cat ../django-template/configs/gitignore >> .gitignore
echo -e "\n## REPOINIT\n'gh repo create ${PROJECT_NAME} --private --source=. --push'\n" >> README.md 
cp ../django-template/configs/pre-commit .git/hooks/
cp ../django-template/configs/pre-push .
uv run pre-commit install -t pre-push
sed -i '2i ./pre-push' .git/hooks/pre-push
# CI - test
 cat ../django-template/configs/justfile >> justfile
# CI - remove dependabot
# TODO!!!!!!!: add dependabot config to update image and git repo after all fixex
rm -rf .github/dependabot.yml

# CD
# CD - build image
cp ../django-template/configs/docker-image.yml .github/workflows/docker-image.yml #TODO uniwersalne nazwy Dockerfile, compose, build
sed -E -i '/^  django: &django$/,/^    volumes:$/ {
  /^    build:$/,/^    image: .*_production_django$/c\
    image: '"${IMAGE_REPO}"'
}' docker-compose.production.yml
sed -i "s/'main'/'prod'/g" ./.github/workflows/ci.yml

# CD - build and pull services on production server
cp ../django-template/configs/update-image.sh ./compose/production/update-image.sh
sed -E -i "s|^IMAGE=.*$|IMAGE=\"${IMAGE_REPO}\"|" ./compose/production/update-image.sh
cp ../django-template/configs/setup-server.sh ./compose/production/setup-server.sh
chmod +x ./compose/production/setup-server.sh
echo -e "\n## PRODUCTION SERVER\nRun './compose/production/setup-server.sh' on production server. It adds crontab to pull image and git." >> README.md 

# CD - traefik production
mv ./compose/production/traefik/traefik.yml ./compose/production/traefik/traefik.yml.old
cp ../django-template/configs/traefik.yml ./compose/production/traefik/traefik.yml
# CD - make production use http on 8000 port
sed -i 's/0\.0\.0\.0:80:80/0.0.0.0:8000:8000/g' docker-compose.production.yml
# CD - remove image names where it inherite from on django build
sed -i '/production_celeryworker/d;/production_celerybeat/d;/production_flower/d' docker-compose.production.yml
# CD - set production allowed hosts
sed -E -i 's|^DJANGO_ALLOWED_HOSTS=.*$|DJANGO_ALLOWED_HOSTS=0.0.0.0|' .envs/.production/.django

#clean unused fiels - lean contxt for LLM
rm -rf compose/local/docs
rm docker-compose.docs.yml
rm -rf docs
rm .readthedocs.yml
# TODO clean README.md

# setup AGENTs.md
cp ../django-template/configs/AGENTS.md AGENTS.md

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

# fix pre-commit formatting
git add .
if ! uv run pre-commit run --all-files; then
  echo "pre-commit failed; continuing with the remaining setup steps"
fi
git add .
git commit -m "Initial commit"

# check project
just test
gh repo create "${PROJECT_NAME}" --private --source=. --remote=origin --push

