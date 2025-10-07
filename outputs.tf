output "master_floating_ip"    { value = openstack_networking_floatingip_v2.fip_master.address }
output "master_mgmt_ip"        { value = "192.168.10.101" }
output "master_mpi_ip"         { value = "192.168.20.101" }

output "worker_mgmt_ips" {
  value = [for i in sort(keys(openstack_networking_port_v2.worker_mgmt)) :
    openstack_networking_port_v2.worker_mgmt[i].all_fixed_ips[0]]
}

output "worker_mpi_ips" {
  value = [for i in sort(keys(openstack_networking_port_v2.worker_mpi)) :
    openstack_networking_port_v2.worker_mpi[i].all_fixed_ips[0]]
}

output "access_subnet" { value = openstack_networking_subnet_v2.access.cidr }
output "mgmt_subnet"   { value = openstack_networking_subnet_v2.mgmt.cidr }
output "mpi_subnet"    { value = openstack_networking_subnet_v2.mpi.cidr }
