#################################################
# RDS Auto-Scaling - Production Grade
#################################################

######################
# SNS Topic
######################
resource "aws_sns_topic" "rds_scaling_notifications" {
  name = "rds-scaling-notifications"
  
}

######################
# CloudWatch Alarms
######################
# High CPU Utilization (scale up)
resource "aws_cloudwatch_metric_alarm" "high_db_cpu" {
  alarm_name          = "${var.db_identifier}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    DBInstanceIdentifier = data.aws_db_instance.existing.id
  }

  alarm_actions = [aws_sns_topic.rds_scaling_notifications.arn]
  ok_actions    = [aws_sns_topic.rds_scaling_notifications.arn]

  treat_missing_data = "notBreaching"
}

# High Storage Usage (scale up storage)
resource "aws_cloudwatch_metric_alarm" "high_db_storage" {
  alarm_name          = "${var.db_identifier}-high-storage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120  # 5 GB remaining free space

  dimensions = {
    DBInstanceIdentifier = data.aws_db_instance.existing.id
  }

  alarm_description = "Triggers when free storage space < 5 GB"
  alarm_actions     = [aws_sns_topic.rds_scaling_notifications.arn]
  ok_actions        = [aws_sns_topic.rds_scaling_notifications.arn]
  treat_missing_data = "notBreaching"
}









######################
# SNS Subscription → Lambda
######################
resource "aws_sns_topic_subscription" "rds_scaling_subscription" {
  topic_arn = aws_sns_topic.rds_scaling_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.rds_scale_lambda.arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scale_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.rds_scaling_notifications.arn
}
