output "public_ec2_ip" {
    value = aws_instance.public_ec2.public_ip
    description = "public ip for web server"

}

output "public_ec2_dns" {
    value = aws_instance.public_ec2.public_dns
    description = "public dns for web server"

}

output "private_ec2_id" {
    value = aws_instance.private_ec2.id
    description = "private ec2 instance id"

}

output "nat_gateway_ip" {
    value = aws_eip.nat_eip.public_ip
    description = "NAT gateway and elastic IP"
}

output "load_balancer_dns" {
    value = aws_lb.test.dns_name
    description = "load balancer DNS"
}