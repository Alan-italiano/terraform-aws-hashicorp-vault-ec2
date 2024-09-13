# Create target groups for ALB
resource "aws_lb_target_group" "vault" {
 target_type = "instance"     
 name     = "Target-Group-Vault"
 port     = 8200
 protocol = "HTTPS"
 vpc_id   = aws_vpc.my_vpc.id

 health_check {
  protocol            = "HTTPS"    
  enabled             = true
  path                = "/v1/sys/health"
  matcher             = "200,473"
 }

}

# Create ALB
resource "aws_lb" "vault" {
 name               = "Vault-ALB"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.terrafrom_sg.id]
 subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]

 tags = {
   Environment = "PROD"
 }
}


# Create ALB Listeners
resource "aws_lb_listener" "vault_tls" {
 load_balancer_arn = aws_lb.vault.arn
 certificate_arn   = module.acm.acm_certificate_arn
 port              = "443"
 protocol          = "HTTPS"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.vault.arn
 }
}

resource "aws_lb_listener" "vault_notls" {
  load_balancer_arn = aws_lb.vault.arn
  port              = "80"
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

# Target Group EC2 Attachments
resource "aws_lb_target_group_attachment" "vault_1" {
 target_group_arn = aws_lb_target_group.vault.arn
 target_id        = aws_instance.vault_instance_1.id
}

resource "aws_lb_target_group_attachment" "vault_2" {
 target_group_arn = aws_lb_target_group.vault.arn
 target_id        = aws_instance.vault_instance_2.id
}

resource "aws_lb_target_group_attachment" "vault_3" {
 target_group_arn = aws_lb_target_group.vault.arn
 target_id        = aws_instance.vault_instance_3.id
}


# Create Route 53 record for ALB
resource "aws_route53_record" "vault" {
  zone_id = var.route_53_zone_id
  name    = var.cert_san_1
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.vault.dns_name]
}