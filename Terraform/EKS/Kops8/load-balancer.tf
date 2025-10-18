# Now in the ALB resource, use these explicitly
resource "aws_lb" "api_alb" {
  name               = "api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_albb.alb_sg]
  subnets            = [
    data.aws_subnet.public_1.id,
    data.aws_subnet.public_2.id
  ]
}

 
resource "aws_lb_target_group" "api_tg" {
  name        = "api-tg"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = data.aws_vpc.existing.id
  target_type = "instance"
  health_check {
    port     = "443"
    protocol = "HTTPS"
    path     = "/healthz"  # Replace with your endpoint
  }
}

# 5. Listener for ALB
resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = 443
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}