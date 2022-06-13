#######################################################################
# Placing TFstate file which related to RDS deployment to S3 bucket
#######################################################################

terraform {
    backend "s3" {
        bucket = "deni-practice-project-terraform-state"
        key = "dev/rds/terraform.tfstate"
        region = "us-east-1"
    }
}


#######################################################################
# Getting information from TFstate file related to Layer1-Network for further usage
#######################################################################

data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket = "deni-practice-project-terraform-state"
        key = "dev/network/terraform.tfstate"
        region = "us-east-1"
    }
}