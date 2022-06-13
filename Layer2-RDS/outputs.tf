output "rds_password" {
    value = data.aws_ssm_parameter.my_rds_pass.value
    sensitive = true
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}
