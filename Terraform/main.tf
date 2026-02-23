provider "aws" {
  region = "us-east-1"
}

resource "aws_eks_cluster" "hospitality_cluster" {
  name     = "hospitality-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "hospitality-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
# 1. Define a Security Group to allow access to your FastAPI app
resource "aws_security_group" "hospitality_ec2_sg" {
  name        = "hospitality-app-sg"
  description = "Allow SSH and FastAPI traffic"

  # Allow SSH for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Allow traffic on port 8000 (standard for your app)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Define the EC2 Instance
resource "aws_instance" "hospitality_server" {
  ami           = "ami-0440d3b780d96b29d" # Amazon Linux 2023 AMI in us-east-1
  instance_type = "t2.micro"             # Free tier eligible

  vpc_security_group_ids = [aws_security_group.hospitality_ec2_sg.id]

  tags = {
    Name = "HospitalityAppServer"
  }
}

# 3. Output the IP address so you can find your server
output "ec2_public_ip" {
  value = aws_instance.hospitality_server.public_ip
}

