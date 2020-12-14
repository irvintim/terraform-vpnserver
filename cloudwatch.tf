resource "aws_cloudwatch_metric_alarm" "awsvpn_no_vpn_sessions" {
  count               = var.enable_novpnalarm ? 1 : 0
  alarm_name          = "${var.environment}-awsvpn-no-vpn-sessions"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  threshold           = "0"
  treat_missing_data  = "ignore"
  alarm_description   = "${var.environment} Number of IPSEC VPN Sessions is Zero"
  alarm_actions       = [aws_sns_topic.aws_vpnalarms.arn]

  metric_query {
    id          = "e1"
    expression  = "m1+m2"
    label       = "${var.environment} Authenticated IKE Sessions"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "collectd_ipsec_value"
      namespace   = "CWAgent"
      period      = "60"
      stat        = "Maximun"
      unit        = "Count"

      dimensions = {
        instance      = "ipsec.current"
        type_instance = "states.iketype.authenticated"
        InstanceId    = aws_instance.awsvpn.0.id
        ImageId       = aws_instance.awsvpn.0.ami
        InstanceType  = aws_instance.awsvpn.0.instance_type
        type          = "gauge"
      }
    }
    return_data = false
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "collectd_ipsec_value"
      namespace   = "CWAgent"
      period      = "60"
      stat        = "Maximun"
      unit        = "Count"

      dimensions = {
        instance      = "ipsec.current"
        type_instance = "states.iketype.authenticated"
        InstanceId    = aws_instance.awsvpn.1.id
        ImageId       = aws_instance.awsvpn.1.ami
        InstanceType  = aws_instance.awsvpn.1.instance_type
        type          = "gauge"
      }
    }
    return_data = false
  }
  tags = merge(local.global_tags)

}

