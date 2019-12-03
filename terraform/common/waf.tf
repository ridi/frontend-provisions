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
  value = "${join("", aws_waf_web_acl.in_office_waf_acl.*.id)}"
}

resource "aws_waf_rule" "books_wafrule" {
  depends_on  = ["aws_waf_ipset.books_allowed_ipset"]
  name        = "booksRidiIoWAFRule"
  metric_name = "booksRidiIoWAFRule"

  predicates {
    data_id = "${aws_waf_ipset.books_allowed_ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "books_waf_acl" {
  depends_on = [
    "aws_waf_ipset.books_allowed_ipset",
    "aws_waf_rule.books_wafrule",
  ]

  name        = "booksRidiIoWebACL"
  metric_name = "booksRidiIoWebACL"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_waf_rule.books_wafrule.id}"
    type     = "REGULAR"
  }
}

output "books_waf_acl_id" {
  value = "${join("", aws_waf_web_acl.books_waf_acl.*.id)}"
}
