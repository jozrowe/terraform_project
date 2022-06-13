#######################################################################
# Layer II -- RDS
# This Terraform File will create components that related to MySQL Amazon RDS (Amazon Relational Database Service):
#
# 1. Random password for admin, which will be stored in AWS Systems Manager service
# 2. Two DB Subnets in VPC from Layer1 for High Availability
# 3. Security Group for RDS Instance
# 4. RDS intance itself on MySQL Engine
#######################################################################

provider "aws" {
    region = "us-east-1"
}


#######################################################################
# Create random string (12 symbols) for future RDS password
#######################################################################

resource "random_string" "rds_pass"{
    length = 12
    special = true
    override_special = "!^_="

}

#######################################################################
# Save encrypted random string to Systems Manager 
#######################################################################

resource "aws_ssm_parameter" "rds_password"{
    name = "prod_mysql"
    description = "Master Password for RDS MySQL"
    type = "SecureString"
    value = random_string.rds_pass.result
}

#######################################################################
# Get our pass as a existing value from AWS
#######################################################################

data "aws_ssm_parameter" "my_rds_pass" {
    name = "prod_mysql"
    
    depends_on = [aws_ssm_parameter.rds_password]

}


#######################################################################
# Creating DB Subnets with DB Subnet Group
#######################################################################

data "aws_availability_zones" "available" {}

resource "aws_subnet" "db_subnet_1" {
  vpc_id                  = data.terraform_remote_state.network.outputs.vpc_id
  cidr_block = "10.0.13.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

    tags = {
        Name = "${var.env}-db-subnet-1"
        Project = "${var.env}-exercise"
    }
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id                  = data.terraform_remote_state.network.outputs.vpc_id
  cidr_block = "10.0.23.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

    tags = {
        Name = "${var.env}-db-subnet-2"
        Project = "${var.env}-exercise"
    }
}


resource "aws_db_subnet_group" "default" {
  name        = "${var.rds_instance_identifier}-subnet-group"
  description = "RDS subnet group for ${var.rds_instance_identifier}"
  subnet_ids  = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
     tags = {
    Name = "${var.env}-DB-subnet-group"
    Project = "${var.env}-exercise"
  }
}

#######################################################################
# Security Group Creation for RDS Instance:
#######################################################################

resource "aws_security_group" "db-server-sg" {
  name        = "${var.env}-rds-instance-sg"
  description = "Security Group for RDS Instance"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-rds-instance-sg"
    Project = "${var.env}-exercise"
  }
}

#######################################################################
# RDS Instance creation on MySQL engine with admin user and pass from random string
#######################################################################

resource "aws_db_instance" "default" {
  identifier           = "${var.env}-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name                 = "${var.env}"
  username             = "administrator"
  password             = data.aws_ssm_parameter.my_rds_pass.value
  db_subnet_group_name      = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids    = ["${aws_security_group.db-server-sg.id}"]
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  tags = {
    Project = "${var.env}-exercise"
  }
}
