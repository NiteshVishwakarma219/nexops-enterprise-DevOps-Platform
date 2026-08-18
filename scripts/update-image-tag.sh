#!/usr/bin/env bash
# update-image-tag.sh
# Updates backend OR frontend image tag independently in helm/nexops/values.yaml.
# Usage:
#   bash scripts/update-image-tag.sh backend v1.2
#   bash scripts/update-image-tag.sh frontend v1.3
set -euo pipefail

SERVICE="${1:-}"
NEW_TAG="${2:-}"

if [[ -z "$SERVICE" || -z "$NEW_TAG" ]]; then
  echo "Usage: bash scripts/update-image-tag.sh <backend|frontend> <new-tag>"
  exit 1
fi

if [[ "$SERVICE" != "backend" && "$SERVICE" != "frontend" ]]; then
  echo "ERROR: service must be 'backend' or 'frontend'"
  exit 1
fi

VALUES="helm/nexops/values.yaml"

awk -v svc="$SERVICE" -v tag="$NEW_TAG" '
  /repository: cloudwithnitesh\/nexops-/ { in_svc = index($0, "nexops-" svc) > 0 }
  in_svc && /^    tag:/ { print "    tag: \"" tag "\""; in_svc=0; next }
  { print }
' "$VALUES" > "${VALUES}.tmp" && mv "${VALUES}.tmp" "$VALUES"

echo "Updated $SERVICE tag to $NEW_TAG in $VALUES"
echo ""
echo "Next steps:"
echo "  git add helm/nexops/values.yaml"
echo "  git commit -m \"release: $SERVICE $NEW_TAG\""
echo "  git push"
echo "  → CI validates → Argo CD auto-deploys"
