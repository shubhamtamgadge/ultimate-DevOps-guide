output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}

output "arn" {
  value = aws_instance.testinstance.arn
}

output "public_ip" {
  value = aws_instance.testinstance.public_ip
}
