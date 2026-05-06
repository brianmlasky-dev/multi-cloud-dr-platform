variable "domain_name" {
  type    = string
  default = "northstarcommerce.com"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "primary_alb_dns" {
  type    = string
  default = "primary-alb.northstarcommerce.com"
}

variable "gcp_cloudrun_fqdn" {
  type    = string
  default = "northstar-app-placeholder.run.app"
}
