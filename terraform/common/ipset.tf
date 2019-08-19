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

resource "aws_waf_ipset" "test_ridi_io_ipset" {
  name = "test.ridi.io"

  ip_set_descriptors {
    type  = "IPV4"
    value = "52.78.20.56/32"
  }
}

resource "aws_waf_ipset" "books_ridi_io_allowed_ipset" {
  name = "RIDI Office and test.ridi.io and Gitlab Shared Runners"

  for (ip_set in aws_waf_ipset.office_ipset.ip_set_descriptors) {
    ip_set_descriptors {
      type  = "IPV4"
      value = ip_set.value
    }
  }

  for (ip_set in aws_waf_ipset.gitlab_shared_runner.ip_set_descriptors) {
    ip_set_descriptors {
      type  = "IPV4"
      value = ip_set.value
    }
  }

  for (ip_set in aws_waf_ipset.test_ridi_io_ipset.ip_set_descriptors) {
    ip_set_descriptors {
      type  = "IPV4"
      value = ip_set.value
    }
  }
}
