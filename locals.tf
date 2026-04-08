locals {
  hostnames     = concat(["master"], [for i in local.workers : "worker${i}"])
  mpi_hostnames = concat(["master-mpi"], [for i in local.workers : "worker${i}-mpi"])
  worker_host_octet = {
    for i in local.workers :
    i => (i <= 4 ? 101 + i : 105 + i)
  }
  host_ip_map = merge(
    { master = { mgmt = "192.168.10.101", mpi = "192.168.20.101" } },
    {
      for i in local.workers :
      "worker${i}" => {
        mgmt = "192.168.10.${local.worker_host_octet[i]}"
        mpi  = "192.168.20.${local.worker_host_octet[i]}"
      }
    }
  )

  # Lines we’ll drop into /etc/hosts on every node via cloud-init
  hosts_file = join("\n", concat(
    [for h in local.hostnames : "${local.host_ip_map[h].mgmt} ${h}"],
    [for h in local.hostnames : "${local.host_ip_map[h].mpi} ${h}-mpi"]
  ))
  ssh_host_patterns = join(" ", concat(local.hostnames, local.mpi_hostnames, ["192.168.10.*", "192.168.20.*"]))
  mpi_hosts_file    = join("\n", [for h in local.mpi_hostnames : "${h} slots=1"])
  worker_hosts      = join(" ", [for i in local.workers : "worker${i}"])

  master_user_data = templatefile("${path.module}/cloudinit/master.yaml", {
    cluster_pub       = trimspace(file("${path.module}/cluster.pub"))
    cluster_priv      = indent(6, trimspace(file("${path.module}/cluster.key")))
    hosts_file        = indent(6, local.hosts_file)
    ssh_host_patterns = local.ssh_host_patterns
    worker_hosts      = local.worker_hosts
    mpi_hostnames     = join(" ", local.mpi_hostnames)
    mpi_hosts_file    = indent(6, local.mpi_hosts_file)
    mpi_rank_count    = length(local.mpi_hostnames)
  })

  worker_user_data_map = {
    for i in local.workers :
    i => templatefile("${path.module}/cloudinit/worker.yaml", {
      node_name   = "worker${i}"
      cluster_pub = trimspace(file("${path.module}/cluster.pub"))
      hosts_file  = indent(6, local.hosts_file)
    })
  }
}
