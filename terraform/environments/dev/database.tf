
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for the application database"

  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
    Tier = "database"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "platformdb"
  username = "platformadmin"
  port     = 3306

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  multi_az = false

  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = {
    Name        = "${var.project_name}-mysql"
    Tier        = "database"
    Environment = var.environment
  }
}