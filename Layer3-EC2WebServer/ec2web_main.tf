#######################################################################
# Layer III -- EC2 WebServer with Wordpress
# This Terraform File will create components that related to EC2 WebServer with Wordpress:
#
# 1. VPC
# 2. Internet Gateway for VPC
# 3. Two Public Subnets with Route Tables to Internet Gateway
# 4. Two NAT gateways with Elastic IPs which will be atached to private subnets
# 5. Two Private Subnets with Route Tables to NAT Gateway
#######################################################################


provider "aws" {
    region = "us-east-1"
}



#######################################################################
# Identifying latest Amazon Linux Image
#######################################################################

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}


#######################################################################
# Creating an instance configuration template that an Auto Scaling group uses to launch EC2 instances.
#######################################################################

resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "wordpress-web-instance"
  image_id                    = data.aws_ami.latest_amazon_linux.id # Amazon Linux AMI
  instance_type               = "t2.micro"
  security_groups = [aws_security_group.my_webserver.id]
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}" # taken for iam_main.tf
  user_data              = file("user_data.sh") # user data is run one time at first launch
 # associate_public_ip_address = true
  key_name = "main-key-pair"

  lifecycle {
    create_before_destroy = true
  }
}

#######################################################################
# Security Group, which will allow incoming traffic from Application Load Balancer
#######################################################################

resource "aws_security_group" "my_webserver" {
  name        = "WebServer Security Group"
  description = "My Security Group for WebServer with WordPress"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   security_groups = ["${aws_security_group.alb.id}"] # taken for alb_main.tf
  # }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   security_groups = ["${aws_security_group.alb.id}"] # taken for alb_main.tf
  # }

 ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "${var.env}-exercise"
  }
}


#######################################################################
# An Auto Scaling group contains a collection of Amazon EC2 instances 
# that are treated as a logical grouping for the purposes of automatic scaling and management. 
# All instances will be placed in private networf from Layer1.
#######################################################################

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = "${aws_launch_configuration.launch_config.id}"
  min_size             = 2
  max_size             = 3
  target_group_arns    = ["${aws_alb_target_group.group.arn}"]
  vpc_zone_identifier  = [data.terraform_remote_state.network.outputs.private_subnet_1, data.terraform_remote_state.network.outputs.private_subnet_2,]

  tag {
    key                 = "Name"
    value               = "${var.env}-ASG-WebServer-WordPress"
    propagate_at_launch = true
  }
}