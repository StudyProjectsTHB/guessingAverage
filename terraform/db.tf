resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "tf-db_subnet_group"
  subnet_ids = [for i in range(var.num_private_subnets) : aws_subnet.private_subnet[i].id]
}

resource "aws_db_instance" "postgres_instance" {
  identifier            = "tf-p-postgres-db"
  allocated_storage     = 20
  engine                = "postgres"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  username              = var.aws_credentials["db_user"]
  password              = var.aws_credentials["db_password"]
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  multi_az              = true
  skip_final_snapshot   = true
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "tf-secret_manager"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_secret" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = <<EOT
                  {
                    "host": "${aws_db_instance.postgres_instance.address}",
                    "db_name": "${var.db_name}",
                    "username": "${var.aws_credentials["db_user"]}",
                    "password": "${var.aws_credentials["db_password"]}"
                  }
                  EOT
}