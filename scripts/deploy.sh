#!/bin/bash
set -e
echo "🔐 Criando secrets..."
kubectl create secret generic techsafe-db-secret \
  --from-literal=password=SenhaSegura123! \
  --from-literal=username=techsafe_user \
  --namespace=techsafe \
  --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Implantando com Helm..."
helm upgrade --install techsafe ./charts/techsafe-chart \
  --namespace techsafe \
  --create-namespace \
  --values ./charts/techsafe-chart/values.yaml

echo "🗄️ Aplicando backups e segurança..."
kubectl apply -f k8s/backups/
kubectl apply -f k8s/security/
kubectl apply -f k8s/istio/

echo "✅ Deploy concluído!"
helm list -n techsafe
kubectl get pods -n techsafe
