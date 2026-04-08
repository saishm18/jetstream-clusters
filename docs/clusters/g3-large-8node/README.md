# g3.large 8-Node GPU Cluster

This document is the operational README for the `codex/g3-large-8node` branch.

## Intended Shape

- `1` master
- `8` GPU workers
- worker flavor: `g3.large`
- same shared Terraform and Ansible layout as the CPU branch

## Purpose

- validate the schedulable Jetstream2 GPU flavor
- scale the currently working `1 + 1` GPU proof cluster to `1 + 8`
- run GPU-capable benchmark and HPL-related experiments
- compare the scaled GPU branch against the CPU baseline on `main`

## What Has Already Been Proven On The Current GPU Validation Branch

On the current `1 master + 1 g3.large worker` setup:

- Terraform deploy works
- SSH works
- MPI works
- Ansible reaches both nodes
- NVIDIA driver works
- CUDA toolkit works
- CUDA smoke test reports:
  - `GPU count: 1`
  - `GPU 0: GRID A100X-20C`

## Known Requirements For This Branch

- keep `g3.large` as the worker flavor
- keep a smaller CPU master unless scaling proves it is insufficient
- keep GPU-specific Ansible setup separate from CPU-only benchmark assumptions
- preserve the CUDA compatibility setup that fixed the toolkit/driver mismatch

## First Tasks When This Branch Is Expanded

- resize Terraform from `1` GPU worker to `8`
- update Ansible inventory and host templates to the `1 + 8` shape
- rerun GPU bootstrap
- rerun CUDA smoke on all workers
- choose and run the first real GPU benchmark

## Current Deployment State

Current documented cluster shape:

- `1` master
- `8` workers
- worker flavor `g3.large`
- management and MPI addressing are derived from Terraform outputs and the generated inventory

## Cluster Validation Commands

Run these from the repo root after `terraform apply`.

Check the built-in cloud-init verification log:

```bash
MASTER_IP="$(terraform output -raw master_floating_ip)"
ssh-keygen -R "$MASTER_IP"
ssh -i cluster.key rocky@"$MASTER_IP" 'tail -n +1 /home/rocky/cluster-verify.log'
```

Run a direct MPI smoke test from the master:

```bash
MASTER_IP="$(terraform output -raw master_floating_ip)"
ssh -i cluster.key rocky@"$MASTER_IP" 'source /etc/profile.d/openmpi.sh && mpirun --mca btl_tcp_if_include enp3s0 --mca oob_tcp_if_include enp3s0 -np 9 --host master-mpi,worker1-mpi,worker2-mpi,worker3-mpi,worker4-mpi,worker5-mpi,worker6-mpi,worker7-mpi,worker8-mpi hostname'
```

Check GPU visibility across all workers:

```bash
MASTER_IP="$(terraform output -raw master_floating_ip)"
ssh -i cluster.key rocky@"$MASTER_IP" 'for h in worker1 worker2 worker3 worker4 worker5 worker6 worker7 worker8; do echo "== $h =="; ssh $h "nvidia-smi --query-gpu=name,driver_version --format=csv,noheader"; done'
```

Run the CUDA smoke helper across all workers:

```bash
MASTER_IP="$(terraform output -raw master_floating_ip)"
ssh -i cluster.key rocky@"$MASTER_IP" 'for h in worker1 worker2 worker3 worker4 worker5 worker6 worker7 worker8; do echo "== $h =="; ssh $h "/home/rocky/run-gpu-smoke.sh"; done'
```

Build the first real GPU benchmark:

```bash
cd ansible
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 ansible-playbook -i inventory.ini playbooks/build-nccl-tests.yml
```

Run the first NCCL benchmark:

```bash
MASTER_IP="$(terraform output -raw master_floating_ip)"
ssh -i cluster.key rocky@"$MASTER_IP" 'mkdir -p /home/rocky/results && /home/rocky/run-nccl-tests.sh | tee /home/rocky/results/nccl-all-reduce-first-run.txt'
```

Build CUDA microbenchmarks:

```bash
cd ansible
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 ansible-playbook -i inventory.ini playbooks/build-cuda-bench.yml
```

