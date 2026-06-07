resource "aws_dynamodb_table" "carts" {
  name         = "retailstore-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name    = "retailstore-carts"
    Project = "karatu-2025-capstone"
  }
}