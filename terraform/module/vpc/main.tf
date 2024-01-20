# VPC - Elements
# vpc, internet gateway, subnets[Private and Public]
# route table, route table association

resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.env}"
  }
}

resource "aws_subnet" "public-subnet" {
  for_each          = var.subnets.public
  vpc_id            = aws_vpc.dev.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  # public subnet has value true
  map_public_ip_on_launch = each.value.map_public

  tags = {
    "Name"                                      = "${each.key}-${each.value.az}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private-subnet" {
  for_each          = var.subnets.private
  vpc_id            = aws_vpc.dev.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  # private subnet has value false
  map_public_ip_on_launch = each.value.map_public

  tags = {
    "Name"                                      = "${each.key}-${each.value.az}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "eks-public-rt"
  }
}

# Associating public subnets with route table 
resource "aws_route_table_association" "subnets" {
  for_each       = aws_subnet.public-subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-rt.id
}
