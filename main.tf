provider "aws" {
  region = var.region

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

resource "aws_security_group" "ec2" {
  name        = var.name

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

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "home" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.volume_size
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  availability_zone      = data.aws_availability_zones.available.names[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.name

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
