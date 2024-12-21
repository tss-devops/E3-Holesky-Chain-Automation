data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }

    owners = ["099720109477"]  # Canonical

}

resource "aws_key_pair" "login_key" {
  key_name = "login_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuE8Bx4Cxtv+JYSwbcCJG82FFei0kllnzXVCO8nugKaLFfsnPfFVVSVIG5gOpgordVqRoXfnMFsL4z//4LeGfh6ZneM2t4YudrD67CPh0C9uEXxOVM8u6BDu2wN8OZewgKCvJsz7v05rSfHYMfQWhLdxO1QuLnC2Qex6OOOiL56FIdIZinzLEXgB4AL+80GuwUWlwJtRQvJZmm1EBogoH5e/4nfO6zH5bH2Q2/BPOUfeYwllE+L396/V7lfzZ9Ypd01CIynI/ETiMKJMjIGjXWpWeqbqSk9iFwy9EuQ0D2I5kBrLzPpvYCYelBeBpwUnM3zVkWEEEFEar0UYHQ/QWyB6HsuiIl49cgAkrwMNGC6a6M1MGnxLbr2cCURcAvC7TWCYxn7V8Bvl7/xbRUVBjEfxJkXZuRFUD4m1gAIJ20PXqz4QSP8PjNGECQUGuPHBpTtgw4tp/xxI7i9dsuNNkiExKA5v4lER5czlvkPv28rtHI8s7uRTw5VdC/ChFXCqU= gautam@21-ZEE-LAP023"
}

resource "aws_instance" "bastion_host" {
  ami = data.aws_ami.ubuntu.id

  instance_type = "t2.micro"
  key_name = aws_key_pair.login_key.key_name
  tags = {
    Name = "Bastion Host"
  }

  associate_public_ip_address = true
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id, aws_security_group.private_sg.id]

  provisioner "file" {
    source = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/id_rsa"

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }
  }
}


resource "aws_instance" "ethereum" {
  ami = data.aws_ami.ubuntu.id

  instance_type = "t2.medium"
  key_name = aws_key_pair.login_key.key_name
  count = 2
  vpc_security_group_ids = [ aws_security_group.private_sg.id ]

  tags = {
    Name = "Ethereum-${count.index}"
  }

  subnet_id = var.private_subnet_ids[count.index]
  
}


# resource "aws_instance" "by_chaining" {
#   for_each = zipmap(
#     range(length(var.private_subnet_ids)),
#     var.private_subnet_ids
#   )

#   key_name               = aws_key_pair.login_key.key_name
#   vpc_security_group_ids = [aws_security_group.private_sg]
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t2.micro"
#   subnet_id              = each.value

#   tags = {
#     Name = "Ethereum-${each.value}"
#   }
# }

