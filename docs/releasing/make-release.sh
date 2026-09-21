#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$SCRIPT_DIR/../..
[[ -n "${DEBUG:-}" ]] && set -x

log() { echo "$1" >&2; }
fail() { log "$1"; exit 1; }

TAG="${TAG:?TAG env variable must be specified}"
REPO_PREFIX="${REPO_PREFIX:?REPO_PREFIX env variable must be specified e.g. us-central1-docker.pkg.dev\/google-samples\/microservices-demo}"
PROJECT_ID="${PROJECT_ID:?PROJECT_ID env variable must be specified e.g. google-samples}"

if [[ "$TAG" != v* ]]; then
    fail "\$TAG must start with 'v', e.g. v0.1.0 (got: $TAG)"
fi

if [[ $(git status -s | wc -l) -gt 0 ]]; then
    echo "error: can't have uncommitted changes"
    exit 1
fi

git checkout main
git pull

"${SCRIPT_DIR}"/make-docker-images.sh

"${SCRIPT_DIR}"/make-release-artifacts.sh

"${SCRIPT_DIR}"/make-helm-chart.sh

git checkout -b "release/${TAG}"
git add "${REPO_ROOT}/release/"
git add "${REPO_ROOT}/kustomize/base/"
git add "${REPO_ROOT}/helm-chart/"
git commit --allow-empty -m "Release $TAG"
log "Pushing k8s manifests to release/${TAG}..."
git tag "$TAG"
git push --set-upstream origin "release/${TAG}"
git push --tags

log "Successfully tagged release $TAG."
