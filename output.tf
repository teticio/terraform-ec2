output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "instance_id" {
  value = aws_instance.ec2.id
}

output "home_ebs_volume" {
  value = aws_instance.ec2.root_block_device.0.volume_id
}
