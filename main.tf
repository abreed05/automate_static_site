# Create S3 Bucket with policy

resource "aws_s3_bucket" "static_website_bucket" {
  bucket = var.domain
  acl    = "public-read"

  tags = {
    Name = "Static_site"
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::${var.domain}/*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
  }
}

# Create Hosted Zone and pull name servers

resource "aws_route53_zone" "primary" {
  name = var.domain

}

# null_resource to call Python script to update Godaddy Name servers after AWS Hosted Zone has been created
# the executable bit must be set on the python scripts to run as they currently are configured. 
# this can be accomplished with chmod +x dns.py or chmod +x repo.py 


resource "null_resource" "updateDNS" {
  depends_on = [
    aws_route53_zone.primary,
  ]

  provisioner "local-exec" {
    command = "./dns.py"
  }
}

# null resource to call Python script to initalize a blank github repo based on domain name
resource "null_resource" "repopy" {
  depends_on = [aws_route53_zone.primary]

  provisioner "local-exec" {
    command = "./repo.py"
  }
}

# Request certificate and validate via DNS

resource "aws_acm_certificate" "default" {
  domain_name       = var.domain
  validation_method = "DNS"
}


resource "aws_route53_record" "validation" {
  name    = aws_acm_certificate.default.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.default.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.primary.zone_id
  records = ["${aws_acm_certificate.default.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn

  validation_record_fqdns = [
    aws_route53_record.validation.fqdn,
  ]
}

# Create Cloudfront Distribution 
# set to depend on the aws_acm_certificate_validation block. This ensures that the ACM cert has been created
# before the cloudfront distribution is created. 

resource "aws_cloudfront_distribution" "root_distribution" {

  origin {

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_s3_bucket.static_website_bucket.website_endpoint
    origin_id   = var.domain
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.domain
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["${var.domain}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.default.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
  depends_on = [aws_acm_certificate_validation.default]
}

# Adds the cloudfront distribution to as an A record to route53

resource "aws_route53_record" "cloudfrontrecord" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.root_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


