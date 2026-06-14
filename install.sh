#!/bin/bash
set -euo pipefail

MISSING=()

if ! command -v kubectl &>/dev/null; then
    MISSING+=("kubectl")
fi

if ! command -v helm &>/dev/null; then
    MISSING+=("helm")
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "Error: the following required tools are missing: ${MISSING[*]}"
    echo "Please install them before using this plugin."
    exit 1
fi

echo "deploy-preview installed successfully"
