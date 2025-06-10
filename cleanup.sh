#!/bin/bash
NAMESPACE=$1
if [ -n "$NAMESPACE" ]; then
    kubectl delete namespace $NAMESPACE --ignore-not-found
    echo "Namespace $NAMESPACE cleaned up"
else
    echo "Please specify a namespace to clean up"
fi
