# ec2

resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [ var.security_group_id ]

  tags = {
    Name = "demo-web-server"
  }
}