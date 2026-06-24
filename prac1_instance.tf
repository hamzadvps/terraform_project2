terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-2"
}

# Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create AWS Key Pair
resource "aws_key_pair" "prac1ins_key" {
  key_name   = "prac1ins-key"
  public_key = file("${path.module}/prac1ins-key.pub")
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name = "prac1ins-ec2-sg"

  ingress {
    description = "SSH"

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "prac1ins" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.prac1ins_key.key_name

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = "prac1ins-ohio-ec2"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.prac1ins.id
}

output "public_ip" {
  value = aws_instance.prac1ins.public_ip
}

output "public_dns" {
  value = aws_instance.prac1ins.public_dns
}

output "keypair_name" {
  value = aws_key_pair.prac1ins_key.key_name
}




