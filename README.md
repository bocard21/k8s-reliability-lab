# K8s Reliability Lab

Projeto focado em práticas de SRE e DevOps utilizando:

- Kubernetes
- Helm
- Istio (Service Mesh + mTLS)
- Liveness / Readiness Probes
- CronJob de Backup
- Microsserviços

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
