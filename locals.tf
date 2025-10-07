locals {
  host_ip_map = {
    master  = { mgmt = "192.168.10.101", mpi = "192.168.20.101" }
    worker1 = { mgmt = "192.168.10.102", mpi = "192.168.20.102" }
    worker2 = { mgmt = "192.168.10.103", mpi = "192.168.20.103" }
    worker3 = { mgmt = "192.168.10.104", mpi = "192.168.20.104" }
    worker4 = { mgmt = "192.168.10.105", mpi = "192.168.20.105" }
  }

  hosts_file = join("\n", [
    "${local.host_ip_map.master.mgmt} master",
    "${local.host_ip_map.worker1.mgmt} worker1",
    "${local.host_ip_map.worker2.mgmt} worker2",
    "${local.host_ip_map.worker3.mgmt} worker3",
    "${local.host_ip_map.worker4.mgmt} worker4",
    "${local.host_ip_map.master.mpi} master-mpi",
    "${local.host_ip_map.worker1.mpi} worker1-mpi",
    "${local.host_ip_map.worker2.mpi} worker2-mpi",
    "${local.host_ip_map.worker3.mpi} worker3-mpi",
    "${local.host_ip_map.worker4.mpi} worker4-mpi",
  ])

  master_user_data = templatefile("${path.module}/cloudinit-master.yaml", {
    cluster_pub  = tls_private_key.cluster.public_key_openssh
    cluster_priv = tls_private_key.cluster.private_key_pem
    hosts_file   = local.hosts_file
    worker_cpus  = 2
  })
  worker_user_data = templatefile("${path.module}/cloudinit-worker.yaml", {
    cluster_pub = tls_private_key.cluster.public_key_openssh
    hosts_file  = local.hosts_file
  })
}
