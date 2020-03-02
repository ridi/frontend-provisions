resource "aws_waf_ipset" "office_ipset" {
  name = "RIDI Office"

  ip_set_descriptors {
    type  = "IPV4"
    value = "218.232.41.2/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "218.232.41.3/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "218.232.41.4/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "218.232.41.5/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "222.231.4.164/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "222.231.4.165/32"
  }
}

resource "aws_waf_ipset" "gitlab_shared_runner" {
  name = "RIDI Gitlab Shared Runner"

  ip_set_descriptors {
    type = "IPV4"
    value = "222.231.4.163/32"
  }
  ip_set_descriptors {
    type = "IPV4"
    value = "52.78.157.166/32"
  }
  ip_set_descriptors {
    type = "IPV4"
    value = "13.125.24.99/32"
  }
}

resource "aws_waf_ipset" "store_team_ipset" {
  name = "test.ridi.io"

  # DEV
  ip_set_descriptors {
    type  = "IPV4"
    value = "52.78.20.56/32"
  }
  # PROD
  ip_set_descriptors {
    type  = "IPV4"
    value = "52.79.216.238/32"
  }
}

resource "aws_waf_ipset" "account_team_ipset" {
  name = "account team"

  # DEV
  ip_set_descriptors {
    type  = "IPV4"
    value = "13.125.165.225/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "13.125.173.44/32"
  }
  # PROD
  ip_set_descriptors {
    type  = "IPV4"
    value = "13.124.161.99/32"
  }
  ip_set_descriptors {
    type  = "IPV4"
    value = "13.209.56.147/32"
  }
}

resource "aws_waf_ipset" "books_allowed_ipset" {
  name = "RIDI Office and test.ridi.io and Gitlab Shared Runners"

  dynamic "ip_set_descriptors" {
    for_each = [for i in aws_waf_ipset.office_ipset.ip_set_descriptors: i.value]

    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }

  dynamic "ip_set_descriptors" {
    for_each = [for i in aws_waf_ipset.gitlab_shared_runner.ip_set_descriptors: i.value]

    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }

  dynamic "ip_set_descriptors" {
    for_each = [for i in aws_waf_ipset.store_team_ipset.ip_set_descriptors: i.value]

    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }

  dynamic "ip_set_descriptors" {
    for_each = [for i in aws_waf_ipset.account_team_ipset.ip_set_descriptors: i.value]

    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }
}
