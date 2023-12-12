output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "instance_id" {
  value = aws_instance.ec2.id
}

output "home_ebs_volume" {
  value = aws_ebs_volume.home.id
}
