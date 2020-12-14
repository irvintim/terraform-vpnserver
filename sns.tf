resource "aws_sns_topic" "aws_vpnalarms" {
  name = "${var.environment}-aws-vpnalarms"
  tags = merge(local.global_tags)
}