resource "aws_cloudwatch_dashboard" "awsvpn-dashboard" {
  dashboard_name = "AWS-VPN_Dashboard_${var.environment}"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 9,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "CWAgent", "collectd_ipsec_value", "instance", "ipsec.current", "type_instance", "states.ipsec", "InstanceId", "${aws_instance.awsvpn.0.id}", "ImageId", "${aws_instance.awsvpn.0.ami}", "InstanceType", "${aws_instance.awsvpn.0.instance_type}", "type", "gauge", { "id": "m1", "label": "awsvpn-1" } ],
                    [ "...", "${aws_instance.awsvpn.1.id}", ".", ".", ".", ".", ".", ".", { "label": "awsvpn-2" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Maximum",
                "period": 30,
                "title": "IPSEC SAs"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 9,
            "width": 9,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "CWAgent", "collectd_ipsec_value", "instance", "ipsec.current", "type_instance", "states.ipsec", "InstanceId", "${aws_instance.awsvpn.0.id}", "ImageId", "${aws_instance.awsvpn.0.ami}", "InstanceType", "${aws_instance.awsvpn.0.instance_type}", "type", "gauge", { "id": "m1", "label": "awsvpn-1" } ],
                    [ "...", "${aws_instance.awsvpn.1.id}", ".", ".", ".", ".", ".", ".", { "label": "awsvpn-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Maximum",
                "period": 10,
                "title": "IPSEC SAs"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 9,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "CWAgent", "collectd_ipsec_value", "instance", "ipsec.current", "type_instance", "states.iketype.authenticated", "InstanceId", "${aws_instance.awsvpn.0.id}", "ImageId", "${aws_instance.awsvpn.0.ami}", "InstanceType", "${aws_instance.awsvpn.0.instance_type}", "type", "gauge", { "accountId": "${data.aws_caller_identity.current.account_id}", "label": "awsvpn-1" } ],
                    [ "...", "${aws_instance.awsvpn.1.id}", ".", ".", ".", ".", ".", ".", { "accountId": "${data.aws_caller_identity.current.account_id}", "label": "awsvpn-2" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Maximum",
                "period": 30,
                "title": "IPSEC IKE Authenticated"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 9,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "CWAgent", "collectd_ipsec_value", "instance", "ipsec.current", "type_instance", "states.iketype.authenticated", "InstanceId", "${aws_instance.awsvpn.0.id}", "ImageId", "${aws_instance.awsvpn.0.ami}", "InstanceType", "${aws_instance.awsvpn.0.instance_type}", "type", "gauge", { "accountId": "${data.aws_caller_identity.current.account_id}", "label": "awsvpn-1" } ],
                    [ "...", "${aws_instance.awsvpn.1.id}", ".", ".", ".", ".", ".", ".", { "accountId": "${data.aws_caller_identity.current.account_id}", "label": "awsvpn-2" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Maximum",
                "period": 10,
                "title": "IPSEC IKE Authenticated"
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 6,
            "width": 9,
            "height": 3,
            "properties": {
                "metrics": [
                    [ { "expression": "IF(FILL(m1, 0) == 2, 1, 0)", "label": "awsvpn-1", "id": "e1", "region": "${var.aws_region}", "period": 30 } ],
                    [ { "expression": "IF(FILL(m2, 0) == 2, 1, 0)", "label": "awsvpn-2", "id": "e2", "region": "${var.aws_region}", "period": 30 } ],
                    [ "CWAgent", "collectd_snmp_value", "type_instance", "keepalived_instance_state", "InstanceId", "${aws_instance.awsvpn.0.id}", "ImageId", "${aws_instance.awsvpn.0.ami}", "InstanceType", "${aws_instance.awsvpn.0.instance_type}", "type", "gauge", { "accountId": "${data.aws_caller_identity.current.account_id}", "id": "m1", "visible": false } ],
                    [ "...", "${aws_instance.awsvpn.1.id}", ".", ".", ".", ".", ".", ".", { "accountId": "${data.aws_caller_identity.current.account_id}", "id": "m2", "visible": false } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Maximum",
                "period": 30,
                "title": "Keepalived Active",
                "setPeriodToTimeRange": false
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 9,
            "width": 9,
            "height": 3,
            "properties": {
                "metrics": [
                    [ { "expression": "IF(m1 == 2, 1, 0)", "label": "awsvpn-1", "id": "e1" } ],
                    [ { "expression": "IF(m2 == 2, 1, 0)", "label": "awsvpn-2", "id": "e2" } ],
                    [ "CWAgent", "collectd_snmp_value", "type_instance", "keepalived_instance_state", "InstanceId", "${aws_instance.awsvpn.0.id}", "ImageId", "${aws_instance.awsvpn.0.ami}", "InstanceType", "${aws_instance.awsvpn.0.instance_type}", "type", "gauge", { "accountId": "${data.aws_caller_identity.current.account_id}", "id": "m1", "visible": false } ],
                    [ "...", "${aws_instance.awsvpn.1.id}", ".", ".", ".", ".", ".", ".", { "accountId": "${data.aws_caller_identity.current.account_id}", "id": "m2", "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Maximum",
                "period": 10,
                "title": "Keepalived Active"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 12,
            "width": 24,
            "height": 6,
            "properties": {
                "query": "SOURCE '/${var.company_name}/awsvpn/var/log/tocloudwatch.log' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20",
                "region": "${var.aws_region}",
                "stacked": false,
                "title": "Log group: /${var.company_name}/awsvpn/var/log/tocloudwatch.log",
                "view": "table"
            }
        },
        {
            "type": "text",
            "x": 12,
            "y": 0,
            "width": 3,
            "height": 1,
            "properties": {
                "markdown": "\n[button:primary:Toggle Active](http://${aws_instance.awsvpn.1.public_ip}:${data.aws_ssm_parameter.toggle_port.value}?g=${data.aws_ssm_parameter.toggle_match.value})\n"
            }
        }
    ]
}
 EOF
}
