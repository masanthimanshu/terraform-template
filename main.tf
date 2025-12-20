terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "test_instance" {
  instance_type          = "t2.micro"
  key_name               = "testing_key"
  iam_instance_profile   = "TestingRole"
  ami                    = "ami-00ca570c1b6d79f36"
  vpc_security_group_ids = ["sg-03e6b50ee28ef44af"]

  tags = {
    Name = "TestInstance"
    Role = "BackendServer"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    docker_compose = file("${path.module}/scripts/compose.yaml")
    nginx_config   = file("${path.module}/scripts/nginx.conf")
  })
}
