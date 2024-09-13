variable "REGION" {
  default = "us-east-1"
}

variable "ZONE1" {
  default = "us-east-1a"
}

variable "ZONE2" {
  default = "us-east-1b"
}

variable "ZONE3" {
  default = "us-east-1c"
}

variable "AMIS" {
  default = {
    us-east-1 = "ami-0182f373e66f89c85"
  }
}

variable "USER" {
  default = "ec2-user"
}

variable "PUB_KEY" {
  default = "bastion"
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
  default     = ""
}

variable "route_53_zone_id" {
  description = "Route 53 Zone ID"
  type        = string
  default     = "PASTE ZONE ID HERE"
}

variable "cert_san_1" {
  description = "Domain Name 1"
  type        = string
  default     = ""
}

variable "cert_san_2" {
  description = "Domain Name 2"
  type        = string
  default     = ""
}
