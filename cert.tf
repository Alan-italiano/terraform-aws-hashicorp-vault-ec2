#Create ALB Listener Certificate on Certificate Manager
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = var.domain_name
  zone_id      = var.route_53_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    var.cert_san_1,
    var.cert_san_2
  ]

  wait_for_validation = true

  tags = {
    Name = var.domain_name
  }
}