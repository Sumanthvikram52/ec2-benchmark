output "ec2_private_address" {
  value = aws_instance.server_instance.*.private_ip
}

output "ec2_id" {
  value = aws_instance.server_instance.*.id
}

output "ec2_public_address" {
  value = aws_instance.server_instance.*.public_ip
}