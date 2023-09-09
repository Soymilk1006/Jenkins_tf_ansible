
variable "vpc_block" {
  description = "vpc block"
  default     = "10.0.0.0/16"

}
variable "subnet_cidr_block" {
  description = "Subnet Cidr IP "
  default     = "10.0.0.0/24"
}


variable "availability_zone" {
  description = "availability_zone name"
  default     = "ap-southeast-1c"

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

variable "private_key_location" {

}

variable "work_home" {
  
}