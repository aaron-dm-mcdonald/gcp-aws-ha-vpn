# public facing subnets 

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  map_public_ip_on_launch = true # Assign public IPs to instances
  availability_zone       = "${var.region}a"
  tags = {
    Name = "public-a"
  }
}

# private subnets 

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_a_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  tags = {
    Name = "private-a"
  }
}