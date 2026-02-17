#!/bin/bash
echo "💾 Executando backup manual..."
kubectl create job --from=cronjob/techsafe-db-backup \
  backup-manual-$(date +%Y%m%d%H%M%S) \
  -n techsafe
echo "✅ Job de backup criado!"
kubectl get jobs -n techsafe
