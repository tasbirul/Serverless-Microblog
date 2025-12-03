resource "aws_apigatewayv2_api" "http_api" {
  name          = "ContactUsAPI"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Integration: Create Post
resource "aws_apigatewayv2_integration" "create_post_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.create_post.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_post_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /posts"
  target    = "integrations/${aws_apigatewayv2_integration.create_post_integration.id}"
}

# Integration: Get Posts
resource "aws_apigatewayv2_integration" "get_posts_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_posts.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_posts_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /posts"
  target    = "integrations/${aws_apigatewayv2_integration.get_posts_integration.id}"
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "api_gw_create_post" {
  statement_id  = "AllowExecutionFromAPIGatewayCreatePost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_post.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/posts"
}

resource "aws_lambda_permission" "api_gw_get_posts" {
  statement_id  = "AllowExecutionFromAPIGatewayGetPosts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_posts.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/posts"
}
