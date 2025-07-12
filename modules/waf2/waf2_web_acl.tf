resource "aws_wafv2_ip_set" "admin_remote_ips" {
  name        = "${var.waf_prefix}-generic-match-admin-remote-ips"
  description = "${var.waf_prefix}-generic-match-admin-remote-ips"
  scope       = var.scope
  ip_address_version = "IPV4"
  addresses   = var.waf_ip_sets
  tags = var.tags
}

# resource "aws_wafv2_ip_set" "blacklisted_ips" {
#   name        = "${var.waf_prefix}-generic-match-blacklisted-ips"
#   description = "${var.waf_prefix}-generic-match-blacklisted-ips"
#   scope       = var.scope
#   ip_address_version = "IPV4"
#   addresses          = ["103.72.112.0/24"]

#   tags = {
#       Tag1 = "External IP Sample"
#       Tag2 = "created_by_terraform"
#   }
# }

resource "aws_wafv2_web_acl" "waf_acl" {
  name  = "${var.waf_prefix}-generic-owasp-acl"
  scope = var.scope

  default_action {
    dynamic "block" {
      for_each = var.enableBlock ? [1] : []
      content {}
    }
    dynamic "allow" {
      for_each = var.enableBlock ? [] : [1]
      content {}
    }
  }

  lifecycle {
    ignore_changes = [rule]
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      or_statement {

        statement {

          size_constraint_statement {
            comparison_operator = "GT"
            size                = "4093"

            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            text_transformation {
              priority = 12
              type     = "NONE"
            }
          }
        }

        statement {

          size_constraint_statement {
            comparison_operator = "GT"
            size                = "1024"

            field_to_match {
              query_string {}
            }

            text_transformation {
              priority = 13
              type     = "NONE"
            }
          }
        }

        statement {

          size_constraint_statement {
            comparison_operator = "GT"
            size                = "512"

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 14
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "${var.waf_prefix}-generic-size-restrictions" // only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-2"
    priority = 2

    action {
      allow {}
    }

    statement {

      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.admin_remote_ips.arn // U-Cloud IP
      }
    }
    
    visibility_config {     // Each rule requires a Local visibility_config
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.waf_prefix}-white-list-black-list"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-3"
    priority = 3

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      and_statement {
        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "example-session-id"

            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            text_transformation {
                priority = 11
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"

            field_to_match {
              single_header {
                name = "authorization"
              }
            }

            text_transformation {
              priority = 12
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {     // Each rule requires a visibility_config
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_prefix}-detect-bad-auth-tokens"
    sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-4"
    priority = 4

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      or_statement {
        statement {

          sqli_match_statement {

            field_to_match {
              body {}
            }

            text_transformation {
              priority = 11
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 12
              type     = "URL_DECODE"
            }
          }
        }
      
        statement {

          sqli_match_statement {

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 13
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 14
              type     = "URL_DECODE"
            }
          }
        }

        statement {

          sqli_match_statement {

            field_to_match {
              query_string {}
            }

            text_transformation {
              priority = 15
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 16
              type     = "URL_DECODE"
            }
          }
        }

        statement {

          sqli_match_statement {

            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            text_transformation {
              priority = 17
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 18
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "${var.waf_prefix}-generic-mitigate-sqli" // only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-5"
    priority = 5

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      or_statement {
        statement {

          xss_match_statement {

            field_to_match {
              body {}
            }

            text_transformation { // wafv2 now you can use max 3 Text Transformation
              priority = 11
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 12
              type     = "URL_DECODE"
            }
          }
        }

        statement {

          xss_match_statement {

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 13
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 14
              type     = "URL_DECODE"
            }
          }
        }

        statement {

          xss_match_statement {

            field_to_match {
              query_string {}
            }

            text_transformation {
              priority = 15
              type     = "HTML_ENTITY_DECODE"
            }
                        
            text_transformation {
              priority = 16
              type     = "URL_DECODE"
            }
          }
        }

        statement {

          xss_match_statement {

            field_to_match {
              single_header {
                name = "cookie"
              }
            }

            text_transformation {
              priority = 17
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 18
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "${var.waf_prefix}-generic-mitigate-xss" // only allowed characters (A-Z, a-z, 0-9, -, _)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-6"
    priority = 6

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      or_statement {
        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "://"

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 11
                type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
                priority = 12
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "../"

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 13
                type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
                priority = 14
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "://"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 15
                type     = "HTML_ENTITY_DECODE"
            }
            
            text_transformation {
                priority = 16
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "../"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 17
                type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
                priority = 18
                type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {     // Each rule requires a visibility_config
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_prefix}-generic-detect-rfi-lfi-traversal"
    sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-7"
    priority = 7

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      or_statement {
        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "_ENV["

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 11
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "auto_append_file="

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 12
                type     = "URL_DECODE"
            }
          }
        }
        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "disable_functions="

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 13
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "auto_prepend_file="

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 14
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "safe_mode="

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 15
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "_SERVER["

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 16
                type     = "URL_DECODE"
            }
          }
        } 

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "allow_url_include="

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 17
                type     = "URL_DECODE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "open_basedir="

            field_to_match {
              query_string {}
            }

            text_transformation {
                priority = 18
                type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {     // Each rule requires a visibility_config
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_prefix}-generic-detect-php-insecure"
    sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-8"
    priority = 8

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      and_statement {
        statement {

          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = "post"

            field_to_match {
              method {}
            }

            text_transformation {
              priority = 11
              type     = "LOWERCASE"
            }
          }
        }

        statement {

          size_constraint_statement {
            comparison_operator = "EQ"
            size                = "36"

            field_to_match {
              single_header {
                name = "x-csrf-token"
              }
            }

            text_transformation {
              priority = 12
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "${var.waf_prefix}-generic-enforce-csrf" // only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-9"
    priority = 9

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      or_statement {
        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".cfg"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 13
                type     = "LOWERCASE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".backup"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 14
                type     = "LOWERCASE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".ini"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 15
                type     = "LOWERCASE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".conf"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 16
                type     = "LOWERCASE"
            }
          }
        }
        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".log"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 17
                type     = "LOWERCASE"
            }
          }
        }
        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".bak"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 18
                type     = "LOWERCASE"
            }
          }
        }
        statement {

          byte_match_statement {
            positional_constraint = "ENDS_WITH"
            search_string         = ".config"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 19
                type     = "LOWERCASE"
            }
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = "/includes"

            field_to_match {
              uri_path {}
            }

            text_transformation {
                priority = 20
                type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "${var.waf_prefix}-generic-detect-ssi"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-10"
    priority = 10

    action {
      dynamic "block" {
        for_each = var.enableBlock ? [1] : []
        content {}
      }
      dynamic "count" {
        for_each = var.enableBlock ? [] : [1]
        content {}
      }
    }

    statement {

      and_statement {
        statement {

          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.admin_remote_ips.arn
          }
        }

        statement {

          byte_match_statement {
            positional_constraint = "STARTS_WITH" // John 에게 체크
            search_string         = "/admin"

            field_to_match {
              uri_path {}
            }

            text_transformation {   // 이제는 동시에 여러개의 text_transformations 사용 가능 priority 설정
              priority = 11
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {     // Each rule requires a visibility_config
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_prefix}-generic-detect-admin-access"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-11"
    priority = 11

    action {
      # dynamic "block" {
      #   for_each = var.enableBlock ? [1] : []
      #   content {}
      # }
      # dynamic "count" {
      #   for_each = var.enableBlock ? [] : [1]
      #   content {}
      # }
      count { }
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = "4096"

        field_to_match {
          body {}
        }

        text_transformation {
          priority = 11
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = "${var.waf_prefix}-body-size-restrictions" // only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_)
      sampled_requests_enabled   = false
    }
  }

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.waf_prefix}-genericowaspacl"
    sampled_requests_enabled   = false
  }
}

resource "aws_cloudwatch_log_group" "waf-logging" {
  name = "aws-waf-logs-${var.waf_prefix}-dev-moga"
  tags = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "logging_configuration" {
  log_destination_configs = [aws_cloudwatch_log_group.waf-logging.arn]
  resource_arn            = aws_wafv2_web_acl.waf_acl.arn
}
