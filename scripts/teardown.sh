#!/bin/bash
echo "🗑️ Removendo tudo..."
helm uninstall techsafe -n techsafe
kubectl delete namespace techsafe
minikube stop
echo "✅ Ambiente removido!"
