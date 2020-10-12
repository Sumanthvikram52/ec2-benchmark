variable "name" {
  description = "Name of the Instance"
  type = string
  default = ""
}

variable "instance_flavor_name" {
  description = "Instance Type to use for deployment"
  type = string
}

variable "instance_count" {
  description = "Number of Instance to be created"
  type = string
  default = 1
}

variable "instance_keypair" {
  description = "Default Keypair to Access the instance"
  default = "terraform-default"
}

variable "rootfs_volume_type" {
  description = "Block device type of rootfs, gp2/standard"
  default = "gp2"
}

variable "rootfs_volume_size" {
  description = "Size of the rootfs"
  default = 10
}

variable "volume_terminate" {
  description = "Delete rootfs on termination"
  type    = bool
  default = false
}

variable "subnet_id" {
  description = "subnet id to launch the VM"
  type = string
  default = ""
}

variable "security_groups" {
  description = "SG to be attached"
  type        = list
  default = [""]
}

variable "api_terminate" {
  description = "Disable ec2 api termination"
  type    = bool
  default = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ami" {
  description = "AMI to use for luanching EC2"
  type = string
  default = ""  
}