resource "aws_waf_ipset" "gitlab_shared_runner" {
  name = "RIDI Gitlab Shared Runner"

  ip_set_descriptors = [
    {
      type = "IPV4"
      value = "222.231.4.163/32"
    },
    {
      type = "IPV4"
      value = "52.78.157.166/32"
    },
    {
      type = "IPV4"
      value = "13.125.24.99/32"
    }
  ]
}


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
  value = "${join("", aws_waf_web_acl.in_office_waf_acl.*.id)}"
}

resource "aws_waf_ipset" "test_ridi_io_ipset" {
  name = "test.ridi.io"

  ip_set_descriptors = [
    {
      type  = "IPV4"
      value = "52.78.20.56/32"
    },
  ]
}

resource "aws_waf_ipset" "books_ridi_io_allowed_ipset" {
  name = "RIDI Office and test.ridi.io and Gitlab Shared Runners"

  ip_set_descriptors = "${concat(aws_waf_ipset.office_ipset.ip_set_descriptors, aws_waf_ipset.test_ridi_io_ipset.ip_set_descriptors, aws_waf_ipset.gitlab_shared_runner)}"
}

resource "aws_waf_rule" "books_ridi_io_wafrule" {
  depends_on  = ["aws_waf_ipset.books_ridi_io_allowed_ipset"]
  name        = "booksRidiIoWAFRule"
  metric_name = "booksRidiIoWAFRule"

  predicates {
    data_id = "${aws_waf_ipset.books_ridi_io_allowed_ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "books_ridi_io_waf_acl" {
  depends_on = [
    "aws_waf_ipset.office_ipset",
    "aws_waf_rule.allow_books_ridi_io_wafrule",
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
    rule_id  = "${aws_waf_rule.books_ridi_io_wafrule.id}"
    type     = "REGULAR"
  }
}

output "books_ridi_io_waf_acl_id" {
  value = "${join("", aws_waf_web_acl.books_ridi_io_wafrule.*.id)}"
}
