# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  # Route for Internet traffic via Internet Gateway (IGW)
  route {
    cidr_block = "0.0.0.0/0"                  # All traffic to the Internet
    gateway_id = aws_internet_gateway.main.id # Route to the IGW
  }

  tags = {
    Name = "public-route-table"
    env  = "dev"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route_table.id
}


######

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  # Route for Internet traffic via NAT
  route {
    cidr_block = "0.0.0.0/0"             # All traffic to the Internet
    gateway_id = aws_nat_gateway.main.id # Route to the IGW
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_route_table.id
}