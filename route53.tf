resource "aws_route53_record" "vpngw" {
  zone_id = var.route53_zone
  name    = "vpngw.${var.company_name}.com."
  type    = "A"
  ttl     = "300"
  records = [aws_eip.awsvpn_gw_eni_eip.public_ip]
}

resource "aws_route53_record" "toyota-nat" {
  zone_id = var.route53_zone
  name    = "toyota-nat.${var.company_name}.com."
  type    = "A"
  ttl     = "300"
  records = [aws_eip.awsvpn_nat_eni_eip.public_ip]
}

resource "aws_route53_record" "awsvpn" {
  count   = var.enable_awsvpn ? 2 : 0
  zone_id = var.route53_zone
  name    = "awsvpn-${count.index + 1}.${var.company_name}.com."
  type    = "A"
  ttl     = "300"
  records = [aws_instance.awsvpn[count.index].public_ip]
}
