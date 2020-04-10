locals {
  oidc_url   = replace(data.aws_eks_cluster.eks_one_kube.identity.0.oidc.0.issuer, "https://", "")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
}
resource "aws_iam_role" "my_iam_role" {
  name               = "my-service-usw2-rl-0"
  assume_role_policy = data.aws_iam_policy_document.eks_iam_assume_role_policy.json
  tags = var.tags
}
 
data "aws_iam_policy_document" "eks_iam_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
 
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_one_kube.identity.0.oidc.0.issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.service_namespace}:${var.service_name}"]
    }
 
    principals {
      identifiers = [
        local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}
 
data "aws_iam_policy_document" "aws_access_policy" {
  source_json = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CanListS3",
            "Effect": "Allow",
            "Action": [
                "s3:List*"
            ],
            "Resource": ["arn:aws:s3:::my-s3-bucket"]
        },
        {
            "Sid": "CanReadS3",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": ["arn:aws:s3:::my-s3-bucket/*"]
        }
    ]
}
POLICY
}
 
resource "aws_iam_role_policy" "my_iam_role_policy" {
  name = "my-service-usw2-rp-0"
  role = aws_iam_role.my_iam_role.name
  policy = data.aws_iam_policy_document.aws_access_policy.json
}

resource "kubernetes_service_account" "my_service_account" {
  metadata {
    name      = var.service_name
    namespace = var.service_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.my_iam_role.arn
    }
  }
}
