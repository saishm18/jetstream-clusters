output "cluster_public_key" {
  value = trimspace(file("${path.module}/cluster.pub"))
}

output "cluster_private_key_path" {
  value = "${path.module}/cluster.key"
}
