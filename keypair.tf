resource "openstack_compute_keypair_v2" "me" {
  name       = "indyssc-cluster-key"
  public_key = trimspace(file("${path.module}/cluster.pub"))
}
