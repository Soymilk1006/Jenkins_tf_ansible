
# Best Practise is that export creditials to enviroment variables
# Best Practise is to configure ~/.aws/credentials file,which can do through aws configure command 
# export AWS_ACCESS_KEY_ID=your_access_key_id
# export AWS_SECRET_ACCESS_KEY=your_secret_access_key
# export AWS_DEFAULT_REGION=us-west-2
provider "aws" {
  region = "ap-southeast-1"

}



resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_block
  enable_dns_hostname = true
  tags = {
    Name : "${var.env_prefix}-vpc"
  }

}



#Apply Security Group

resource "aws_default_security_group" "myapp-default-sg" {
  vpc_id = aws_vpc.development-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name : "${var.env_prefix}-default-sg"
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


module "myapp-subnet" {
 source="./modules/subnet"
 vpc_id = aws_vpc.development-vpc.id
 default_route_table_id = aws_vpc.development-vpc.default_route_table_id
 env_prefix = var.env_prefix
 subnet_cidr_block = var.subnet_cidr_block
 availability_zone = var.availability_zone
} 

module "webserver" {
  source="./modules/webserver"
  vpc_id = aws_vpc.development-vpc.id
  my_ip= var.my_ip
  env_prefix = var.env_prefix
  ec2_instance_type= var.ec2_instance_type
  subnet_id= module.myapp-subnet.subnet.id
  availability_zone= var.availability_zone
  public_key_location= var.public_key_location
  private_key_location=var.private_key_location
  entry-script= var.entry-script
  myapp-default-sg_id=aws_default_security_group.myapp-default-sg.id
  work_home=var.work_home

}


