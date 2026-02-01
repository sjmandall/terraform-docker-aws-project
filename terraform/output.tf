output "instance_public_ip" {
  value = aws_instance.aicode01.public_ip

}

output "instance_url" {
  value = "http://${aws_instance.aicode01.public_ip}"

}

output "master_instance_url" {
  value = "http://${aws_instance.k8s_master_aicode02.public_ip}"

}

output "worker_instance_url" {
  value = "http://${aws_instance.k8s_worker_aicode03.public_ip}"

}