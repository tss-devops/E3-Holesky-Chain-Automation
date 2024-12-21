resource "aws_vpc" "eth_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Eth-VPC"
  }
}

resource "aws_subnet" "eth_public_subnet" {
  vpc_id     = aws_vpc.eth_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "Public Subnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_subnet" "eth_private_subnet" {
    count = 2
    vpc_id = aws_vpc.eth_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index +2 )
    availability_zone = element(data.aws_availability_zones.available.names, count.index +1)

    tags = {
      Name = "Private subnet ${count.index +1}"
    }
}

resource "aws_eip" "nat_eip" {
  
}

resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.eth_public_subnet.id
  allocation_id = aws_eip.nat_eip.id
  depends_on = [ aws_eip.nat_eip ]

  tags = {
    Name = "Eth NAT Gate way"
  }
}


resource "aws_internet_gateway" "public_eth_gateway" {
  vpc_id = aws_vpc.eth_vpc.id 

  tags = {
    Name = "Eth Internet gateway"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eth_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_eth_gateway.id 

  }

  tags = {
    Name = "Public Route Table"
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eth_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id

  }

  tags = {
    Name = "Private Route Table"
  }
}


resource "aws_route_table_association" "public_route_table_association" {
  subnet_id = aws_subnet.eth_public_subnet.id 
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(aws_subnet.eth_private_subnet)
  subnet_id = aws_subnet.eth_private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

