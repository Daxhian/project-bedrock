variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "eks_node_sg_id" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "cluster_name" { type = string }
