terraform {
  backend "s3" {
    bucket = "somesh-bucket-3028"
    key    = "state"
    region = "us-east-1"
  }
}