# Helm Deploy Preview Plugin

## Overview
The `helm-deploy-preview` plugin creates a temporary, isolated preview environment for Helm chart deployments. It deploys your chart in a unique Kubernetes namespace, lets you test changes, and automatically cleans up the environment after a configurable timeout.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/deploy-preview)](https://artifacthub.io/packages/search?repo=deploy-preview)

## Features
- Generates a unique namespace (e.g. `preview-20250610-0125`) based on the current timestamp.
- Deploys the chart with a matching unique release name to avoid conflicts.
- Schedules automatic cleanup after a configurable timeout (default: 30 minutes).
- Supports custom `values.yaml` files via `--values`.
- Validates inputs: chart path existence, namespace prefix safety, numeric timeout.
- Checks for both `helm` and `kubectl` at install time.

## Requirements
- **kubectl**: Required to create and manage Kubernetes namespaces.
- **helm**: Must be installed and configured to interact with your cluster.
- A working Kubernetes cluster with permissions to create namespaces and deploy resources.

## Limitations
- The background cleanup process will not run if the terminal session is closed. Use `helm deploy-preview cleanup <namespace>` for reliable manual deletion.
- Namespace names are timestamp-based; deploying twice within the same minute will produce a conflict. In that case, wait a minute or delete the first namespace manually.

## Installation

### Prerequisites
Verify that `helm` and `kubectl` are installed:
```
helm version
kubectl version
```

### Install from GitHub
```
helm plugin install https://github.com/fadedreams/helm-deploy-preview
```

### Manual install from local clone
```
git clone https://github.com/fadedreams/helm-deploy-preview.git
cd helm-deploy-preview
helm plugin install .
helm plugin list
```

## Usage

### Deploy a preview environment
```
helm deploy-preview <chart-path> [--values <file>] [--timeout <minutes>]
```

| Argument / Flag | Description | Default |
|---|---|---|
| `<chart-path>` | Path to your Helm chart directory | required |
| `--values <file>` | Custom values file | `values.yaml` in current dir (if present) |
| `--timeout <minutes>` | Minutes until automatic cleanup | `30` |

**Example:**
```
helm deploy-preview ./couponService --values custom-values.yaml --timeout 60
```

**Output:**
```
Creating namespace: preview-20250610-0125
Deploying chart: ./couponService
Preview deployed in namespace: preview-20250610-0125
Run 'kubectl get pods -n preview-20250610-0125' to check status.
Preview will be deleted automatically at 02:25 AM PDT on June 10, 2025.

Useful commands:
  kubectl get pods -n preview-20250610-0125
  kubectl logs -n preview-20250610-0125 <pod-name>
  helm deploy-preview cleanup preview-20250610-0125
```

### Clean up a preview environment
```
helm deploy-preview cleanup <namespace>
```

Only namespaces starting with `preview-` can be deleted via this command, as a safety guardrail.

**Example:**
```
helm deploy-preview cleanup preview-20250610-0125
```

**Output:**
```
Namespace preview-20250610-0125 cleaned up
```
