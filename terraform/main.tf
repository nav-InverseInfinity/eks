module "vpc" {
  source       = "./module/vpc"
  env          = local.env
  region       = var.region
  subnets      = var.subnets
  cluster_name = local.cluster_name
}

module "eks_sg" {
  source         = "./module/sg"
  vpc_id         = module.vpc.vpc_id
  eks_sg_ingress = var.eks_sg_ingress
}

module "eks_cluster_nodes" {
  source                  = "./module/eks_cluster_nodes"
  cluster_name            = local.cluster_name
  env                     = local.env
  eks_cluster_policy_arns = var.eks_cluster_policy_arns
  eks_node_policy_arns    = local.eks_node_policy_arns
  eks_subnets             = local.eks_subnets
  node_groups             = var.node_groups
  node_taint              = var.node_taint
}

module "eks_oidc" {
  source            = "./module/oidc"
  eks_oidc_url      = module.eks_cluster_nodes.eks_cluster_oidc_issuer
  k8_namespace      = "default"
  k8_serviceaccount = "aws-sa"
  depends_on        = [module.eks_cluster_nodes]
}

module "karpenter" {
  source        = "./module/karpenter"
  eks_oidc_url  = local.eks_oidc_url
  eks_oidc_arn  = local.eks_oidc_arn
  eks_node_name = local.eks_node_name
  depends_on    = [module.eks_cluster_nodes, module.eks_oidc]
}

output "karpenter_controller_role_arn" {
  value = module.karpenter.karpenter_controller_role_arn
}

output "cluster_id" {
  value = local.cluster_id
}

output "cluster_endpoint" {
  value = local.cluster_endpoint
}

output "default_instance_profile" {
  value = local.karpenter_instance_profile
}
# Karpenter - Helm Release 

# resource "helm_release" "karpenter" {
#   name       = "karpenter"
#   namespace  = "karpenter"
#   repository = "https://charts.karpenter.sh/"
#   version    = "0.16.3"
#   chart      = "karpenter"


#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.karpenter.karpenter_controller_role_arn
#   }

#   set {
#     name  = "clusterName"
#     value = local.cluster_id
#   }

#   set {
#     name  = "clusterEndpoint"
#     value = local.cluster_endpoint
#   }

#   set {
#     name  = "aws.defaultInstanceProfile"
#     value = local.karpenter_instance_profile
#   }

#   depends_on = [module.vpc, module.eks_sg, module.eks_cluster_nodes, module.eks_oidc, module.karpenter]

# }
