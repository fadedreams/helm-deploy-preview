#!/bin/bash
if ! command -v kubectl &>/dev/null; then
    echo "kubectl is required to run this plugin"
    exit 1
fi
echo "deploy-preview installed successfully"
