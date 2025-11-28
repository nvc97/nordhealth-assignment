output "ec2_public_ip" {
  value = aws_instance.demo-ec2-tf.public_ip
}