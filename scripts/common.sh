#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
export NAMESPACE=techsafe
export RELEASE=techsafe
export CHART=./charts/k8s-reliability-chart
require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Required command: $1" >&2; exit 1; }
}
wait_for_job() {
  local job="$1"
  if ! kubectl wait --for=condition=complete "job/$job" -n "$NAMESPACE" --timeout=180s; then
    kubectl logs "job/$job" -n "$NAMESPACE" --all-containers=true || true
    return 1
  fi
  kubectl logs "job/$job" -n "$NAMESPACE" --all-containers=true
}
