# ─────────────────────────────────────────
# RDS SUBNET GROUP (private subnets only)
# ─────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.cluster_name}-db-subnet-group"
  }
}

# ─────────────────────────────────────────
# SECURITY GROUP FOR RDS
# Only allow inbound from EKS nodes
# ─────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds-sg"
  description = "Allow DB traffic only from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-sg"
  }
}

# ─────────────────────────────────────────
# SECRETS MANAGER — store DB credentials
# Never hardcode passwords in manifests
# ─────────────────────────────────────────
resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.cluster_name}/mysql-credentials"
  recovery_window_in_days = 0   # Allow immediate deletion (useful for dev)

  tags = {
    Name = "${var.cluster_name}-mysql-secret"
  }
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = "retailstore"
  })
}

resource "aws_secretsmanager_secret" "postgres" {
  name                    = "${var.cluster_name}/postgres-credentials"
  recovery_window_in_days = 0

  tags = {
    Name = "${var.cluster_name}-postgres-secret"
  }
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = "retailstore"
  })
}

# ─────────────────────────────────────────
# RDS MYSQL
# ─────────────────────────────────────────
resource "aws_db_instance" "mysql" {
  identifier        = "${var.cluster_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "retailstore"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # No public access — private subnets only
  publicly_accessible = false
  multi_az            = false   # Single AZ to save cost

  skip_final_snapshot = true    # Allow clean terraform destroy

  tags = {
    Name = "${var.cluster_name}-mysql"
  }
}

# ─────────────────────────────────────────
# RDS POSTGRESQL
# ─────────────────────────────────────────
resource "aws_db_instance" "postgres" {
  identifier        = "${var.cluster_name}-postgres"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "retailstore"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.cluster_name}-postgres"
  }
}
