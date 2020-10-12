variable "name" {
  description = "Name of the SG"
  type = string
  default = ""
}

variable "description" {
  description = "description of the SG"
  type = string
  default = "Create by Terraform script"
}

variable "vpc_id" {
  description = "VPC ID to create the SG"
  type = string
  default = ""
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "default_cidr" {
  description = "Default CIDR to allow in inbound"
  type = string
  default = ""
}
