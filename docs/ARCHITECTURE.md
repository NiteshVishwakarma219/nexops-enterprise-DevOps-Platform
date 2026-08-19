# Enterprise DevOps & Kubernetes Platform Architecture

The application source code remains in the separate EEMS repository. This repository owns
container runtime configuration, Kubernetes manifests, Helm, CI validation/security checks,
Jenkins, and Argo CD GitOps.

## Release flow

1. EEMS application repository builds frontend/backend Docker images.
2. Images are tagged and pushed to Docker Hub.
3. This repository updates `helm/nexops/values.yaml` with the immutable release tags.
4. GitHub Actions and/or Jenkins validate manifests, lint Helm,.
5. Argo CD watches `main` and reconciles the Helm release.
6. Kubernetes performs a rolling update.
7. HPA can scale the backend/frontend when Metrics Server is installed.
8. Rollback is performed by reverting the image tag commit or using Helm/Argo CD history.

## Why no PostgreSQL pod?

PostgreSQL is an external managed service for this portfolio workload. Running a database
inside the application cluster would add stateful database operations that are better
demonstrated separately with AWS RDS in Project 1.

## Persistent uploads

Application uploads are mounted at `/uploads` through a PVC. For a multi-node production
cluster, use a shared storage class such as EFS rather than relying on a single-node local volume.
