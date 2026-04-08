# g3.xlarge 8-Node GPU Cluster

This document is the placeholder operational README for the future `codex/g3-xlarge-8node` branch.

## Intended Shape

- `1` master
- `8` GPU workers
- worker flavor: `g3.xlarge`

## Purpose

- keep the same layout and workflow as the `g3.large` branch
- change only the flavor-specific sizing, benchmark assumptions, and any GPU-stack adjustments required for `g3.xlarge`

## Current Status

- not deployed yet
- not validated yet
- should only be created after the `g3.large` branch is stable and repeatable

## Branch Rules

- start from the same shared repository layout used by `main` and `codex/g3-large-8node`
- keep a separate branch-specific README
- record any placement limits, quota issues, or driver/toolkit differences independently

## Planned Work

- verify that `g3.xlarge` is schedulable in Jetstream2 at the time of deployment
- validate driver, CUDA toolkit, and MPI stack
- bring the cluster to the same benchmark-ready state as the `g3.large` branch
- record scaled benchmark results separately from `g3.large`

## Benchmark Artifacts

Store future evidence under:

- `docs/clusters/g3-xlarge-8node/assets/cluster-topology.png`
- `docs/clusters/g3-xlarge-8node/assets/gpu-smoke-output.txt`
- `docs/clusters/g3-xlarge-8node/assets/hpl-output.txt`
- `docs/clusters/g3-xlarge-8node/assets/top-speed.png`
- `docs/clusters/g3-xlarge-8node/assets/efficiency-notes.md`
