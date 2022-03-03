resource "aws_iam_role" "red-role" {
  name = "object-rbac-demo-red-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "AWS" = data.aws_caller_identity.current.account_id
        }
      },
    ]
  })

  inline_policy {
    name   = "policy-8675309"
    policy = data.aws_iam_policy_document.inline_policy.json
  }

  tags = {
    access = "red"
  }
}

resource "aws_iam_role" "blue-role" {
  name = "object-rbac-demo-blue-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "AWS" = data.aws_caller_identity.current.account_id
        }
      },
    ]
  })

  tags = {
    access = "blue"
  }

  inline_policy {
    name   = "policy-8675309"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3-object-lambda:GetObject", "lambda:InvokeFunction"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "s3:ExistingObjectTag/access"
      values   = ["$${aws:PrincipalTag/access}"]

    }

  }
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name   = "policy-8675309"
    policy = data.aws_iam_policy_document.lambda_inline_policy.json
  }
}

data "aws_iam_policy_document" "lambda_inline_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3-object-lambda:WriteGetObjectResponse",
      "s3:GetObjectTagging",
      "iam:ListRoleTags"
    ]
    resources = ["*"]
  }
}