### Cluster IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.env}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_cluster_attach_policy" {
  for_each   = var.eks_cluster_policy_arns
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

### Node IAM role
resource "aws_iam_role" "eks_node_role" {
  name = "${var.env}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

### autoscaler for nodes  - using karpenter
# resource "aws_iam_policy" "eks_autoscaler" {
#   name   = "${var.env}-eks-autoscaler-policy"
#   policy = <<EOT
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "autoscaling:DescribeAutoScalingGroups",
#         "autoscaling:DescribeAutoScalingInstances",
#         "autoscaling:DescribeLaunchConfigurations",
#         "autoscaling:DescribeTags",
#         "autoscaling:SetDesiredCapacity",
#         "autoscaling:TerminateInstanceInAutoScalingGroup",
#         "ec2:DescribeLaunchTemplateVersions"
#       ],
#       "Resource": [
#         "*"
#       ]
#     }
#   ]
# }
#   EOT
# }

resource "aws_iam_role_policy_attachment" "eks_node_attach_policy" {
  for_each   = var.eks_node_policy_arns
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

### EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.eks_subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_attach_policy,
  ]
}

### EKS Node group
resource "aws_eks_node_group" "nodegroup" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.eks_subnets

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = 1
    max_size     = each.value.max_scaling_size
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Taint only for dev node, not for default node
  # [1] => one element; [] => empty
  dynamic "taint" {
    for_each = each.key == "dev_node" ? [1] : []
    content {
      key    = var.node_taint.key
      value  = var.node_taint.value
      effect = var.node_taint.effect
    }

  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_attach_policy,
  ]
}
