variable "environment" {
  description = "Deployment environment (e.g., prod, dev)"
  type        = string
  default     = "prod"
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "ContactMessages"
}

variable "lambda_create_post_name" {
  description = "Name of the Create Post Lambda function"
  type        = string
  default     = "CreatePostFunction"
}

variable "lambda_get_posts_name" {
  description = "Name of the Get Posts Lambda function"
  type        = string
  default     = "GetPostsFunction"
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "ContactUsAPI"
}
