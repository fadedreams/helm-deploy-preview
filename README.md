# Helm Deploy Preview Plugin

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/deploy-preview)](https://artifacthub.io/packages/search?repo=deploy-preview)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

## Overview

The `helm-deploy-preview` plugin creates a temporary, isolated preview environment for Helm chart deployments. It deploys your chart in a unique Kubernetes namespace, lets you test changes, and automatically cleans up the environment after a configurable timeout.

## Features

- Generates a unique namespace based on the current timestamp (for example, `preview-20250610-0125`).

- Deploys the chart with a matching unique release name to avoid conflicts.

- Schedules automatic cleanup after a configurable timeout (30 minutes by default).

- Supports custom `values.yaml` files with `--values`.

- Validates inputs, including chart path existence, namespace prefix safety, and numeric timeout values.

- Checks for both `helm` and `kubectl` at install time.

## Requirements

- **kubectl** — required to create and manage Kubernetes namespaces.

- **Helm** — must be installed and configured to interact with your cluster.

- A working Kubernetes cluster with permissions to create namespaces and deploy resources.

- A POSIX shell (Linux, macOS, or WSL on Windows).

## Installation

### Prerequisites

Verify that `helm` and `kubectl` are installed:

```bash
helm version
kubectl version
```

### Install from GitHub

```bash
helm plugin install https://github.com/fadedreams/helm-deploy-preview
```

**Helm 4:** Plugins installed from Git are not signed, and Helm 4 verifies plugins by default. The command above may fail with `plugin source does not support verification`. Add `--verify=false`:

```bash
helm plugin install https://github.com/fadedreams/helm-deploy-preview --verify=false
```

To install a specific release, add `--version`:

```bash
helm plugin install https://github.com/fadedreams/helm-deploy-preview --version v1.0.0
```

### Manual install from a local clone

```bash
git clone https://github.com/fadedreams/helm-deploy-preview.git
cd helm-deploy-preview
helm plugin install .
helm plugin list
```

### Update

```bash
helm plugin update deploy-preview
```

### Uninstall

```bash
helm plugin uninstall deploy-preview
```

## Usage

### Deploy a preview environment

```bash
helm deploy-preview <chart-path> [--values <file>] [--timeout <minutes>]
```

| Argument or flag | Description | Default |
| --- | --- | --- |
| `<chart-path>` | Path to your Helm chart directory | Required |
| `--values <file>` | Custom values file | `values.yaml` in the current directory, if present |
| `--timeout <minutes>` | Minutes until automatic cleanup | `30` |

**Example:**

```bash
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

```bash
helm deploy-preview cleanup <namespace>
```

Only namespaces starting with `preview-` can be deleted with this command, as a safety guardrail.

**Example:**

```bash
helm deploy-preview cleanup preview-20250610-0125
```

**Output:**

```
Namespace preview-20250610-0125 cleaned up
```

## Limitations

- The background cleanup process will not run if the terminal session is closed. For reliable manual deletion, use `helm deploy-preview cleanup <namespace>`.

- Namespace names are timestamp-based, so deploying twice within the same minute will produce a conflict. Wait a minute or delete the first namespace manually before retrying.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `plugin source does not support verification` | You are on Helm 4. Re-run the install with `--verify=false`. |
| `unknown command "deploy-preview" for "helm"` | The plugin is not installed. Check `helm plugin list` and reinstall. |
| `namespace ... already exists` | You deployed twice in the same minute. Wait a minute, or run `helm deploy-preview cleanup <namespace>`. |
| Preview was not deleted automatically | The terminal session that started it was closed. Run `helm deploy-preview cleanup <namespace>`. |

## Releases

Releases are tagged `vX.Y.Z`. The tag must match the `version` field in `plugin.yaml`. Pushing a tag runs the release workflow, which creates the GitHub release.

## Contributing

Issues and pull requests are welcome. Shell scripts are checked with [ShellCheck](https://www.shellcheck.net/) in CI, so run it locally before opening a pull request:

```bash
shellcheck -S warning ./*.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE).
