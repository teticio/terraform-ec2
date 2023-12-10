
variable "name" {
  type    = string
  default = "ec2"
}

variable "region" {
  type    = string
  default = "eu-west-2"
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

variable "volume_size" {
  type    = number
  default = 20
}

variable "startup_commands" {
  type    = list(string)
  default = []
}
