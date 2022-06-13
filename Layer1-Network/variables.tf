variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "denys"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.21.0/24",
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.12.0/24",
    "10.0.22.0/24",
  ]
}

variable "db_subnet_cidrs" {
  default = [
    "10.0.13.0/24",
    "10.0.23.0/24",
  ]
}
