resource "aws_iam_role" "role" {
  name = "dax-role"
   tags = merge({
    "tmna:terraform:script" = "dax-cluster/dax-cluster.tf"
    "tmna:env"              = var.environment
  }, var.tags)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dax.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "dax-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dax:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"

  roles      = ["${aws_iam_role.role.name}"]

  policy_arn = "${aws_iam_policy.policy.arn}"
}


resource "aws_dax_cluster" "dax-cluster" {
  cluster_name       = "dax-cluster"
  iam_role_arn       = "${aws_iam_role.role.arn}"
  node_type          = "dax.r4.large"
  replication_factor = 1
   tags = merge({
    "tmna:terraform:script" = "dax-cluster/dax-cluster.tf"
    "tmna:env"              = var.environment
  }, var.tags)
   subnet_group_name  = "subnetdax"
   security_group_ids = ["var.security_group_ids"]
  
}
resource "aws_dax_subnet_group" "subnetdax" {
  name       = "dax-cluster"
  subnet_ids = "${var.subnet_ids}"

}
