# K8s Reliability Lab

Laboratório local de Kubernetes e confiabilidade com dois serviços Flask de demonstração,
PostgreSQL persistente, Helm, probes, HPA, NetworkPolicy e backup com teste de restauração.
Os endpoints `/monitor` e `/security` retornam dados de demonstração: não realizam análise
real de redes ou detecção de ameaças. O projeto não representa um ambiente de produção.

## Pré-requisitos

- Linux, macOS ou WSL2 com Bash, Docker ativo, Minikube, kubectl, Helm 3 e OpenSSL.
- Pelo menos 4 CPUs e 6 GiB disponíveis para o cluster.
- Acesso à internet para imagens e instalação dos componentes do cluster.

## Executar do início

```bash
git clone https://github.com/bocard21/k8s-reliability-lab.git
cd k8s-reliability-lab
bash scripts/setup-cluster.sh
bash scripts/deploy.sh
kubectl get pods,svc,pvc -n techsafe
kubectl port-forward -n techsafe svc/techsafe-network-monitor 8080:8080
```

Em outro terminal:

```bash
curl --fail http://localhost:8080/health/live
curl --fail http://localhost:8080/health/ready
curl --fail http://localhost:8080/monitor
```

O deploy constrói as duas imagens, carrega-as no Minikube e instala o chart correto,
incluindo PostgreSQL e seu PVC. A senha é gerada na primeira instalação e preservada
no Secret do cluster. Não utilize credenciais ou dados reais neste laboratório.
O namespace e o release suportados pelos scripts são `techsafe`.

## Disponibilidade e investigação

Liveness verifica o processo. Readiness do network-monitor consulta PostgreSQL com
timeout: falha da dependência retorna 503 sem induzir reinicialização por liveness.
O security-analyzer não usa banco e verifica apenas seu próprio processo.

Experimento manual no laboratório, depois de o deploy estar saudável:

```bash
kubectl scale deployment techsafe-postgres -n techsafe --replicas=0
kubectl get pods -n techsafe -w
# Em outro terminal, readiness deve falhar e liveness continuar respondendo.
curl -i http://localhost:8080/health/ready
curl -i http://localhost:8080/health/live
kubectl scale deployment techsafe-postgres -n techsafe --replicas=1
kubectl rollout status deployment/techsafe-postgres -n techsafe
```

Registre tempos e saídas observados. O repositório não atribui resultados medidos
antes da execução desse experimento.

## Backup e restauração

```bash
bash scripts/backup-manual.sh
bash scripts/restore-check.sh
```

O backup diário usa `pg_dump` em formato custom e PVC local, com retenção de 30 dias.
O teste restaura o backup mais recente em uma base temporária e a remove ao terminar;
não sobrescreve `techsafe_db`. Primeiro crie dados de teste se quiser validar conteúdo,
além da integridade do arquivo. Um PVC local não substitui backup externo ou recuperação
de desastre. Os scripts aguardam o Job terminar e exibem seu log.

## HPA e ambientes

`values-dev.yaml` desativa o HPA para manter uma réplica por aplicação no laboratório.
`values-prod.yaml` é um exemplo de parâmetros, não uma configuração pronta para produção.
Para experimentar HPA, habilite `autoscaling.enabled=true` no upgrade Helm e observe
`kubectl get hpa -n techsafe`. O setup habilita metrics-server; a eficácia do autoscaling
precisa ser demonstrada sob carga, não apenas pela existência do manifesto.

## Istio opcional

Instale `istioctl` compatível com o Kubernetes utilizado e execute o setup e o deploy
com `ENABLE_ISTIO=true`. As rotas apontam para os nomes reais dos Services Helm.
As duas aplicações recebem sidecars e política STRICT; PostgreSQL e Jobs ficam fora
da malha. A política de rede permite comunicação interna, DNS e controle do Istio.
Não desabilite a malha em um namespace já implantado; recrie o laboratório para trocar
de modo. Valide as políticas e o tráfego na versão de Istio escolhida antes de afirmar
que mTLS foi comprovado. O código distribuído de terceiros não faz parte da autoria.

## Estrutura e validação

- `charts/k8s-reliability-chart/`: fonte do deploy das aplicações, Services e banco.
- `k8s/base`, `k8s/security`, `k8s/backups`, `k8s/istio`: recursos complementares.
- `k8s/deployments`, `k8s/services`, `k8s/probes`: referências antigas; não aplicar junto
  com Helm, pois não constituem o fluxo suportado de instalação.
- `microservices/`: aplicações Flask demonstrativas.
- `scripts/`: setup, construção, deploy, backup, restauração e remoção explícita.
- `tests/`: contrato dos manifests e comportamento de readiness.

```bash
helm lint charts/k8s-reliability-chart --strict
helm template techsafe charts/k8s-reliability-chart -n techsafe \
  -f charts/k8s-reliability-chart/values-dev.yaml > /tmp/lab.yaml
python -m pip install PyYAML pytest flask==3.0.0 psycopg2-binary==2.9.9
python tests/check_manifests.py /tmp/lab.yaml
pytest -q tests/test_readiness.py
```

A CI verifica sintaxe Bash, renderização Helm, contratos dos manifests, testes de
readiness e construção das imagens. Também cria um cluster descartável Kind para
implantar o chart, interromper e recuperar o PostgreSQL e executar backup e restauração.
Esse fluxo não valida o setup Minikube, a aplicação de NetworkPolicy pelo Calico ou o
Istio opcional. Para problemas, consulte `kubectl describe pod`, eventos, logs do
container e logs de Jobs; não publique Secrets em evidências.

## Remover o laboratório

O comando abaixo apaga banco e backups do namespace. Use apenas no ambiente de estudo:

```bash
bash scripts/teardown.sh --delete-lab-data
```
