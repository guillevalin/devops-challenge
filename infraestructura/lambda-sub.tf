resource "aws_lambda_function" "sns_subscriber" {
  function_name = "sns_subscriber_function"
  role          = aws_iam_role.lambda_execution_role.arn
  image_uri = var.docker_image_sub
  package_type = "Image"
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }  
  tags = {
    Name = "docker-lambda"
  }
  environment {
    variables = {
      DB_HOST     = "your-db-host"
      DB_USER     = "your-db-user"
      DB_PASSWORD = "your-db-password"
      DB_NAME     = "your-db-name"
    }
  }
}

resource "aws_sns_topic_subscription" "sns_to_lambda" {
  topic_arn = aws_sns_topic.user_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_subscriber.arn

  # Permitir que SNS invoque la función Lambda
  raw_message_delivery = true
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_subscriber.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_topic.arn
}