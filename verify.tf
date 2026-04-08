resource "null_resource" "verify" {
  depends_on = [
    openstack_compute_instance_v2.master,
    openstack_compute_instance_v2.worker
  ]

  provisioner "local-exec" {
    command = <<EOC
set -e
MASTER_IP=$(terraform output -raw master_floating_ip)
KEY_PATH=$(terraform output -raw cluster_private_key_path)
echo "== waiting for cluster verification on $MASTER_IP =="
# wait up to ~3 minutes for cloud-init + service
for i in $(seq 1 36); do
  if ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no rocky@$MASTER_IP "test -f /home/rocky/cluster-verify.log"; then
    break
  fi
  sleep 5
done
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no rocky@$MASTER_IP "tail -n +1 /home/rocky/cluster-verify.log || sudo tail -n 120 /var/log/cloud-init-output.log"
EOC
  }
}
