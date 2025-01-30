# Provider setup
provider "aws" {
  region = "us-east-1"  # Change this to your preferred AWS region
}

# VPC (Virtual Private Cloud)
resource "aws_vpc" "savanah" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "savanah-vpc"
  }
}

# Subnet
resource "aws_subnet" "savanah" {
  vpc_id                  = aws_vpc.savanah.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Specify your availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "savanah-subnet"
  }
}

# Security Group (allow HTTP and HTTPS traffic)
resource "aws_security_group" "savanah" {
  name        = "savanah-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.savanah.id

  # Allow HTTP (port 80) and HTTPS (port 443)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (port 22) for remote access (optional, you can remove if unnecessary)
  ingress {
    from_port   = 22
    to_port     = 22
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

# Elastic IP (Static IP)
resource "aws_eip" "savanah" {
  vpc = true
}

# EC2 Instance
resource "aws_instance" "savanah" {
  ami                         = "ami-0c55b159cbfafe1f0"  # Replace with a valid Ubuntu AMI in your region
  instance_type               = "t2.micro"  # You can change this to the required instance size
  subnet_id                   = aws_subnet.savanah.id
  security_group_ids          = [aws_security_group.savanah.id]
  associate_public_ip_address = true

  tags = {
    Name = "savanah-ec2-instance"
  }

  # Optional: User data script to install a web server 
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
}

# Associate Elastic IP with the EC2 instance
resource "aws_network_interface_sg_attachment" "savanah" {
  security_group_id    = aws_security_group.savanah.id
  network_interface_id = aws_instance.savanah.network_interface_ids[0]
}

resource "aws_eip_association" "savanah" {
  instance_id = aws_instance.savanah.id
  public_ip   = aws_eip.savanah.public_ip
}

# Output the Public IP of the EC2 Instance
output "instance_public_ip" {
  value = aws_eip.savanah.public_ip
}
