terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# 1. Configure AWS Provider (Mumbai Region)
provider "aws" {
  region     = "ap-south-1" 
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Variables
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "pvt_key" {}

# 2. Create Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow SSH and Node App"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node App"
    from_port   = 3000
    to_port     = 3000
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

# 3. Create Key Pair (Uploads your local SSH key to AWS)
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = file("${var.pvt_key}.pub")
}

# 4. Create the Server (EC2 Instance)
resource "aws_instance" "app_server" {
  ami           = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04 in Mumbai (ap-south-1)
  instance_type = "t2.micro"              # Free Tier
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "NodeApp-Server"
  }
}

# 5. Output the IP
output "server_ip" {
  value = aws_instance.app_server.public_ip
}