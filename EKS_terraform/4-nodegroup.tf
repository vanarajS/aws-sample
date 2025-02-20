resource "aws_eks_node_group" "ng1" {
    cluster_name = var.cluster_name
    node_role_arn = "arn:aws:iam::590183971315:role/eksClusterRole"
    node_group_name = "ng1"
    subnet_ids = [
        aws_subnet.pri-sn1.id,
        aws_subnet.pri-sn2.id
    ]
    scaling_config {
      desired_size = 3
      max_size = 4
      min_size = 1
    }
    update_config {
      max_unavailable = 1
    }
}