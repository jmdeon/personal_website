# Specify the provider and access details
terraform {
  backend "s3" {
    bucket = "terraform-state-joe"
    key    = "personal_website"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "b" {
  bucket = "thoughts.josephdeon.me"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "static_site" {
  for_each = fileset("${path.module}/thoughts/_site", "**")

  bucket = "${aws_s3_bucket.b.id}"
  key    = each.value
  source = "${path.module}/thoughts/_site/${each.value}"
  content_type = "${length(regexall(".*.css", "${each.value}")) > 0 ? "text/css" : "text/html"}"
  acl = "public-read"
  etag = "${filemd5("thoughts/_site/index.html")}"
}


resource "aws_s3_bucket_object" "error" {
  bucket = "${aws_s3_bucket.b.id}"
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  # etag is used to trigger updates
  etag = "${filemd5("error.html")}"
}

resource "aws_route53_record" "thoughts" {
  zone_id = "Z11J173D9X7UC7"
  name = "thoughts"
  type = "A"
  alias {
    name = "${aws_s3_bucket.b.website_domain}"
    zone_id = "${aws_s3_bucket.b.hosted_zone_id}"
    evaluate_target_health = false
  }
}
