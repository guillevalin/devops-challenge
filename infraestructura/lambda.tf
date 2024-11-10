# Crear el rol IAM para Lambda con permisos básicos
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Adjuntar una política administrada de AWS que otorga permisos básicos de ejecución a Lambda
resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Crear la función Lambda con la imagen Docker
resource "aws_lambda_function" "docker_lambda" {
  function_name = "docker_lambda_function"
  role          = aws_iam_role.lambda_execution_role.arn
  image_uri = var.docker_image_pub
  package_type = "Image"
  environment {
    variables = {
      EXAMPLE_VAR = "example_value"
    }
  }
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }  
  tags = {
    Name = "docker-lambda"
  }
}

# Configuración opcional de permisos de invocación para otros servicios
resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}