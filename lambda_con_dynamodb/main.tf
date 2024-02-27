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

/* 1- SE CREA LA TABLA DE DYNAMO DB*/
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
  name           = "visitorsCounterv2" //poner este mismo nombre en la funcion lambda
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

// 2- SE CREA LA FUNCION LAMBDA QUE CONSULTA LA TABLA DE DYNAMO DB
//Create policy document for role  
data "aws_iam_policy_document" "lambda_assum_role_policy"{
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
//create Role  using policy document called "lambda_assum_role_policy"
resource "aws_iam_role" "lambda_role" {  
  name = "lambda-lambdaRole-waf"  
  assume_role_policy = data.aws_iam_policy_document.lambda_assum_role_policy.json
}

//Create policy document with the required permissions for the lambda function to access dynamodb
data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Scan",
                "dynamodb:UpdateItem"]
    resources = ["*"]
  }
}
//create policy with policy document called "policy"
resource "aws_iam_policy" "policy" {
  name        = "lambda_to_dynamodb_policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.policy.json
}

//Attach the policy to the role
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy.arn
}
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "visitorsCounterLambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }
}