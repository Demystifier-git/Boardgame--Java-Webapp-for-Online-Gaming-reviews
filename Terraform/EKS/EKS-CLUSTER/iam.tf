resource "aws_iam_policy" "java_app_secrets_policy" {
  name        = "java-app-secrets-policy"
  description = "Allow access to java-app secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:920216467853:secret:java-app-TxHsLe*"
      }
    ]
  })
}
