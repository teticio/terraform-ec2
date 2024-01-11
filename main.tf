provider "aws" {
  region  = var.region

  default_tags {
    tags = {
      Name          = var.name
      ManagedBy     = "Terraform"
      ManagedByType = "IAC"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }
}

data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

locals {
  default_vpc = var.vpc_id == "" ? tolist(data.aws_vpc.default.*.id)[0] : var.vpc_id
}

data "aws_subnets" "vpc" {
  filter {
    name   = "vpc-id"
    values = [local.default_vpc]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.vpc.ids[0]
}

resource "aws_security_group" "ec2" {
  name   = var.name
  vpc_id = local.default_vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_rule" {
  for_each          = { for port in var.ingress_ports : tostring(port) => port }
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_key_pair" "ec2" {
  key_name   = var.name
  public_key = file(var.public_key_path)
}

resource "aws_ebs_volume" "home" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.volume_size
}

resource "aws_instance" "ec2" {
  subnet_id              = data.aws_subnet.selected.id
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  availability_zone      = data.aws_subnet.selected.availability_zone
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.name

  root_block_device {
    volume_size = var.root_volume_size
  }

  user_data = templatefile("bootstrap.tftpl", {
    startup_commands = join("\n", var.startup_commands)
  })
}

resource "aws_volume_attachment" "home" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.home.id
  instance_id  = aws_instance.ec2.id
  skip_destroy = true
}
