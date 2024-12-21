resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Bastion Host Security Group"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private_sg" {
  vpc_id = var.vpc_id
  tags = {
    Name = "Private instance Security Group"
  }

  ingress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.public_subnet_cidr]
  }

  dynamic "ingress" {
    for_each = var.private_subnet_cidrs
    content {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [ingress.value]
    }
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}