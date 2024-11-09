provider "aws" {
  region = "us-east-1"
}

# Parámetros para la base de datos
variable "db_name" {
  default = "airports"
}

variable "db_master_username" {
  default = "admin"
}

variable "db_master_password" {
  default = "latam"  # Cambia a una contraseña segura
}

# Crear un clúster de base de datos RDS Aurora Serverless v2 con PostgreSQL 16.4
resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier      = "aurora-postgres-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "16.4"
  database_name           = var.db_name
  master_username         = var.db_master_username
  master_password         = var.db_master_password
  storage_encrypted       = true
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  
  # Configuración de escalado automático de Aurora Serverless v2
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1
  }

  # Parámetros adicionales de la base de datos
  db_cluster_parameter_group_name = "default.aurora-postgresql16"
  skip_final_snapshot             = true
}

# Crear instancias de base de datos asociadas al clúster RDS
resource "aws_rds_cluster_instance" "aurora_postgres_instance" {
  count             = 2
  identifier        = "aurora-postgres-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class    = "db.serverless"  # Serverless
  engine            = aws_rds_cluster.aurora_postgresql.engine
  engine_version    = aws_rds_cluster.aurora_postgresql.engine_version
}

# Crear un grupo de seguridad para la base de datos
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Permitir acceso a la base de datos desde la red permitida"

  # Regla de entrada (Ejemplo: Permitir acceso desde una IP específica)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Reemplaza con el rango de IPs permitidas
  }

  # Regla de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Asociar el grupo de seguridad al clúster de base de datos
resource "aws_rds_cluster_instance" "aurora_postgres_cluster_instance" {
  count               = 1
  cluster_identifier  = aws_rds_cluster.aurora_postgresql.id
  instance_class      = "db.serverless"  # Serverless
  engine              = aws_rds_cluster.aurora_postgresql.engine
  engine_version      = aws_rds_cluster.aurora_postgresql.engine_version
  publicly_accessible = false
  apply_immediately   = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
}

# Crear un subnet group para la base de datos
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = ["subnet-xxxxxx", "subnet-yyyyyy"]  # Reemplaza con los IDs de tus subnets

  tags = {
    Name = "DB Subnet Group"
  }
}