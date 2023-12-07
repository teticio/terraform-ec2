provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2"
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
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = "ec2"

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
