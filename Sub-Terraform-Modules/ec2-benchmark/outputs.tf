output "server_benchmark_001_Private_IP" {
  description = "IP address of Source VM"
 value = module.server_benchmark_001.ec2_private_address
}
output "client_benchmark_002_Private_IP" {
  description = "IP address of Destination VM"
  value = module.client_benchmark_002.ec2_private_address
}
output "server_benchmark_001_Public_IP" {
  description = "IP address of Source VM"
 value = module.server_benchmark_001.ec2_public_address
}
output "client_benchmark_002_Public_IP" {
  description = "IP address of Destination VM"
  value = module.client_benchmark_002.ec2_public_address
}
