# Variables RDS
variable "db_name" {
  default = "airports"
}

variable "db_master_username" {
  default = "administrador"
}

variable "db_master_password" {
  default = "latam-challenge"
}

# Variables Lambda
variable "docker_image" {
  default = "dockerhub_user/repository_name:tag"
}

