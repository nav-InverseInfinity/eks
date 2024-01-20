# Each role for each namespace
## Get the OIDC data to create a IAM role for EKS service account

data "tls_certificate" "eks_oidc" {
  url = var.eks_oidc_url
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_oidc.url
}

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.k8_namespace}:${var.k8_serviceaccount}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_sa_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
  name               = "eks_sa_role"
}

resource "aws_iam_policy" "iam_permissions" {
  name   = "eks_sa_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:*"
    ],
    "Resource": "*"
  }]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "eks_sa_role_attach" {
  role       = aws_iam_role.eks_sa_role.name
  policy_arn = aws_iam_policy.iam_permissions.arn
}
