#!/bin/bash
set -euo pipefail

CHART_PATH=""
VALUES_FLAG=""
TIMEOUT_MINUTES=30
SUBCOMMAND=""

usage() {
    echo "Usage:"
    echo "  helm deploy-preview <chart-path> [--values <file>] [--timeout <minutes>]"
    echo "  helm deploy-preview cleanup <namespace>"
    echo ""
    echo "Options:"
    echo "  --values    Path to a custom values.yaml file"
    echo "  --timeout   Minutes before automatic cleanup (default: 30)"
    exit 1
}

# Parse subcommand
if [[ "${1:-}" == "cleanup" ]]; then
    SUBCOMMAND="cleanup"
    NAMESPACE="${2:-}"
    if [[ -z "$NAMESPACE" ]]; then
        echo "Error: cleanup requires a namespace argument"
        echo "Usage: helm deploy-preview cleanup <namespace>"
        exit 1
    fi
    if [[ "$NAMESPACE" != preview-* ]]; then
        echo "Error: '$NAMESPACE' does not look like a preview namespace (must start with 'preview-')"
        exit 1
    fi
    kubectl delete namespace "$NAMESPACE" --ignore-not-found
    echo "Namespace $NAMESPACE cleaned up"
    exit 0
fi

# Parse deploy arguments
if [[ $# -eq 0 ]]; then
    usage
fi

CHART_PATH="$1"
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        --values)
            VALUES_FLAG="--values ${2:?'--values requires a file path'}"
            shift 2
            ;;
        --timeout)
            TIMEOUT_MINUTES="${2:?'--timeout requires a number of minutes'}"
            if ! [[ "$TIMEOUT_MINUTES" =~ ^[0-9]+$ ]]; then
                echo "Error: --timeout must be a positive integer"
                exit 1
            fi
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
done

# Validate chart path
if [[ ! -d "$CHART_PATH" ]]; then
    echo "Error: chart path '$CHART_PATH' does not exist or is not a directory"
    exit 1
fi

# Fall back to values.yaml in current dir if no --values given
if [[ -z "$VALUES_FLAG" && -f "values.yaml" ]]; then
    VALUES_FLAG="--values values.yaml"
fi

TIMESTAMP=$(date +%Y%m%d-%H%M)
NAMESPACE="preview-${TIMESTAMP}"
RELEASE_NAME="preview-${TIMESTAMP}"

echo "Creating namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE"

echo "Deploying chart: $CHART_PATH"
helm install "$RELEASE_NAME" "$CHART_PATH" $VALUES_FLAG --namespace "$NAMESPACE"

CLEANUP_TIME=$(date -d "+${TIMEOUT_MINUTES} minutes" "+%I:%M %p %Z on %B %d, %Y" 2>/dev/null \
    || date -v "+${TIMEOUT_MINUTES}M" "+%I:%M %p %Z on %B %d, %Y" 2>/dev/null \
    || echo "in ${TIMEOUT_MINUTES} minutes")

echo ""
echo "Preview deployed in namespace: $NAMESPACE"
echo "Run 'kubectl get pods -n $NAMESPACE' to check status."
echo "Preview will be deleted automatically at ${CLEANUP_TIME}."
echo ""
echo "Useful commands:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl logs -n $NAMESPACE <pod-name>"
echo "  helm deploy-preview cleanup $NAMESPACE"

# Background cleanup
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
( sleep "$TIMEOUT_SECONDS" && kubectl delete namespace "$NAMESPACE" --ignore-not-found \
    && echo "Auto-cleanup: namespace $NAMESPACE deleted" ) &
disown $!
