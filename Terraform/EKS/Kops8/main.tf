##################################################
# Locals
##################################################
locals {
  kops_state_store         = "s3://${var.kops_state_bucket}"
  zones_csv                = join(",", var.zones)
 ssh_pub_key_path_expanded = abspath(var.ssh_public_key_path)

}









##################################################
# Kops Cluster Creation
##################################################
resource "null_resource" "kops_create_cluster" {
  triggers = {
    cluster_name       = var.cluster_name
    state_bucket       = var.kops_state_bucket
    kubernetes_version = var.kubernetes_version
    zones              = join(",", var.zones)
    node_count         = tostring(var.node_count)
    node_size          = var.node_size
    master_size        = var.master_size
    ssh_key_name       = var.ssh_public_key_path
    security_group_id  = aws_security_group.kops_sg.id
    extra_args         = var.additional_kops_create_args
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOT
      set -euo pipefail
      export KOPS_STATE_STORE=${local.kops_state_store}

      echo "Creating Kops cluster: ${var.cluster_name}"

      kops create cluster \
        --name ${var.cluster_name} \
        --cloud aws \
        --state ${local.kops_state_store} \
        --zones ${local.zones_csv} \
        --vpc ${data.aws_vpc.existing.id} \
        --subnets ${data.aws_subnet.private_1.id},${data.aws_subnet.private_2.id} \
        --node-count ${var.node_count} \
        --node-size ${var.node_size} \
        --master-size ${var.master_size} \
        --ssh-public-key ${var.ssh_public_key_path} \
        --kubernetes-version ${var.kubernetes_version} \
        --authorization RBAC \
        ${var.additional_kops_create_args} || true

      echo "Applying cluster changes..."
      kops update cluster --name ${var.cluster_name} --state ${local.kops_state_store} --yes

      echo "Cluster creation started! You can validate with:"
      echo "  kops validate cluster --name ${var.cluster_name} --state ${local.kops_state_store}"
    EOT
  }

  depends_on = [
    var.kops_state_bucket,
    aws_security_group.kops_sg
  ]
}

