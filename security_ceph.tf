# MON (msgr1) 6789
resource "openstack_networking_secgroup_rule_v2" "egress_ceph_mon_6789" {
  count             = var.egress_secgroup_id == null || var.cephfs_export_msgr1 == null ? 0 : 1
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6789
  port_range_max    = 6789
  security_group_id = var.egress_secgroup_id
  remote_ip_prefix  = var.storage_remote_cidr # e.g., 0.0.0.0/0 or the Ceph subnet
}

# Ceph daemons (MDS/OSD) 6800–7300
resource "openstack_networking_secgroup_rule_v2" "egress_ceph_daemons" {
  count             = var.egress_secgroup_id == null || var.cephfs_export_msgr1 == null ? 0 : 1
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6800
  port_range_max    = 7300
  security_group_id = var.egress_secgroup_id
  remote_ip_prefix  = var.storage_remote_cidr
}
