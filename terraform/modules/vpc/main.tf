# ─────────────────────────────────────────
# VPC
# ─────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# ─────────────────────────────────────────
# INTERNET GATEWAY
# ─────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# ─────────────────────────────────────────
# PUBLIC SUBNETS
# ─────────────────────────────────────────
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.vpc_name}-public-${count.index + 1}"
    # Required tags for AWS Load Balancer Controller to discover subnets
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ─────────────────────────────────────────
# PRIVATE SUBNETS
# ─────────────────────────────────────────
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                        = "${var.vpc_name}-private-${count.index + 1}"
    # Required tags for AWS Load Balancer Controller (internal LBs)
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ─────────────────────────────────────────
# ELASTIC IPs FOR NAT GATEWAYS
# ─────────────────────────────────────────
resource "aws_eip" "nat" {
  count      = length(var.public_subnet_cidrs)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.vpc_name}-eip-nat-${count.index + 1}"
  }
}

# ─────────────────────────────────────────
# NAT GATEWAYS (one per AZ for HA)
# ─────────────────────────────────────────
resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  }
}

# ─────────────────────────────────────────
# ROUTE TABLES
# ─────────────────────────────────────────

# Single public route table (shared by both public subnets)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route tables — one per AZ, each pointing to its own NAT GW
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.vpc_name}-rt-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
