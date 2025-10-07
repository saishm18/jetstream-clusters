variable "region"               { type = string, default = "" }  # optional override
variable "image_id"             { type = string }                 # exact UUID from Horizon
variable "master_flavor"        { type = string, default = "m3.large" }
variable "worker_flavor"        { type = string, default = "m3.small" }
variable "worker_count"         { type = number, default = 4 }
variable "assign_fips_to_workers" { type = bool, default = false }  # usually false
