# External/public network (already provided by Jetstream)
data "openstack_networking_network_v2" "external" {
  name = "public"
}

# Access network (NIC1): routed to the internet via router for Floating IPs/egress
resource "openstack_networking_network_v2" "access" { name = "access-net" }

resource "openstack_networking_subnet_v2" "access" {
  name            = "access-subnet"
  network_id      = openstack_networking_network_v2.access.id
  cidr            = "10.50.0.0/24"
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

resource "openstack_networking_router_v2" "rtr" {
  name                = "access-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "rtr_access" {
  router_id = openstack_networking_router_v2.rtr.id
  subnet_id = openstack_networking_subnet_v2.access.id
}

# Management network (NIC2) — fixed, human-readable IPs
resource "openstack_networking_network_v2" "mgmt" { name = "mgmt-net" }

resource "openstack_networking_subnet_v2" "mgmt" {
  name       = "mgmt-subnet"
  network_id = openstack_networking_network_v2.mgmt.id
  cidr       = "192.168.10.0/24"
  ip_version = 4
  enable_dhcp = true
  # Avoid DHCP handing out .101-.105 by skipping them in pools
  allocation_pool { start = "192.168.10.50", end = "192.168.10.100" }
  allocation_pool { start = "192.168.10.106", end = "192.168.10.200" }
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

# MPI network (NIC3) — fixed, human-readable IPs
resource "openstack_networking_network_v2" "mpi" { name = "mpi-net" }

resource "openstack_networking_subnet_v2" "mpi" {
  name       = "mpi-subnet"
  network_id = openstack_networking_network_v2.mpi.id
  cidr       = "192.168.20.0/24"
  ip_version = 4
  enable_dhcp = true
  allocation_pool { start = "192.168.20.50", end = "192.168.20.100" }
  allocation_pool { start = "192.168.20.106", end = "192.168.20.200" }
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

# Security group: Internet SSH to NIC1; allow ICMP; allow intra-group on mgmt/mpi
resource "openstack_networking_secgroup_v2" "cluster_sg" {
  name        = "cluster-sg"
  description = "SSH on access-net; intra-cluster allow on mgmt/mpi"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_in" {
  security_group_id = openstack_networking_secgroup_v2.cluster_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_in" {
  security_group_id = openstack_networking_secgroup_v2.cluster_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Intra-cluster allow (same SG)
resource "openstack_networking_secgroup_rule_v2" "intra_tcp" {
  security_group_id = openstack_networking_secgroup_v2.cluster_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_sg.id
}
resource "openstack_networking_secgroup_rule_v2" "intra_udp" {
  security_group_id = openstack_networking_secgroup_v2.cluster_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_sg.id
}
resource "openstack_networking_secgroup_rule_v2" "intra_icmp" {
  security_group_id = openstack_networking_secgroup_v2.cluster_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_sg.id
}
