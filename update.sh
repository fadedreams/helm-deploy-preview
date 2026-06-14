#!/bin/bash
PLUGIN_VERSION=$(grep '^version:' "$HELM_PLUGIN_DIR/plugin.yaml" | awk '{print $2}' | tr -d '"')
echo "deploy-preview updated to version ${PLUGIN_VERSION}"
