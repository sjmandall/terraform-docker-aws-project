resource "aws_security_group" "mysg" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "mysg"
  }

  #HTTP
  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  #HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes NodePort range

  ingress {
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #Grafana

  ingress {
  from_port   = 32000
  to_port     = 32000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow kubelet communication (REQUIRED)
ingress {
  from_port   = 10250
  to_port     = 10250
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
}

# For accessing nodeport
ingress {
    from_port = 30348
    to_port = 30348
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


# Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}