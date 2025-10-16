#######################################################
# IAM Role for Lambda: RDS Auto-Scaling
#######################################################

resource "aws_iam_role" "lambda_rds_scaling_role" {
  name = "lambda-rds-scaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#######################################################
# Attach AWS Managed Policy for CloudWatch Logs
#######################################################
resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_rds_scaling_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#######################################################
# Custom Inline Policy: Least Privilege for RDS Scaling
#######################################################
resource "aws_iam_policy" "lambda_rds_scaling_policy" {
  name        = "lambda-rds-scaling-policy"
  description = "Permissions for Lambda to modify RDS and access CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # RDS Instance modification and read access
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance"
        ]
        Resource = "*"
      },
      # CloudWatch metrics for FreeStorageSpace, CPU, etc.
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"
      },
      # Allow writing logs to CloudWatch
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # Optional: SNS access if triggered by alarms
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

#######################################################
# Attach the Custom Inline Policy
#######################################################
resource "aws_iam_role_policy_attachment" "lambda_rds_scaling_policy_attach" {
  role       = aws_iam_role.lambda_rds_scaling_role.name
  policy_arn = aws_iam_policy.lambda_rds_scaling_policy.arn
}

