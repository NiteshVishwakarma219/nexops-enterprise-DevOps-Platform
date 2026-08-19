# Project 2 — Setup Order

## Prerequisites
- Docker Desktop
- kubectl
- Helm
- Kubernetes cluster (KIND/Minikube/EKS)
- Git
- Argo CD for GitOps
- Docker Hub images:
  - cloudwithnitesh/nexops-backend:v1.0
  - cloudwithnitesh/nexops-frontend:v1.1

## Phase 1 — Validate repository
```bash
helm lint helm/nexops
helm template nexops helm/nexops --namespace nexops
```

## Phase 2 — Create namespace/config/storage/secret
```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/config/app-config.yaml
kubectl apply -f kubernetes/storage/uploads-pvc.yaml
copy kubernetes/backend/secret.example.yaml kubernetes/backend/secret.yaml
# Edit secret.yaml with real values
kubectl apply -f kubernetes/backend/secret.yaml
```

## Phase 3 — Deploy plain Kubernetes manifests
```bash
kubectl apply -f kubernetes/backend/deployment.yaml
kubectl apply -f kubernetes/backend/service.yaml
kubectl apply -f kubernetes/frontend/deployment.yaml
kubectl apply -f kubernetes/frontend/service.yaml
kubectl apply -f kubernetes/ingress/ingress.yaml
```

## Phase 4 — Verify
```bash
kubectl get pods -n nexops
kubectl get svc -n nexops
kubectl get pvc -n nexops
kubectl get ingress -n nexops
kubectl rollout status deployment/nexops-backend -n nexops
kubectl rollout status deployment/nexops-frontend -n nexops
```

## Phase 5 — Helm
The chart defaults to an externally managed Secret. Create `nexops-backend-secret` first, then:
```bash
helm upgrade --install nexops helm/nexops --namespace nexops --create-namespace
```

## Phase 6 — HPA
Install Metrics Server appropriate for your cluster, then:
```bash
kubectl top pods -n nexops
kubectl get hpa -n nexops
```

## Phase 7 — Argo CD
```bash
kubectl apply -f argocd/application.yaml
kubectl get application nexops -n argocd
```

## Important
Never commit:
- `docker/.env`
- `kubernetes/backend/secret.yaml`
- real credentials
- kubeconfig files
- private keys
