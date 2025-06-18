resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_ids[0]
  key_name      = var.key_name

  tags = merge(
    var.tags,
    {
      Name = "bastion-host"
    }
  )
}
