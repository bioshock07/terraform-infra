//resource "aws_s3_bucket" "example" {
//  bucket = var.bucket_name
//}

//resource "aws_s3_bucket_acl" "example_acl" {
//  bucket = aws_s3_bucket.example.id
//  acl    = "private"
//}

resource "aws_instance""example1"{
ami="ami-084568db4383264d4"
instance_type="t2.micro"
tags = {
Name="tfinstance"
}
}

terraform {
  backend "s3" {
    bucket         = "jenkins-tfbuck"
    key            = "jenkins/infra.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
