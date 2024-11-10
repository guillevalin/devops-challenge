provider "aws" {
  region = "us-east-1"
}

# Grupo de seguridad para la función Lambda que permitirá el acceso a la base de datos
resource "aws_security_group" "lambda_security_group" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "lambda_security_group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Crear un grupo de seguridad para la base de datos
resource "aws_security_group" "db_security_group" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "db_security_group"
  description = "Permitir acceso a la base de datos desde la red permitida"

  # Regla de entrada
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}