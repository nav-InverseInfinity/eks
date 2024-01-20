output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller_role.arn
}
output "karpenter_instance_profile" {
  value = aws_iam_instance_profile.karpenter.name
}
