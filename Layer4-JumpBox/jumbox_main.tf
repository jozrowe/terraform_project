#######################################################################
# Layer IV -- Jumpboxs
# This Terraform File will create EC2 JumpBox in public subnet for troubleshooting purposes.
#######################################################################

provider "aws" {
    region = "us-east-1"
}



#######################################################################
#===========================
#######################################################################

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.latest_amazon_linux.id # Amazon Linux AMI
  instance_type          = "t2.micro"
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_1
  vpc_security_group_ids = [aws_security_group.jumpbox.id]
  user_data              = file("user_data.sh")
  user_data_replace_on_change = true
  key_name = "main-key-pair"

  tags = {
    Name = "${var.env}-JumpBox"
  }
}



resource "aws_security_group" "jumpbox" {
  name        = "JumpBox Security Group"
  description = "My Security Group for JumBox"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

 ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "${var.env}-jumpbox"
  }
}