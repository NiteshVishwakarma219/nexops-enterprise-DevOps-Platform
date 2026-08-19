# Release Workflow

## 1. Build in the EEMS application repository

The application repository owns Dockerfiles and application source.

```bash
docker build -t cloudwithnitesh/nexops-backend:v1.2 ./backend
docker build -t cloudwithnitesh/nexops-frontend:v1.2 ./frontend
docker push cloudwithnitesh/nexops-backend:v1.2
docker push cloudwithnitesh/nexops-frontend:v1.2
```


## 2. Update this repository

```bash
bash scripts/update-image-tag.sh backend v1.2
bash scripts/update-image-tag.sh frontend v1.2
git add helm/nexops/values.yaml
git commit -m "release: backend=v1.2 frontend=v1.2"
git push origin main
```

## 3. Automated validation

GitHub Actions:

- Helm lint
- Helm template
- Kubernetes schema validation

Jenkins can perform the same validation in a self-hosted CI environment.

## 4. GitOps deployment

Argo CD detects the Git change and reconciles the Helm release.

Monitor:

```bash
kubectl get pods -n nexops -w
kubectl rollout status deployment/nexops-backend -n nexops
kubectl rollout status deployment/nexops-frontend -n nexops
```

## 5. Rollback

Revert the release commit:

```bash
git revert <release-commit>
git push origin main
```

Argo CD then returns the cluster to the previous desired state.
