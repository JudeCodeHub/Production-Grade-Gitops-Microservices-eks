data "terraform_remote_state" "ec2" {
  backend = "s3"

  config = {
    bucket = "<YOUR_TERRAFORM_BACKEND_BUCKET>"
    key    = "ec2/terraform.tfstate"
    region = "us-east-1"
  }
}
