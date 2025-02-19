resource "aws_iam_role" "eks_role" {
    name = "eks-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole",
                ]
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })

    }

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam:aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_role.name
  
}

resource "aws_eks_cluster" "eks_cluster" {
    name = var.cluster_name
    role_arn = aws_iam_role.eks_role.arn
    vpc_config {
      
      endpoint_private_access = true
      endpoint_public_access = true
      subnet_ids = [ 
        aws_subnet.pri-sn1,
        aws_subnet.pri-sn2,
        aws_subnet.pub-sn1,
        aws_subnet.pub-sn2
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
    depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy ]
}

