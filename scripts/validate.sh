#!/usr/bin/env bash
set -euo pipefail

echo "== Helm lint =="
helm lint helm/nexops

echo "== Helm render =="
helm template nexops helm/nexops --namespace nexops --set backend.secret.create=true   --set backend.secret.DATABASE_URL=ci-placeholder   --set backend.secret.DIRECT_URL=ci-placeholder   --set backend.secret.JWT_SECRET=ci-placeholder   --set backend.secret.ADMIN_KEY=ci-placeholder

echo "Validation completed."
