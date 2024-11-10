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
}

# Crear un grupo de subnets para la base de datos RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "DB Subnet Group"
  }
}