resource "tls_private_key" "cluster" {
  algorithm = "ED25519"
}

# Export the Terraform-generated SSH keypair as outputs (private is marked sensitive)
output "cluster_private_key_pem" {
  value     = tls_private_key.cluster.private_key_pem
  sensitive = true
}

output "cluster_public_key" {
  value = tls_private_key.cluster.public_key_openssh
}

# OpenSSH-formatted private key (works with ssh -i)
output "cluster_private_key_openssh" {
  value     = tls_private_key.cluster.private_key_openssh
  sensitive = true
}
