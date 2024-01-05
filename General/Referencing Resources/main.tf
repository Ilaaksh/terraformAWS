provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "first_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC-1"
  }
}
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.first_vpc.id //Referencing the resources which was declared above
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Subnet"
  }
}