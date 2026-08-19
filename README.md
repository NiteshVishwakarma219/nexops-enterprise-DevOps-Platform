# Enterprise DevOps & Kubernetes Platform

This repository is **Project 2** of the NexEcoTech portfolio.

The single workload is the **Enterprise Employee Management System (EEMS)**. Its source code
stays in the separate application repository. This repository owns the container runtime,
Kubernetes platform, CI validation/security, Helm packaging, Jenkins validation, and Argo CD GitOps.

## Stack

- Docker / Docker Compose
- Docker Hub
- Kubernetes
- Helm
- GitHub Actions
- Jenkins
- Argo CD / GitOps
- NGINX Ingress
- ConfigMap / Secret
- PVC
- HPA
- External PostgreSQL (managed by the application/cloud architecture)

## Repository structure

```text
enterprise-devops-platform/
├── .github/
│   └── workflows/
│       └── ci.yml
├── argocd/
│   └── application.yaml
├── docker/
│   ├── docker-compose.yml
│   └── .env.example
├── kubernetes/
│   ├── namespace.yaml
│   ├── config/
│   │   └── app-config.yaml
│   ├── backend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── secret.example.yaml
│   ├── frontend/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── ingress/
│   │   └── ingress.yaml
│   └── storage/
│       └── uploads-pvc.yaml
├── helm/
│   └── nexops/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── jenkins/
│   └── Jenkinsfile
├── scripts/
│   ├── encode-secrets.sh
│   └── update-image-tag.sh
├── docs/
│   ├── ARCHITECTURE.md
│   ├── CI-CD.md
│   ├── HOW-TO-RELEASE.md
│   └── TROUBLESHOOTING.md
└── README.md
```

## Important architecture decision

This repository intentionally does **not** contain application source code.

The EEMS repository performs:

```text
React/FastAPI source
       ↓
Tests
       ↓
Docker build
       ↓
Docker Hub push
       ↓
release image tag
```

This repository performs:

```text
Helm/Kubernetes validation
       ↓
Git commit with image tag
       ↓
Argo CD
       ↓
Kubernetes rolling deployment
```

That separation prevents duplicated application source and is a realistic GitOps multi-repository model.

## Local Docker Compose

```bash
cp docker/.env.example docker/.env
# edit docker/.env with real values

cd docker
docker compose up -d

docker compose ps
```

Access:
- Frontend: `http://localhost:3000`
- Backend health: `http://localhost:8000/api/health`

## Kubernetes with plain manifests

```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/config/app-config.yaml
kubectl apply -f kubernetes/storage/uploads-pvc.yaml

# Create a real secret locally. Never commit secret.yaml.
copy kubernetes/backend/secret.example.yaml kubernetes/backend/secret.yaml
# edit the secret

kubectl apply -f kubernetes/backend/deployment.yaml
kubectl apply -f kubernetes/backend/service.yamlsecret.yaml
kubectl apply -f kubernetes/backend/deployment.yaml
kubectl apply -f kubernetes/backend/service.yaml
kubectl apply -f kubernetes/frontend/
kubectl apply -f kubernetes/ingress/

kubectl get all -n nexops
kubectl get pvc -n nexops
```

## Kubernetes with Helm

For local learning, a pre-created Secret is preferred:

```bash
helm lint helm/nexops
helm template nexops helm/nexops --namespace nexops
helm upgrade --install nexops helm/nexops   --namespace nexops   --create-namespace
```

Create `nexops-backend-secret` before the Helm install because the default chart intentionally references an externally managed Secret:

```yaml
backend:
  secret:
    create: false
```

This avoids committing credentials into Git. In a stronger production implementation, use an
external secret manager such as AWS Secrets Manager + External Secrets Operator or SOPS.

## HPA

HPA requires Kubernetes Metrics Server:

```bash
kubectl top nodes
kubectl top pods -n nexops
kubectl get hpa -n nexops
```

If metrics are unavailable, HPA cannot calculate CPU utilization.

## GitOps with Argo CD

```bash
kubectl apply -f argocd/application.yaml
kubectl get applications -n argocd
```

Argo CD watches `main` and reconciles `helm/nexops`.

## CI

GitHub Actions validates:

1. Helm lint
2. Helm rendering
3. Kubernetes manifests

Jenkins provides the equivalent enterprise validation pipeline.

## Release

Update one image at a time:

```bash
bash scripts/update-image-tag.sh backend v1.2
git add helm/nexops/values.yaml
git commit -m "release: backend v1.2"
git push
```

Then:

```text
GitHub
  ↓
Actions validation
  ↓
Argo CD detects Git change
  ↓
Helm release
  ↓
Kubernetes rolling update
```

## Rollback

GitOps rollback:

```bash
git revert <release-commit>
git push
```

Or inspect Argo CD/Helm history and return the Helm values to the previous known-good image tag.

## Security rules

- Never commit `.env`.
- Never commit `kubernetes/backend/secret.yaml`.
- Never put real database passwords in `values.yaml`.
- Use short-lived Docker Hub access tokens.
- Prefer immutable image tags for production releases.
- Use a managed external PostgreSQL service instead of a database pod in this cluster.

## Interview explanation

> "I separated the application repository from the DevOps repository. The application CI
builds and scans the React and FastAPI images and publishes them to Docker Hub. The DevOps
repository is the desired-state repository: GitHub Actions and Jenkins validate Helm and
Kubernetes configuration and scan the exact release images. Argo CD continuously watches the
Helm chart and reconciles Kubernetes. Secrets are not stored in Git, uploads use a PVC, and HPA
provides horizontal scaling when Metrics Server is available."

## Setup order\n\nSee `SETUP-ORDER.md` for the exact clean deployment sequence.\n\n## Troubleshooting

See:
- `docs/TROUBLESHOOTING.md`
- `docs/CI-CD.md`
- `docs/ARCHITECTURE.md`
- `docs/HOW-TO-RELEASE.md`
