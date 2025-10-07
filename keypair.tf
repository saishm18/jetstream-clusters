resource "openstack_compute_keypair_v2" "me" {
  name       = "indyssc-cluster-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
