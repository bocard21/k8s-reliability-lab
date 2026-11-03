#!/usr/bin/env bash
# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require kubectl
job="backup-manual-$(date +%s)"
kubectl create job --from=cronjob/techsafe-db-backup "$job" -n "$NAMESPACE"
wait_for_job "$job"
