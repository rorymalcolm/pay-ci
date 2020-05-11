resource "aws_iam_role" "waf_firehose_iam_role" {
    name = "waf-firehose-iam-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "firehose.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
EOF
}


resource "aws_kinesis_firehose_delivery_stream" "waf_kinesis_stream" {
  provider    = aws.us
  name        = "aws-waf-logs-govuk-pay-waf-kinesis-stream-${var.environment}"
  destination = "s3"

  s3_configuration {
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
    role_arn           = aws_iam_role.waf_firehose_iam_role.arn
    bucket_arn         = aws_s3_bucket.waf_log_bucket.arn
  }
}
