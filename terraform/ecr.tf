variable "ecr_name" {
    type = list
    default = ["backend", "frontend"]
}

resource "aws_ecr_repository" "ecr" {
  for_each = toset(var.ecr_name)
  name     = each.key
}

resource "aws_ecr_repository_policy" "lifecycle_policy" {
  depends_on = [aws_ecr_repository.ecr]
  for_each   = toset(var.ecr_name)
  repository = each.key

  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
EOF
}
