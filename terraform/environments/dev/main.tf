resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
    Tier = "public"
  }
}

resource "aws_subnet" "app" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = count.index == 0 ? "10.0.11.0/24" : "10.0.12.0/24"

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
    Tier = "application"
  }
}

resource "aws_subnet" "database" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = count.index == 0 ? "10.0.21.0/24" : "10.0.22.0/24"

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-database-${count.index + 1}"
    Tier = "database"
  }
}
