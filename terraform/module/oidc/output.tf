output "eks_oidc_url" {
  value = aws_iam_openid_connect_provider.eks_cluster.url
}
output "eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_cluster.arn
}
