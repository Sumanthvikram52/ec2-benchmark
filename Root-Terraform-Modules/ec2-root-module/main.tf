data "aws_ami" "ubuntu_18_04" {
  most_recent = true
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}
resource "aws_instance" "server_instance" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_flavor_name
  key_name      = var.instance_keypair
  subnet_id     = var.subnet_id
  security_groups = var.security_groups
  disable_api_termination = var.api_terminate
  root_block_device {
    volume_type = var.rootfs_volume_type
    volume_size = var.rootfs_volume_size
    delete_on_termination = var.volume_terminate
  }
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}