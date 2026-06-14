#!/bin/bash
set -euo pipefail

NAMESPACE="${1:-}"

if [[ -z "$NAMESPACE" ]]; then
    echo "Error: please specify a namespace to clean up"
    echo "Usage: helm deploy-preview cleanup <namespace>"
    exit 1
fi

if [[ "$NAMESPACE" != preview-* ]]; then
    echo "Error: '$NAMESPACE' does not look like a preview namespace (must start with 'preview-')"
    exit 1
fi

kubectl delete namespace "$NAMESPACE" --ignore-not-found
echo "Namespace $NAMESPACE cleaned up"