Run CUDA microbenchmarks across all workers:

```bash
MASTER_IP="$(terraform output -raw master_floating_ip)"
ssh -i cluster.key rocky@"$MASTER_IP" '/home/rocky/run-cuda-bench.sh'
```

## Current Validation Results

What has already passed on the current `1 + 8` deployment:

- management network ping from the master to all workers
- MPI network ping from the master to all workers
- SSH hostname checks from the master to all workers
- worker management addresses and MPI addresses are configured correctly
- CUDA smoke test works on all workers
- CUDA microbenchmark path is available for per-worker GPU performance numbers

Important benchmarking note:

- GPU counts are not uniform across workers
- for the first benchmarkable cluster-wide GPU result, use `1 GPU per node`
- that keeps the first NCCL result defensible and comparable across all 8 workers
- NCCL collectives currently fail on this vGPU environment with `operation not supported`, so CUDA per-worker benchmarks are the current reliable GPU result path

## CUDA Microbenchmark Results

Screenshots for this run:

- [assets/cluster-active-instances.png](assets/cluster-active-instances.png)
- [assets/cuda-microbench-8node-run-1.png](assets/cuda-microbench-8node-run-1.png)
- [assets/cuda-microbench-8node-run-2.png](assets/cuda-microbench-8node-run-2.png)

Per-worker results from the CUDA microbenchmark:

| Worker | Visible GPUs | HostToDevice GB/s | DeviceToHost GB/s | SAXPY GFLOPS |
|---|---:|---:|---:|---:|
| worker1 | 1 | 12.87 | 12.21 | 207.11 |
| worker2 | 2 | 6.50 | 10.14 | 207.21 |
| worker3 | 3 | 7.11 | 4.88 | 203.90 |
| worker4 | 2 | 13.10 | 8.82 | 207.20 |
| worker5 | 1 | 13.24 | 12.40 | 206.75 |
| worker6 | 1 | 9.59 | 5.72 | 203.77 |
| worker7 | 2 | 14.45 | 13.54 | 205.20 |
| worker8 | 1 | 11.29 | 8.71 | 201.07 |

Summary:

- best observed per-worker SAXPY result: `207.21 GFLOPS` on `worker2`
- average per-worker SAXPY result: `205.28 GFLOPS`
- estimated 8-worker cluster total at `1 GPU per node`: `1642.21 GFLOPS` or about `1.64 TFLOPS`

Important note about the estimated total:

- this `1.64 TFLOPS` figure is an estimate derived by summing independent per-worker CUDA microbenchmark results
- it is not a synchronized full-cluster GPU collective benchmark
- we are reporting it this way because NCCL multi-node collectives fail in this Jetstream2 vGPU environment with `operation not supported`
- so the estimate is useful as a practical cluster capability indicator, but it should be labeled as estimated in any GitHub summary

Observed latency profile from the built-in verification log:

- management network:
  - roughly `0.7 ms` to `2.7 ms`
- MPI network:
  - roughly `0.9 ms` to `3.5 ms`

The built-in MPI sanity stage reached remote host startup on all nodes, but the final result should still be confirmed with the direct manual MPI smoke command above.

## Required Documentation Updates During Scale-Out

- record schedulability issues, if any
- record final master flavor decision
- record benchmark commands
- record benchmark throughput and efficiency

## Benchmark Artifacts

Store GPU benchmark evidence under:

- `docs/clusters/g3-large-8node/assets/cluster-topology.png`
- `docs/clusters/g3-large-8node/assets/gpu-smoke-output.txt`
- `docs/clusters/g3-large-8node/assets/hpl-output.txt`
- `docs/clusters/g3-large-8node/assets/top-speed.png`
- `docs/clusters/g3-large-8node/assets/efficiency-notes.md`

When results are available, embed the key images directly in this README so GitHub shows:

- the working cluster
- top speed
- efficiency summary
- main problems encountered and the fixes used

Example image embeds for GitHub:

```md
![Cluster Topology](assets/cluster-topology.png)
![Top Speed](assets/top-speed.png)
```
