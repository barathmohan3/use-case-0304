resource "aws_lb" "openproject" {
  name               = "openproject-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnets
}

resource "aws_lb" "devlake" {
  name               = "devlake-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "openproject_tg" {
  name     = "openproject-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "devlake_tg" {
  name     = "devlake-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "openproject_listener" {
  load_balancer_arn = aws_lb.openproject.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openproject_tg.arn
  }
}

resource "aws_lb_listener" "devlake_listener" {
  load_balancer_arn = aws_lb.devlake.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devlake_tg.arn
  }
}