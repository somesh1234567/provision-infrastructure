output "subnet_id" {
    description = "The ID of the subnet"
    value       = aws_subnet.somesh_subnet.id
}

output "security_group_id" {
    description = "The ID of the security group"
    value       = aws_security_group.somesh_sg.id
}