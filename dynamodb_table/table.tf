terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}
// Create a DynamoDB item
resource "aws_dynamodb_table_item" "counter" {
  table_name = aws_dynamodb_table.visitorsCounterv2.name
  hash_key   = aws_dynamodb_table.visitorsCounterv2.hash_key

  item = <<ITEM
{
  "id": {"S": "count"},
  "value": {"N": "0"}
}
ITEM
}
// Create a DynamoDB table
resource "aws_dynamodb_table" "visitorsCounterv2" {
  name           = "visitorsCounterv2"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}