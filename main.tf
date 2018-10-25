provider "aws" {
  region = "eu-west-1"
}

resource "aws_guardduty_detector" "main" {
  enable = true
}

data "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/guardduty_s3.py"
  output_path = "${path.module}/guardduty_s3.py.zip"
}

resource "aws_lambda_function" "guardduty_s3" {
  filename         = "${path.module}/guardduty_s3.py.zip"
  source_code_hash = "${data.archive_file.source.output_base64sha256}"
  function_name    = "guardduty_s3"
  description      = "Write GuardDuty events to S3"
  runtime          = "python3.6"
  role             = "${aws_iam_role.guardduty_s3.arn}"
  handler          = "guardduty_s3.lambda_handler"
  timeout          = 10
  count            = "${var.enabled ? 1 : 0}"

  environment {
    variables = {
      bucket = "${var.bucket}"
      prefix = "${var.prefix}"
    }
  }

  lifecycle {
    # These will change even if the archive hashsum is the same.
    ignore_changes = ["filename", "last_modified"]
  }
}

resource "aws_cloudwatch_event_rule" "guardduty_finding" {
  name_prefix = "guardduty-finding-"
  description = "GuardDuty Finding"
  count       = "${var.enabled ? 1 : 0}"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ]
}
PATTERN
}

resource "aws_lambda_permission" "guardduty_s3" {
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = "${aws_lambda_function.guardduty_s3.function_name}"
  source_arn    = "${aws_cloudwatch_event_rule.guardduty_finding.arn}"
  count         = "${var.enabled ? 1 : 0}"
}

resource "aws_cloudwatch_event_target" "guardduty_s3" {
  rule  = "${aws_cloudwatch_event_rule.guardduty_finding.name}"
  arn   = "${aws_lambda_function.guardduty_s3.arn}"
  count = "${var.enabled ? 1 : 0}"
}

data "aws_iam_policy_document" "guardduty_s3" {
  statement {
    actions = [
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}",
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}/${var.prefix}*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "guardduty_s3" {
  name_prefix = "guardduty_s3-"
  policy      = "${data.aws_iam_policy_document.guardduty_s3.json}"
  count       = "${var.enabled ? 1 : 0}"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "guardduty_s3" {
  name               = "guardduty_s3"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  count              = "${var.enabled ? 1 : 0}"
}

resource "aws_iam_role_policy_attachment" "guardduty_s3" {
  role       = "${aws_iam_role.guardduty_s3.name}"
  policy_arn = "${aws_iam_policy.guardduty_s3.arn}"
  count      = "${var.enabled ? 1 : 0}"
}
