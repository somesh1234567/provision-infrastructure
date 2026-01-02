terraform {
  backend "s3" {
    bucket = "somesh-bucket-1999"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}