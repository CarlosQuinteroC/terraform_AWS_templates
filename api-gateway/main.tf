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

//creaccion del recurso API de tipo HTTP
resource "aws_apigatewayv2_api" "visitorsCounterAPI" {
  name          = "visitorsCounterAPI"
  protocol_type = "HTTP"
}

//Creación de la ruta GET
resource "aws_apigatewayv2_route" "get_visitors" {
  api_id    = aws_apigatewayv2_api.visitorsCounterAPI.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.integration_get.id}" //se define a donde dirigir la petición en este caso al recurso de integracion definido mas adelante
}

resource "aws_apigatewayv2_route" "post_visitors" {
  api_id    = aws_apigatewayv2_api.visitorsCounterAPI.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.integration_post.id}"
}

// Se define el recurso de integracion para el metodo GET 
resource "aws_apigatewayv2_integration" "integration_get" {
  api_id           = aws_apigatewayv2_api.visitorsCounterAPI.id
  integration_type = "HTTP_PROXY"
  integration_method  = "GET"
  integration_uri  = "http://example.com/get"
}

resource "aws_apigatewayv2_integration" "integration_post" {
  api_id           = aws_apigatewayv2_api.visitorsCounterAPI.id
  integration_type = "HTTP_PROXY"
  integration_method  = "POST"
  integration_uri  = "http://example.com/post"
}

// Se define el recurso stage para el API
resource "aws_apigatewayv2_stage" "visitorsCounterAPI" {
  api_id = aws_apigatewayv2_api.visitorsCounterAPI.id
  name   = "visitorsCounterAPIv2"
  auto_deploy = true
}