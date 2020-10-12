data "aws_ami" "ubuntu_18" {
  most_recent = true
  owners = ["679593333241"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
data "aws_vpc" "default" {
  default = true
  }

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "default" {
  count = length(data.aws_subnet_ids.default.ids)
  id    = tolist(data.aws_subnet_ids.default.ids)[count.index]
}

locals {
  ami_id = data.aws_ami.ubuntu_18.id
  vpc_id = data.aws_vpc.default.id
  subnet_id = data.aws_subnet.default.*.id
  vpc_cidr = cidrsubnet(data.aws_vpc.default.cidr_block, 0, 0)
}


resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.keypair_name
  public_key = file(pathexpand("~/.ssh/public.key"))
}

module "benchmark_sg_create" {
  source = "/opt/ec2-benchmark/Root-Terraform-Modules/vpc-root-module/sg-root-module/"
  vpc_id = local.vpc_id
  default_cidr = local.vpc_cidr
}

module "add_rules_sg" {
  source = "/opt/ec2-benchmark/Root-Terraform-Modules/vpc-root-module/sg-rule-add-root-module/"
  count = length(var.ingress_rules)
  rule_type = var.ingress_rules[count.index].type
  from_port = var.ingress_rules[count.index].from_port
  to_port = var.ingress_rules[count.index].to_port
  protocol = var.ingress_rules[count.index].protocol
  cidr_blocks = var.ingress_rules[count.index].cidr_block
  description = var.ingress_rules[count.index].description
  security_group_id = module.benchmark_sg_create.sg_id[0]
}

module "server_benchmark_001" {
  source = "/opt/ec2-benchmark/Root-Terraform-Modules/ec2-root-module/"
  instance_count = 1
  ami = local.ami_id
  instance_flavor_name = lookup(var.instance_type,var.instance_core)
  instance_keypair = aws_key_pair.ec2_key_pair.key_name
  subnet_id = tostring(local.subnet_id[0])
  security_groups = module.benchmark_sg_create.sg_id
  name = "Source_VM_001"
}


resource "null_resource" "server_benchmark_001" {
  depends_on = [module.server_benchmark_001]
  connection {
    host = module.server_benchmark_001.ec2_public_address[0]
    private_key = file(pathexpand("~/.ssh/private.key"))
    user = "ubuntu"
  }
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "/opt/ec2-benchmark/Ansible-Playbooks/install_iperf3/main.yaml"
      }
      extra_vars = {
        start_server = "True"
      }
    }
    ansible_ssh_settings {
      connect_timeout_seconds = 60
      connection_attempts = 5
      insecure_no_strict_host_key_checking = true
    }
  }
}

module "client_benchmark_002" {
  source = "/opt/ec2-benchmark/Root-Terraform-Modules/ec2-root-module/"
  depends_on = [null_resource.server_benchmark_001]
  instance_count = 1
  ami = data.aws_ami.ubuntu_18.id
  instance_flavor_name = lookup(var.instance_type,var.instance_core)
  instance_keypair = aws_key_pair.ec2_key_pair.key_name
  subnet_id = tostring(local.subnet_id[0])
  security_groups = module.benchmark_sg_create.sg_id
  name = "Destination_VM_002"
}


resource "null_resource" "client_benchmark_002" {
  depends_on = [module.client_benchmark_002]
  connection {
    host = module.client_benchmark_002.ec2_public_address[0]
    private_key = file(pathexpand("~/.ssh/private.key"))
    user = "ubuntu"
  }
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "/opt/ec2-benchmark/Ansible-Playbooks/install_iperf3/main.yaml"
      }
    }
    plays {
      playbook {
        file_path = "/opt/ec2-benchmark/Ansible-Playbooks/run_iperf3/main.yaml"
      }
      extra_vars = {
        server_ip = module.server_benchmark_001.ec2_private_address[0]
      }
    }
    ansible_ssh_settings {
      connect_timeout_seconds = 60
      connection_attempts = 5
      insecure_no_strict_host_key_checking = true
    }
  }
}
