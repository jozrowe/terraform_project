# Placing TFstate file which related to EC2 JumpBox deployment to S3 bucket
terraform {
    backend "s3" {
        bucket = "deni-practice-project-terraform-state"
        key = "dev/jumpbox/terraform.tfstate"
        region = "us-east-1"
    }
}


#######################################################################
# Getting information from TFstate file related to Layer1-Network & Layer2-RDS for further usage
#######################################################################

data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket = "deni-practice-project-terraform-state"
        key = "dev/network/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "rds" {
    backend = "s3"
    config = {
        bucket = "deni-practice-project-terraform-state"
        key = "dev/rds/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "alb" {
    backend = "s3"
    config = {
        bucket = "deni-practice-project-terraform-state"
        key = "dev/alb/terraform.tfstate"
        region = "us-east-1"
    }
}
