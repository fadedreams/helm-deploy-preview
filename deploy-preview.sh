#!/bin/bash

# Generate a unique namespace (e.g., preview-20250601-0856)
TIMESTAMP=$(date +%Y%m%d-%H%M)
NAMESPACE="preview-${TIMESTAMP}"
CHART_PATH=$1
VALUES=""
if [ -f "values.yaml" ]; then
    VALUES="--values values.yaml"
fi

# Create namespace
kubectl create namespace $NAMESPACE

# Deploy chart with a unique release name
helm install preview-$NAMESPACE $CHART_PATH $VALUES --namespace $NAMESPACE

# Output details
echo "Preview deployed in namespace: $NAMESPACE"
echo "Run 'kubectl get pods -n $NAMESPACE' to check status."
echo "Preview will be deleted automatically in 30 minutes (adjust with --timeout)."

# Schedule cleanup (e.g., using kubectl to delete after timeout)
sleep 1800 && kubectl delete namespace $NAMESPACE &
