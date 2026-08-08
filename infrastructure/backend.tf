terraform {
  backend "s3" {
    bucket = "anshugahtori-terraform-state"
    key    = "serverless-cicd/terraform.tfstate"
    region = "us-east-1"
  }
}
