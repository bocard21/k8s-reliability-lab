#!/usr/bin/env bash
# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require docker
require minikube
for service in network-monitor security-analyzer; do
  docker build -t "k8s-reliability/$service:1.0.0" "microservices/$service"
  minikube image load "k8s-reliability/$service:1.0.0"
done
