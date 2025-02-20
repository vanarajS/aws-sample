# resource "aws_iam_role" "eks_role" {
#     name = "eks-role2"
#     assume_role_policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#             {
#                 Action = [
#                     "sts:AssumeRole",
#                 ]
#                 Effect = "Allow"
#                 Principal = {
#                     Service = "eks.amazonaws.com"
#                 }
#             },
#         ]
#     })

#     }

# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#     role = "EKS-role"
  
# }

resource "aws_eks_cluster" "eks_cluster" {
    name = var.cluster_name
    role_arn = "arn:aws:iam::590183971315:role/eksClusterRole"
    vpc_config {
      
      endpoint_private_access = true
      endpoint_public_access = true
      subnet_ids = [ 
        aws_subnet.pri-sn1.id,
        aws_subnet.pri-sn2.id,
        aws_subnet.pub-sn1.id,
        aws_subnet.pub-sn2.id
      ]
    }
    access_config {
      
      authentication_mode = "API"
      bootstrap_cluster_creator_admin_permissions = true

    }
    bootstrap_self_managed_addons = true
    tags = var.tags
    version = var.eks_version
    upgrade_policy {
      support_type = "STANDARD"
    }

}

resource "aws_eks_fargate_profile" "eks-fargate_pro" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    fargate_profile_name = "demo"
    pod_execution_role_arn = "arn:aws:iam::590183971315:role/eksClusterRole"

    selector {
      namespace = "kube-system"
    }
    subnet_ids = [aws_subnet.pri-sn1.id, aws_subnet.pri-sn2.id]
  
}