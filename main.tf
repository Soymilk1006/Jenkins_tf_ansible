terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "vpc_block" {
  description = "vpc block"
  default = "10.0.0.0/16"
  
}
variable "subnet_cidr_block"{
   description = "Subnet Cidr IP "
   default = "10.0.0.0/24"
}


variable "availability_zone" {
  description = "availability_zone name"
  default = "ap-southeast-1c"
  
}

variable "env_prefix" {
  
}

variable "my_ip" {
  
}

variable "ec2_instance_type" {
  
}

variable "public_key_location" {
  
}

variable "entry-script" {
  
}




# Best Practise is that export creditials to enviroment variables
# Best Practise is to configure ~/.aws/credentials file,which can do through aws configure command 
provider "aws" { 
    region = "ap-southeast-1"
  
}



resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
  
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
    
  
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.development-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
  
}

# resource "aws_route_table" "myapp-route-table" {
#   vpc_id = aws_vpc.development-vpc.id
#   route {
#        cidr_block = "0.0.0.0/0"
#        gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     Name: "${var.env_prefix}-rtb"
#   }
  
# }

# resource "aws_route_table_association" "myapp-route-table-association" {
#   subnet_id = aws_subnet.dev-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }


#use default route table
resource "aws_default_route_table" "myapp-aws_default_route_table" {
  default_route_table_id = aws_vpc.development-vpc.default_route_table_id
  
  route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }

  
}

#Apply Security Group

resource "aws_default_security_group" "myapp-default-sg" {
  vpc_id = aws_vpc.development-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =[var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  
  tags={
        Name: "${var.env_prefix}-default-sg"
    }
  
}

# Linux Image for aws ec2 instance

resource "aws_instance" "myapp-server" {
  ami= data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.ec2_instance_type
  subnet_id = aws_subnet.dev-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  user_data = file(var.entry-script)
  user_data_replace_on_change = true 

  tags = {
    Name ="${var.env_prefix}-server"
  }
  
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name="name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
}


#Set up key pairs
resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
  
}


output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}