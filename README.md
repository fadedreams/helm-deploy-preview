# Helm Deploy Preview Plugin

## Overview
The `helm-deploy-preview` plugin creates a temporary, isolated preview environment for Helm chart deployments. It deploys your chart in a unique Kubernetes namespace, allows you to test changes (e.g., MySQL configurations, service ports), and automatically cleans up the environment after a set time or on manual command. This is ideal for testing updates without affecting production releases.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/deploy-preview)](https://artifacthub.io/packages/search?repo=deploy-preview)

## Features
- Automatically generates a unique namespace (e.g., `preview-YYYYMMDD-HHMM`) based on the current timestamp.
- Deploys the chart with a unique release name to avoid conflicts.
- Schedules automatic cleanup after the specified timeout (default 30 minutes).
- Supports custom `values.yaml` files for configuration (e.g., MySQL `rootPassword`, service ports).

## Requirements
- **kubectl**: Required to create and manage Kubernetes namespaces and resources.
- **helm**: Must be installed and configured to interact with your cluster.
- A working Kubernetes cluster with sufficient permissions to create namespaces and deploy resources.

## Limitations
- The cleanup timeout is currently backgrounded and may not execute if the terminal closes. Use the `cleanup` command for manual deletion if needed.
- No advanced flag parsing (e.g., `--timeout` is not yet implemented; use the default 30 minutes for now).
- Assumes `values.yaml` exists in the current directory unless overridden.

## Installation

### Prerequisites
Verify that `helm` and `kubectl` are installed and configured:
```
helm version
kubectl version
```
### Steps
Choose one of the following methods to install the plugin:
- **Direct Installation from GitHub**:
```
helm plugin install https://github.com/fadedreams/helm-deploy-preview
```
- **Manual Installation from Local Clone**:

1. Clone or download the plugin repository:
```
git clone https://github.com/fadedreams/helm-deploy-preview.git
cd helm-deploy-preview
```
2. Install the plugin:
```
helm plugin install .
```
3. Verify installation:
```
helm plugin list
```

## Usage

### Deploy a Preview Environment
Create a temporary preview environment for your Helm chart:
```
helm deploy-preview ./path-to-your-chart
```
- **Arguments**:
  - `./path-to-your-chart`: The local path to your Helm chart directory (e.g., `./couponService`).
- **Optional Flags**:
  - `--values values.yaml`: Specify a custom `values.yaml` file (defaults to `values.yaml` in the current directory if present).
  - `--timeout <minutes>`: Intended to set the cleanup timeout (not yet implemented; defaults to 30 minutes).

- **Example**:
```
helm deploy-preview ./couponService --values custom-values.yaml
```
This deploys the `couponService` chart in a namespace like `preview-20250610-0125` and cleans up after 30 minutes.

- **Output**:
Preview deployed in namespace: preview-20250610-0125
Run 'kubectl get pods -n preview-20250610-0125' to check status.
Preview will be deleted automatically at 01:55 AM PDT on June 10, 2025.
- **Next Steps**:
- Check pod status: `kubectl get pods -n preview-20250610-0125`
- View logs: `kubectl logs -n preview-20250610-0125 <pod-name>`
- Test services (e.g., MySQL at `docker-mysql.preview-20250610-0125.svc.cluster.local:3306`).

### Cleanup a Preview Environment
Manually delete a preview namespace if needed:
```
helm deploy-preview cleanup preview-20250610-0125
```
- **Arguments**:
  - `preview-20250610-0125`: The namespace to clean up (e.g., from the deployment output).
- **Output**:
Namespace preview-20250610-0125 cleaned up
