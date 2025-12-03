resource "aws_dynamodb_table" "contact_messages" {
  name           = "ContactMessages"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "ContactUs"
  }
}
