#!/bin/bash
set -e
echo "🚀 Iniciando Minikube..."
minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g

echo "✅ Habilitando addons..."
minikube addons enable ingress
minikube addons enable metrics-server

echo "📦 Instalando Istio..."
curl -L https://istio.io/downloadIstio | sh -
export PATH="$PATH:$(ls -d istio-*/bin)"
istioctl install --set profile=demo -y

echo "🏗️ Criando namespace e recursos base..."
kubectl apply -f k8s/base/

echo "✅ Cluster pronto!"
kubectl get nodes
