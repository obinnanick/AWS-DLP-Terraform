provider "aws" {
  region = "us-east-1"
}

#CREATING S3 BUCKET
resource "aws_s3_bucket" "sensitive_data" {
  bucket = "macie-sensitive-data-bucket234"

}
#Providing the sensitive data in the file
resource "aws_s3_object" "sample_sensitive_file" {
  bucket = aws_s3_bucket.sensitive_data.bucket
  key    = "credit_card_info.txt"
  content = <<EOT
  Name: John Doe
  Card Number: 1234-5678-9012-3456
  CVV: 123
  Expiry: 12/26
  EOT
}
#Providing the second sensitive data in the file
resource "aws_s3_object" "nigerian_bvn_data" {
  bucket = aws_s3_bucket.sensitive_data.bucket
  key    = "nigerian_bvn_data.csv"
  content = <<EOT
  Name, BVN
  Marcus, 12345678901
  Nick, 09876543210
  EOT
}
# Getting AWS Account ID
data "aws_caller_identity" "current" {

}



resource "aws_macie2_classification_job" "sensitive_data_scan" {
  name         = "macie-s3-scan"
  job_type     = "ONE_TIME"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sensitive_data.id]
    }

    # ✅ This enables all AWS Macie managed identifiers
    scoping {
      includes {
        and {
          simple_scope_term {
            comparator = "EQ"
            key        = "OBJECT_EXTENSION"
            values     = ["txt", "csv"]
          }
        }
      }
    }
  }

  sampling_percentage = 100
}
resource "aws_cloudwatch_event_rule" "macie_finding" {
  event_pattern = jsonencode({
    "source": ["aws.macie"],
    "detail-type": ["Macie Finding"]
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.macie_finding.name
  target_id = "send_to_sns"
  arn       = aws_sns_topic.macie_alert.arn
}

# SNS Topic for Macie Alerts
resource "aws_sns_topic" "macie_alert" {
  name = "macie-alert-topic"
}
# SNS Subscription (Email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.macie_alert.arn
  protocol  = "email"
  endpoint  = "nickobinna@yandex.com" 
}
# EventBridge triggering Lambda
resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.macie_finding.name
  target_id = "send_to_lambda"
  arn       = aws_lambda_function.macie_handler.arn
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
}

# IAM Policy for Lambda to Access S3 and Publish to SNS
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          aws_s3_bucket.sensitive_data.arn,
          "${aws_s3_bucket.sensitive_data.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": aws_sns_topic.macie_alert.arn
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "macie_handler" {
  function_name = "macie-handler"
  handler       = "macie_handler.lambda_handler"
  runtime       = "python3.8"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  role = aws_iam_role.lambda_exec.arn
}

# CloudWatch Logs for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.macie_handler.function_name}"
  retention_in_days = 14
}
