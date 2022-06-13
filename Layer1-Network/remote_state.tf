#######################################################################
# Placing TFstate file which related to Layer1-Network deployment to S3 bucket
#######################################################################

terraform {
  backend "s3" {
    bucket = "deni-practice-project-terraform-state"     // Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate"             // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                                 // Region where bucket created
  }
}