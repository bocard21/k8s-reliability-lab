#!/usr/bin/env bash
# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require kubectl
require helm
require minikube
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/
if [[ "${ENABLE_ISTIO:-false}" == true ]]; then
  kubectl get crd peerauthentications.security.istio.io >/dev/null
  kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
elif [[ "$(kubectl get namespace "$NAMESPACE" -o jsonpath='{.metadata.labels.istio-injection}')" == enabled ]]; then
  echo 'Namespace already uses Istio. Use ENABLE_ISTIO=true or recreate this lab.' >&2
  exit 1
fi
# Generate a credential for this lab, preserving it on subsequent deployments.
if ! kubectl get secret techsafe-db-secret -n "$NAMESPACE" >/dev/null 2>&1; then
  require openssl
  password="$(openssl rand -hex 24)"
  kubectl create secret generic techsafe-db-secret -n "$NAMESPACE"     --from-literal=username=techsafe_user --from-literal=password="$password"
  unset password
fi
kubectl apply -f k8s/security/
bash scripts/build-images.sh
helm upgrade --install "$RELEASE" "$CHART" -n "$NAMESPACE"   --values "$CHART/values-dev.yaml" --wait --timeout 300s
kubectl apply -f k8s/backups/
if [[ "${ENABLE_ISTIO:-false}" == true ]]; then
  kubectl apply -f k8s/istio/
fi
kubectl get pods,services,pvc -n "$NAMESPACE"
