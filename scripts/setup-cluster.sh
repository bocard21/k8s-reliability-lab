#!/usr/bin/env bash
# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require minikube
require kubectl
require docker
docker info >/dev/null
minikube start --driver=docker --cni=calico --memory=6144 --cpus=4 --disk-size=20g
minikube addons enable metrics-server
kubectl apply -f k8s/base/
# The default lab does not require a service mesh. Explicitly enable it if needed.
if [[ "${ENABLE_ISTIO:-false}" == true ]]; then
  require istioctl
  istioctl install --set profile=demo -y
  kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
else
  kubectl label namespace "$NAMESPACE" istio-injection=disabled --overwrite
fi
kubectl get nodes
