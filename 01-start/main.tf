provider "aws" {
  region = "ap-northeast-2"
}



resource "aws_instance" "ubuntu" {
  ami           = "ami-0ab04b3ccbadfae1f"
  instance_type = "t2.micro"

  tags = {
    Name = "tf-ubuntu"
  }
}