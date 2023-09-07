

# Linux Image for aws ec2 instance

resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.myapp-default-sg_id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name
  # user_data = file(var.entry-script)
  # user_data_replace_on_change = true 

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = var.entry-script
    destination = "/home/ec2-user/${var.entry-script}"
  }
  provisioner "remote-exec" {
    # inline = [ 
    #   "export ENV=dev",
    #   "mkdir newdir"
    #  ]
    script = file(var.entry-script)

  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"

  }

  tags = {
    Name = "${var.env_prefix}-server"
  }

}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}


#Set up key pairs
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)

}