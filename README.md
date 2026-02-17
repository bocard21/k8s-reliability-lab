# Techsafe - Segurança de Redes Corporativas

Aplicação baseada em microsserviços para monitorar e proteger redes corporativas.

## Tecnologias
- Kubernetes (Minikube)
- Helm
- Istio
- Docker
- PostgreSQL

## Início Rápido
```bash
# 1. Subir o cluster
./scripts/setup-cluster.sh

# 2. Fazer o deploy
./scripts/deploy.sh

# 3. Verificar
kubectl get pods -n techsafe
```

## Estrutura
- `charts/` — Helm Charts
- `k8s/` — Manifests Kubernetes
- `microservices/` — Código-fonte dos serviços
- `scripts/` — Automações

## Backup Manual
```bash
./scripts/backup-manual.sh
```
