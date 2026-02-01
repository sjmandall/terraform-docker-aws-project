provider "aws" {
  region = "ap-south-1"

}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.myvpc.id
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "Private Subnet"
  }

}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.myvpc.id
   availability_zone       = "ap-south-1a"
  tags = {
    Name = "Public Subnet"
  }

}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

}

resource "aws_route_table_association" "public_subnet" {
  route_table_id = aws_route_table.myrt.id
  subnet_id      = aws_subnet.public_subnet.id

}




resource "aws_instance" "aicode01" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "realcode-key"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.mysg.id]
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

apt update -y
apt install docker.io git -y

systemctl start docker
systemctl enable docker

docker pull sjmandal/realcode:02

docker rm -f realcode || true

docker run -d -p 80:3000 -e NODE_ENV=production -e MONGO_URL="mongodb+srv://sjmandal2415_db_user:sjmandal2415_db_user@cluster0.iq6pvqp.mongodb.net/?appName=Cluster0" --name realcode sjmandal/realcode:02


EOF


 

  tags = {
    Name = "aicode01"
  }
}