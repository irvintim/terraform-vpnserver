resource "aws_s3_bucket" "awsvpn-provisioning-scripts" {
  bucket = "${var.company_name}-instance-config-awsvpn-${var.environment}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "ipsec_updown_netkey" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "ipsec_updown_netkey"
  source = "${path.module}/files/usr/libexec/ipsec/_updown.netkey"
  etag   = filemd5("${path.module}/files/usr/libexec/ipsec/_updown.netkey")
}

resource "aws_s3_bucket_object" "dnsmasq_config_foobar_com" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-foo.com.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-foo.com.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-foo.com.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_generate_hosts" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-generated_hosts.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-generated_hosts.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-generated_hosts.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_sf_foobar" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-sf.foobar.com.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-sf.foobar.com.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-sf.foobar.com.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_toyota_com" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-toyota.com.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-toyota.com.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-toyota.com.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_toyotadrivethru_com" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-toyotadrivethru.com.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-toyotadrivethru.com.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-toyotadrivethru.com.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_toyota_mobility" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-toyotamobility.com.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-toyotamobility.com.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-toyotamobility.com.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_users" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-users.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-users.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-users.conf")
}

resource "aws_s3_bucket_object" "dnsmasq_config_zones" {
  bucket = aws_s3_bucket.awsvpn-provisioning-scripts.bucket
  key    = "/files/etc/dnsmasq.d/10-zones.conf"
  source = "${path.module}/files/etc/dnsmasq.d/10-zones.conf"
  etag   = filemd5("${path.module}/files/etc/dnsmasq.d/10-zones.conf")
}