provider "aws" {
  region = "ap-south-1"
}

# Security Group (allow SSH)
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_instance" "hospitality_server" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t3.micro"
  key_name               = "hospatility-key"
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "hospitality-terraform-server"
  }
}