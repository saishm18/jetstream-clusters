# CPU Baseline Cluster

This document is the target operational README for the `main` branch.

## Intended Shape

- `1` master
- normal CPU worker cluster
- dedicated access, management, and MPI networks

The exact worker count and flavor can evolve as CPU tuning continues, but `main` should remain the stable CPU branch.

## Purpose

- maintain the non-GPU reference cluster
- run CPU HPL benchmarks
- tune HPL parameters and measure maximum practical efficiency
- use the result as the baseline against GPU branches

## Validated Results So Far

Small-node validated HPL result from the earlier CPU baseline work:

- `N = 12000`
- `NB = 128`
- `P = 2`
- `Q = 2`
- `Time = 7.97 s`
- `Performance = 144.53 GFLOPS`
- residual check: `PASSED`

## Files To Keep Stable On `main`

- Terraform topology files
- cloud-init for the CPU cluster
- Ansible HPL preparation and build flow
- benchmark tuning notes for CPU-only runs

## Planned Next Work On `main`

- rerun HPL on the current CPU cluster shape
- tune `N`, `NB`, and process grid
- record best sustained result
- document the highest observed efficiency

## Benchmark Artifacts

Store CPU benchmark evidence under:

- `docs/clusters/cpu-baseline/assets/cluster-topology.png`
- `docs/clusters/cpu-baseline/assets/hpl-output.txt`
- `docs/clusters/cpu-baseline/assets/top-speed.png`
- `docs/clusters/cpu-baseline/assets/efficiency-notes.md`

Use the README to embed the important images once they exist.
