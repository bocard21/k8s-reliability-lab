#!/usr/bin/env bash
# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require kubectl
job="restore-check-$(date +%s)"
kubectl create job --from=cronjob/techsafe-db-restore-check "$job" -n "$NAMESPACE"
wait_for_job "$job"
