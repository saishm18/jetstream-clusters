variable "region" {
  type    = string
  default = "" # optional override
}

variable "image_id" {
  type = string # exact UUID from Horizon
}

variable "master_flavor" {
  type    = string
  default = "m3.small"
}

variable "worker_flavor" {
  type    = string
  default = "g3.large"
}

variable "worker_count" {
  type    = number
  default = 8
}

variable "assign_fips_to_workers" {
  type    = bool
  default = false # usually false
}

variable "cephfs_export_msgr1" {
  type        = string
  default     = null
  description = "CephFS export using msgr1 (mon1:6789,mon2:6789,...:/volumes/.../<uuid>/<uuid>)"
  nullable    = true
}

variable "cephx_id" {
  type        = string
  default     = "cluster-cephx"
  description = "cephx client id used by Manila access"
}

variable "cephx_key_b64" {
  type        = string
  default     = null
  sensitive   = true
  description = "Base64 cephx key for cephx_id (from 'openstack share access list')"
  nullable    = true
}

variable "cephfs_mountpoint" {
  type        = string
  default     = "/opt/cluster"
  description = "Where to mount the CephFS share"
}

variable "storage_remote_cidr" {
  type        = string
  default     = "0.0.0.0/0" # tighten later to the storage subnet if known
  description = "Remote CIDR for Ceph MON/MDS egress rules"
}

variable "egress_secgroup_id" {
  type        = string
  default     = null
  description = "Security group ID applied to instances' egress NICs"
  nullable    = true
}
