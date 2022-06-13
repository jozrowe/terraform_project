# output "vpc_id" {
#   value = aws_security_group.my_webserver.id
# }

# output "instance_public_ip" {
#   description = "Public IP address of the EC2 instance"
#   value       = aws_instance.my_webserver.public_ip
# }

output "alb_dns_endpoint" {
  description = "Public IP address of the ALB"
  value       = aws_alb.alb.dns_name
}