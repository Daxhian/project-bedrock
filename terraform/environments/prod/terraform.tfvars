region               = "us-east-1"
cluster_name         = "project-bedrock-cluster"
cluster_version      = "1.34"
vpc_name             = "project-bedrock-vpc"
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
node_instance_type   = "t3.medium"
node_desired_size    = 2
node_min_size        = 1
node_max_size        = 3
student_id           = "altsoe0253240"

# Set these via environment variables or a local override file — never commit real passwords
# export TF_VAR_db_password="YourStrongPassword123!"
db_username = "adminuser"
db_password = "ChangeMe123!"   # Override with TF_VAR_db_password in CI/CD
