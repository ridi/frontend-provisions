resource "aws_waf_ipset" "office_ipset" {
  name = "RIDI Office"

  ip_set_descriptors = [
    {
      type  = "IPV4"
      value = "218.232.41.2/32"
    },
    {
      type  = "IPV4"
      value = "218.232.41.3/32"
    },
    {
      type  = "IPV4"
      value = "218.232.41.4/32"
    },
    {
      type  = "IPV4"
      value = "218.232.41.5/32"
    },
    {
      type  = "IPV4"
      value = "222.231.4.164/32"
    },
    {
      type  = "IPV4"
      value = "222.231.4.165/32"
    },
  ]
}

resource "aws_waf_rule" "allow_ridi_office_wafrule" {
  depends_on  = ["aws_waf_ipset.office_ipset"]
  name        = "ridiOfficeWAFRule"
  metric_name = "ridiOfficeWAFRule"

  predicates {
    data_id = "${aws_waf_ipset.office_ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "in_office_waf_acl" {
  depends_on = [
    "aws_waf_ipset.office_ipset",
    "aws_waf_rule.allow_ridi_office_wafrule",
  ]

  name        = "ridiOfficeWebACL"
  metric_name = "ridiOfficeWebACL"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_waf_rule.allow_ridi_office_wafrule.id}"
    type     = "REGULAR"
  }
}

output "in_office_waf_acl_id" {
  value = "aws_waf_web_acl.in_office_waf_acl.id"
}
