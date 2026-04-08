# Roadmap

This file tracks planned improvements that should land as later versions of the cluster stack rather than being mixed into the first publishable baseline.

## Planned Improvements

### CephFS Integration

Target outcome:

- mount shared storage across cluster nodes
- support common dataset and benchmark input paths
- keep storage setup optional and branch-aware

Expected implementation areas:

- Terraform variables for CephFS-related inputs
- Ansible role or playbook for client-side mount configuration
- branch-specific documentation for storage-enabled clusters

Recommended delivery model:

- ship as a later enhancement after the base CPU and GPU branches are stable
- document it as a new version or improvement, not as part of the initial public baseline

### Prometheus Monitoring

Target outcome:

- collect node health, GPU telemetry, and benchmark-time system metrics
- support comparison across CPU and GPU cluster variants

Expected implementation areas:

- node exporter deployment
- GPU telemetry exporter if supported in the target environment
- Prometheus scrape config and dashboards
- benchmark artifact capture tied to monitored runs

Recommended delivery model:

- add after the cluster provisioning and benchmark flows are stable
- publish as a later improvement or monitoring-enabled version of the cluster stack

## Branch Compatibility Goal

Future improvements should preserve the same overall repository model:

- `main` for CPU baseline
- `codex/g3-large-8node` for the current GPU branch
- `codex/g3-xlarge-8node` for the future larger GPU branch

Where possible, add shared functionality in common Terraform or Ansible files and document branch-specific differences in the cluster READMEs.
