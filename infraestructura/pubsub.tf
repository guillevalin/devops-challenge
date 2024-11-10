# Crear el tema SNS FIFO
resource "aws_sns_topic" "devops_challenge_sns_fifo" {
  name                     = "devops-challenge-topic.fifo"
  fifo_topic               = true
  content_based_deduplication = true

  tags = {
    Name = "devops-challenge-sns-topic"
  }
}

# Crear la cola SQS FIFO
resource "aws_sqs_queue" "devops_challenge_sqs_fifo" {
  name                        = "devops-challenge-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = 86400  # Opcional: Ajusta el tiempo de retención según sea necesario (24 horas)

  tags = {
    Name = "devops-challenge-sqs-queue"
  }
}

# Suscripción de la cola SQS al tema SNS
resource "aws_sns_topic_subscription" "sns_to_sqs_subscription" {
  topic_arn = aws_sns_topic.devops_challenge_sns_fifo.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.devops_challenge_sqs_fifo.arn

  # Configura los atributos para mensajes FIFO
  raw_message_delivery = true

  # Establece permisos para que SNS pueda enviar mensajes a SQS
  depends_on = [aws_sqs_queue_policy.allow_sns_to_sqs]
}

# Política de permisos para que SNS envíe mensajes a la cola SQS
resource "aws_sqs_queue_policy" "allow_sns_to_sqs" {
  queue_url = aws_sqs_queue.devops_challenge_sqs_fifo.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "sns.amazonaws.com" },
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.devops_challenge_sqs_fifo.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.devops_challenge_sns_fifo.arn
          }
        }
      }
    ]
  })
}