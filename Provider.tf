provider "aws" {
  region = var.AWS_REGION
#access_key = var.AWS_ACCESS_KEY
#secret_key = var.AWS_SECRET_KEY

assume_role {
  #The role ARN within Account B to AssumeRole into. Created in step 1.
  role_arn = "arn:aws:iam::495599767034:role/Engineer"
  }
}
