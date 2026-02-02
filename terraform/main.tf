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




