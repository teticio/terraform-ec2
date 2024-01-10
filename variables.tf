variable "name" {
  type    = string
  default = "ec2"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "ami_owner" {
  type    = string
  default = "099720109477" # Canonical
}

variable "ami_name" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*"
}

variable "ami_architecture" {
  type    = string
  default = "x86_64"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ingress_ports" {
  type    = list(number)
  default = [22]
}

variable "root_volume_size" {
  type    = number
  default = 8
}

variable "volume_size" {
  type    = number
  default = 20
}

variable "startup_commands" {
  type    = list(string)
  default = []
}
