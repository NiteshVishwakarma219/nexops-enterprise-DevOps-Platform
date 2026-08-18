# Kubernetes Troubleshooting

## Pods Pending
```bash
kubectl get pods -n nexops
kubectl describe pod <pod> -n nexops
```
Check node capacity, image pull errors, PVC binding, and scheduling events.

## CrashLoopBackOff
```bash
kubectl logs deploy/nexops-backend -n nexops --previous
kubectl describe pod <pod> -n nexops
```
Verify database URLs, JWT secret, CORS values, and application startup logs.

## Readiness probe failing
```bash
kubectl exec deploy/nexops-backend -n nexops -- wget -qO- http://127.0.0.1:8000/api/health
```
If the image does not contain `wget`, test the endpoint with the application's available HTTP client
or temporarily inspect logs. The Kubernetes probe itself does not require wget.

## HPA shows unknown / metrics unavailable
Install Metrics Server and verify:
```bash
kubectl top pods -n nexops
kubectl get hpa -n nexops
```

## Ingress returns 404
Check:
```bash
kubectl get ingress -n nexops
kubectl describe ingress nexops-ingress -n nexops
kubectl get svc -n nexops
```
The `/api` path is intentionally NOT rewritten. The backend receives `/api/...`.

## Argo CD OutOfSync
```bash
kubectl get application nexops -n argocd
kubectl describe application nexops -n argocd
```
Confirm the Git revision, Helm values, namespace, and cluster health.

## Rollback
Preferred GitOps method:
```bash
git revert <release-commit>
git push
```
Argo CD then reconciles the previous image tag.
