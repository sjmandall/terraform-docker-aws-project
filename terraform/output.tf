output "master_instance_url" {
  value = "http://${aws_instance.k8s_master_aicode02.public_ip}"

}

output "worker_instance_url" {
  value = "http://${aws_instance.k8s_worker_aicode03.public_ip}"

}