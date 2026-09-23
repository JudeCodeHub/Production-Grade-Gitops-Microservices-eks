#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$SCRIPT_DIR/../..

log() { echo "$1" >&2; }

TAG="${TAG:?TAG env variable must be specified}"
GITHUB_USERNAME="${GITHUB_USERNAME:?GITHUB_USERNAME env variable must be specified}"
HELM_CHART_REPO="ghcr.io/${GITHUB_USERNAME,,}"

cd ${REPO_ROOT}/Helm-Chart
sed -i "s/^appVersion:.*/appVersion: \"${TAG}\"/" Chart.yaml
sed -i "s/^version:.*/version: ${TAG:1}/" Chart.yaml
helm package .
helm push onlineboutique-${TAG:1}.tgz oci://$HELM_CHART_REPO

rm ./onlineboutique-${TAG:1}.tgz

log "Successfully built and pushed the Helm chart."
