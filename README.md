# IndySCC Jetstream2 Cluster

This repository is one shared Terraform + Ansible codebase for multiple Jetstream2 cluster variants.

The intended GitHub structure is:

- `main`
  - stable CPU cluster baseline
  - HPL tuning and efficiency work for normal clusters
- `codex/g3-large-8node`
  - `1` master + `8` `g3.large` GPU workers
  - separate benchmark notes and GPU-specific validation
- `codex/g3-xlarge-8node`
  - future `1` master + `8` `g3.xlarge` GPU workers
  - same layout as the `g3.large` branch, with flavor-specific changes only

The code layout stays the same across branches. What changes per branch is:

- Terraform sizing and flavor defaults
- Ansible benchmark/toolchain defaults
- branch-specific deployment notes

## Repository Layout

- [README.md](README.md)
  - top-level repo and branch model
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
  - issues encountered and exact fixes
- [docs/clusters/cpu-baseline/README.md](docs/clusters/cpu-baseline/README.md)
  - `main` branch target and CPU HPL baseline
- [docs/clusters/g3-large-8node/README.md](docs/clusters/g3-large-8node/README.md)
  - GPU branch plan for the `g3.large` cluster
- [docs/clusters/g3-xlarge-8node/README.md](docs/clusters/g3-xlarge-8node/README.md)
  - placeholder for the future larger GPU branch
- [docs/ROADMAP.md](docs/ROADMAP.md)
  - future planned cluster capabilities such as CephFS and Prometheus

Core infrastructure files remain shared:

- [variables.tf](variables.tf)
- [instances.tf](instances.tf)
- [locals.tf](locals.tf)
- [cloudinit/master.yaml](cloudinit/master.yaml)
- [cloudinit/worker.yaml](cloudinit/worker.yaml)
- [ansible/playbooks/prepare-hpl.yml](ansible/playbooks/prepare-hpl.yml)
- [ansible/playbooks/build-hpl.yml](ansible/playbooks/build-hpl.yml)
- [ansible/playbooks/prepare-gpu.yml](ansible/playbooks/prepare-gpu.yml)

## Current Validated States

- CPU baseline cluster has already been deployed, verified, and used to run HPL successfully.
- Current GPU validation branch has already proven:
  - Terraform deployment works
  - MPI works across the dedicated MPI network
  - Ansible connectivity works
  - NVIDIA driver works on `g3.large`
  - CUDA toolkit + compatibility package works
  - CUDA smoke test sees the GPU

## Standard Workflow

1. Export Jetstream2 / OpenStack credentials.
2. Fill in `terraform.tfvars` with at least a valid `image_id`.
3. Ensure `cluster.key` and `cluster.pub` exist in the repo root.
4. Run `terraform init`.
5. Run `terraform plan` and `terraform apply`.
6. SSH to the master with `ssh -i cluster.key rocky@$(terraform output -raw master_floating_ip)`.
7. Check `/home/rocky/cluster-verify.log`.
8. Create `ansible/inventory.ini` from [ansible/inventory.ini.example](ansible/inventory.ini.example).
9. Run the branch-appropriate Ansible playbooks.
10. Record benchmark results in the matching cluster README.

## Branch Discipline

- Keep `main` focused on the normal CPU cluster.
- Keep GPU flavor work in separate `codex/...` branches.
- Keep the file layout identical across branches where possible.
- Put branch-specific operational notes in the matching file under `docs/clusters/...`.
- Put shared failure modes and fixes in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Publishing Rules

- Never commit `cluster.key`, `cluster.pub`, `terraform.tfvars`, `.env.*`, or `ansible/inventory.ini`.
- Do not hardcode live floating IPs, current worker IPs, or allocation-specific identifiers in GitHub-facing docs.
- Use `terraform output -raw master_floating_ip` and `ansible/inventory.ini.example` in examples instead of live values.
- Keep benchmark evidence under `docs/clusters/.../assets/` and avoid embedding anything that exposes credentials or active control endpoints.
