# Troubleshooting

This file tracks the main issues encountered while bringing up CPU and GPU clusters on Jetstream2, along with the exact fix that worked.

## Terraform And OpenStack

### Missing image

Symptom:

- Terraform failed with `Can not find requested image`.

Cause:

- `image_id` in `terraform.tfvars` pointed to an image UUID that was no longer valid in the current Jetstream2 project.

Fix:

- update `image_id` in `terraform.tfvars`
- use a currently visible image, such as `Featured-RockyLinux10`

### Stale security group ID

Symptom:

- Terraform failed with `SecurityGroupNotFound`.

Cause:

- an old `egress_secgroup_id` value referenced a security group that no longer existed.

Fix:

- remove the stale value from `terraform.tfvars`
- keep Ceph-specific security inputs out of the stage-1 deployment unless they are actively needed

### IP address already allocated

Symptom:

- Terraform failed with `IpAddressAlreadyAllocated` for worker ports.

Cause:

- partial failed applies left ports behind in the project.

Fix:

- avoid manual deletion of managed resources unless state is already broken
- after partial failures, re-run Terraform with the corrected target shape so state and cloud resources converge cleanly

## Cloud-Init And SSH

### Cloud-init YAML parse failure from embedded private key

Symptom:

- `/home/rocky/cluster-verify.log` was missing
- `/var/log/cloud-init-output.log` showed YAML parse errors

Cause:

- multi-line private key content was rendered into cloud-init without proper indentation

Fix:

- indent multi-line rendered values before injecting them into the cloud-init template

### Host key changed after instance replacement

Symptom:

- local SSH failed with `REMOTE HOST IDENTIFICATION HAS CHANGED`

Cause:

- master instance was recreated and got a new host key

Fix:

- run `ssh-keygen -R <master_floating_ip>`
- reconnect and accept the new host key

### Verification script used SSH without the cluster key

Symptom:

- Terraform apply reached the verification step but failed with public-key authentication errors

Cause:

- `verify.tf` SSHed to the master without explicitly using `cluster.key`

Fix:

- update the verification command to use `-i cluster.key`

## MPI And Networking

### MPI blocked by firewalld

Symptom:

- SSH worked
- ping worked
- `mpirun` failed with PRTE daemon communication errors

Cause:

- `firewalld` was active on Rocky nodes and blocked MPI daemon traffic

Fix:

- disable `firewalld` on all nodes
- bake that into `cloudinit/master.yaml` and `cloudinit/worker.yaml`

### MPI hostnames worked over SSH but failed in cloud-init smoke test

Symptom:

- manual MPI launch worked
- cloud-init verification failed during the MPI smoke stage

Cause:

- the smoke test used `--prefix /usr/lib64/openmpi`
- on Rocky 10, `mpirun` lives under the OpenMPI prefix but `prted` is in `/usr/bin`

Fix:

- remove the hardcoded `--prefix`
- launch MPI with explicit interface selection instead:
  - `--mca btl_tcp_if_include enp3s0`
  - `--mca oob_tcp_if_include enp3s0`

### MPI needed hostname-based SSH config on the master

Symptom:

- master could reach worker IPs, but MPI launches via hostnames were inconsistent

Cause:

- the master SSH config did not trust the hostnames used in the MPI hostfile

Fix:

- render `~/.ssh/config` on the master with both hostname and IP-based matches

## Ansible

### Worker SSH through the master failed

Symptom:

- `ansible all -m ping` reached the master but workers were `UNREACHABLE`

Cause:

- inventory had stale workers and an old `ProxyCommand` master IP

Fix:

- keep `ansible/inventory.ini` aligned with the live cluster shape
- use a working jump-host `ProxyCommand`

### Removed callback plugin

Symptom:

- Ansible failed because `community.general.yaml` callback no longer existed

Cause:

- repo config was written for an older Ansible version

Fix:

- use the current built-in YAML/default callback settings in `ansible.cfg`

## HPL

### HPL build template was incomplete

Symptom:

- `make arch=...` looped or failed with malformed shell commands

Cause:

- the generated HPL makefile template missed required variables used by HPL's make system

Fix:

- supply the expected HPL variables and include paths
- keep the generated makefile in the HPL top-level directory where `make arch=...` expects it

### Parallel builds on tiny nodes were killed

Symptom:

- Ansible returned `rc=137` while building HPL on all nodes

Cause:

- small instances ran out of memory during concurrent compilation

Fix:

- build HPL only on the master
- distribute the built tree to workers afterward

### HPL sizing was too large for small instances

Symptom:

- initial HPL sizing assumptions were too aggressive for `m3.tiny`-class nodes

Fix:

- use a conservative starting point
- validated small-node profile:
  - `N = 12000`
  - `NB = 128`

## GPU Bring-Up

### `g3.xl` placement failed

Symptom:

- manual and Terraform launch attempts for `g3.xl` failed

Cause:

- Jetstream2 returned `No valid host was found. There are not enough hosts available.`

Fix:

- do not assume allocation SUs alone guarantee placement
- use `g3.large` as the currently schedulable GPU flavor

### `nvcc` missing by default on GPU instances

Symptom:

- `nvidia-smi` worked
- `nvcc` was not found

Cause:

- the Rocky image included the NVIDIA driver but not the CUDA toolkit

Fix:

- install the CUDA toolkit via the NVIDIA RHEL 10 repository from Ansible

### CUDA toolkit / driver mismatch

Symptom:

- CUDA sample compiled but failed at runtime with:
  - `CUDA driver version is insufficient for CUDA runtime version`

Cause:

- the worker had a driver compatible with CUDA `12.2`
- the available repository toolkit installed CUDA `13.2`

Fix that worked:

- install:
  - `cuda-toolkit-13-2`
  - `cuda-compat-13-2`
- export:
  - `PATH=/usr/local/cuda-13.2/bin:$PATH`
  - `LD_LIBRARY_PATH=/usr/local/cuda-13.2/compat:/usr/local/cuda-13.2/lib64:$LD_LIBRARY_PATH`
- validate with a small CUDA `cudaGetDeviceCount` smoke test

Validated result:

- `nvcc --version` works
- CUDA smoke reports `GPU count: 1`
- device detected: `GRID A100X-20C`
