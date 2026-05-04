#!/bin/bash
# GIT UPDATE
set -euo pipefail

REPO_PATH="/home/maciejb/bizfinder-v2"
cd "$REPO_PATH"

git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Updating: $LOCAL -> $REMOTE"
    git pull --ff-only
else
    echo "Up to date."
fi

# IMAGE UPDATE
IMAGE="ghcr.io/maciejborkow/bizfinder-v2:prod"
# Get local digest
LOCAL_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE | cut -d'@' -f2)
# Get remote digest 
REMOTE_DIGEST=$(docker manifest inspect $IMAGE | grep -Po '(?<="digest": ")[^"]*' | head -n 1)

if [ "$LOCAL_DIGEST" != "$REMOTE_DIGEST" ]; then
    echo "New image available: $REMOTE_DIGEST"
    docker compose -f docker-compose.prod.yml pull
    docker compose -f docker-compose.prod.yml up -d
    docker image prune -f
else
    echo "Image is up to dateeeee."
fi