# HTTP listener: Redirect to HTTPS
resource "aws_lb_listener" "edo_http_listener01" {
  load_balancer_arn = aws_lb.edo_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener: Use regional certificate for ALB
resource "aws_lb_listener" "edo_https_listener01" {
  load_balancer_arn = aws_lb.edo_alb01.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate.edo_alb_cert01.arn   # ← regional cert (ap-northeast-1)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.edo_tg01.arn
  }

  depends_on = [aws_acm_certificate_validation.edo_alb_validation01]
}

# Origin Header Protection Rule
resource "aws_lb_listener_rule" "edo_require_origin_header01" {
  listener_arn = aws_lb_listener.edo_https_listener01.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.edo_tg01.arn
  }

  condition {
    http_header {
      http_header_name = "X-edo-Growl"
      values           = [random_password.edo_origin_header_value01.result]
    }
  }
}

# Default block rule (403 Forbidden for unmatched traffic)
resource "aws_lb_listener_rule" "edo_default_block01" {
  listener_arn = aws_lb_listener.edo_https_listener01.arn
  priority     = 99

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    path_pattern { values = ["*"] }
  }
}