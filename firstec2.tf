provider "aws" {
  region     = var.region
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
}

resource "aws_instance" "myec2" {
    ami = var.os-name
    instance_type = var.instance-type
    subnet_id = aws_subnet.demo-subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.demo-vpc-sg.id]

    


    tags = {
      Name = "my-first-ec2"
    }
}

//create vpc
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc-cidr
}

//create subnet
resource "aws_subnet" "demo-subnet" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = var.subnet1-cidr
  availability_zone = var.subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-subnet"
  }
}

//create internet gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

//route table
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "demo-rt"
  }
}

//subnet association with rt
resource "aws_route_table_association" "demo-rt_association" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
}


//security group
resource "aws_security_group" "demo-vpc-sg" {
  name        = "demo-vpc-sg"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}