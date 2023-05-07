############ datasource.tf

data "aws_route53_zone" "mydomain" {
  name         = var.domain
  private_zone = false
}
