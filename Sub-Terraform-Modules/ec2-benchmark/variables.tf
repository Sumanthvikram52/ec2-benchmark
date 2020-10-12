variable "instance_type" {
  description = "Instance Type to use for deployment"
  type = map
  default = {
    "1"  = "t2.small"
    "2"  = "t2.medium"
    "4"  = "t2.xlarge"
    "8"  = "t2.2xlarge"
  }
}

variable "keypair_name" {
  description = "Default Keypair to Access the instance"
  default = "terraform-default"
}

variable "instance_core" {
  description = "Instance vCPU number"
  type    = string
  default =  1
}

variable "ingress_rules" {
  description = "Rules to add"
      type = list(object({
      type        = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
}