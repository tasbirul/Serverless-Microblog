# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "contact_us_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for DynamoDB and Logging
resource "aws_iam_policy" "lambda_policy" {
  name = "contact_us_lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.contact_messages.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Zip the Python code
data "archive_file" "backend_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend"
  output_path = "${path.module}/backend.zip"
}

# Lambda Function: Create Post
resource "aws_lambda_function" "create_post" {
  filename         = data.archive_file.backend_zip.output_path
  function_name    = var.lambda_create_post_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "create_post.lambda_handler"
  source_code_hash = data.archive_file.backend_zip.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contact_messages.name
    }
  }
}

# Lambda Function: Get Posts
resource "aws_lambda_function" "get_posts" {
  filename         = data.archive_file.backend_zip.output_path
  function_name    = var.lambda_get_posts_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_posts.lambda_handler"
  source_code_hash = data.archive_file.backend_zip.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contact_messages.name
    }
  }
}
