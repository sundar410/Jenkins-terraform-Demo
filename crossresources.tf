provider "aws" {
    region = "ap-south-1"
    
}

resource "aws_instance" "myec2"{
    ami = "ami-0a4a70bd98c6d6441"
   

    instance_type = "t3.micro"
     tags = {
    Name = "eipassociation-tf"
  }

    
}
resource "aws_eip" "lb"{
    vpc = true
    tags = {
    Name = "eipassociation-tf"
    Application = "Terraform"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.myec2.id
  allocation_id = aws_eip.lb.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-18f2e670"
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.lb.public_ip}/32"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.sg-ip]
  }
}
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.allow_tls.id
  network_interface_id = aws_instance.myec2.primary_network_interface_id
}

