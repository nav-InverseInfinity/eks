output "eks_cluster_id" {
  value = aws_eks_cluster.cluster.id
}
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}
output "eks_cluster_oidc_issuer" {
  value = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
output "eks_node_name" {
  value = aws_iam_role.eks_node_role.name
}
output "eks_cluster_ca_cert" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}
