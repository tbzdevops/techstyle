output "master_public_ips" {
  description = "Öffentliche IP-Adressen der Master Nodes"
  value       = aws_instance.master[*].public_ip
}

output "worker_public_ips" {
  description = "Öffentliche IP-Adressen der Worker Nodes"
  value       = aws_instance.worker[*].public_ip
}

output "kubernetes_api_endpoint" {
  description = "Kubernetes API Endpoint"
  value       = length(aws_instance.master) > 0 ? "https://${aws_instance.master[0].public_ip}:6443" : ""
}
