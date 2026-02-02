resource "aws_instance" "k8s_master_aicode02" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  key_name                    = "realcode-key"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.mysg.id]
  associate_public_ip_address = true
  user_data = file("scripts/master.sh")
  
  


  root_block_device {
  volume_size = 20
  volume_type = "gp3"
 }

  

 

  tags = {
    Name = "k8s_master_aicode02"
  }
}