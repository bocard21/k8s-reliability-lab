#!/usr/bin/env bash
# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require helm
require kubectl
require minikube
if [[ "${1:-}" != --delete-lab-data ]]; then
  echo 'Usage: bash scripts/teardown.sh --delete-lab-data' >&2
  echo 'Deletes the techsafe namespace, database and backup volumes.' >&2
  exit 1
fi
helm uninstall "$RELEASE" -n "$NAMESPACE" --ignore-not-found
kubectl delete namespace "$NAMESPACE" --ignore-not-found
minikube stop
