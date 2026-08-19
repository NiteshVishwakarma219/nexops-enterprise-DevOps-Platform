# CI/CD Design

## Important separation of responsibilities

This DevOps repository does not contain the EEMS source code, so it cannot legitimately run
`docker build` against the application source. The build stage belongs to the EEMS application
repository.

### Application repository
- test frontend/backend
- docker build
- docker push
- publish release tag

### DevOps repository
- Helm lint/template validation
- Kubernetes manifest validation
- GitOps configuration
- Argo CD deployment
- rollback through Git

This is the normal multi-repository GitOps model used by many teams.

## Jenkins

`jenkins/Jenkinsfile` performs the same deployment-repository validation and image-security checks.
It is intentionally not a second Docker build system for an application whose source is elsewhere.

## CI/CD ownership

The EEMS application repository should own the image-build workflow. This repository must not
pretend to build application images without the application source. The DevOps pipeline validates
the deployment artifacts and scans the exact image references declared in Helm.
