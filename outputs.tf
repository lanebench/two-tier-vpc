output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_id" {
  value = aws_subnet.public.id
}
output "private_subnet_id" {
  value = aws_subnet.private.id
}
output "private_subnet2_id" {
  value = aws_subnet.private2.id
}
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}
output "ec2_instance_id" {
  value = aws_instance.web.id
}
output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}
output "rds_secret_arn" {
  value = aws_db_instance.mysql.master_user_secret[0].secret_arn
}