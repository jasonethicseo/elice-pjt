#data "aws_route53_zone" "zone" {
#  name         = "${var.domain}."
#  private_zone = true
#}

#resource "aws_route53_vpc_association_authorization" "association-authorization" {
#  vpc_id  = var.vpc_id
#  zone_id = data.aws_route53_zone.zone.id
#}

resource "aws_route53_zone_association" "association" {
  vpc_id  = var.vpc_id
  zone_id = var.zone_id
}