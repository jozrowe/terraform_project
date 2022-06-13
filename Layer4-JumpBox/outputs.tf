# output "vpc_id" {
#   value = aws_security_group.my_webserver.id
# }

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.jumpbox.public_ip
}