variable "rule_type" {
  description = "Rule Type to add"
  type = string
  default = ""
}

variable "from_port" {
  description = "Starting Port"
  type = number
  default = 1
}

variable "to_port" {
  description = "Ending Port"
  type = number
  default = 1
}

variable "protocol" {
  description = "Protocol to allow"
  type = string
  default = ""
}

variable "cidr_blocks" {
  description = "CIDR blocks to allow"
  type = string
  default = ""
}

variable "security_group_id" {
  description = "Name of the SG"
  type = string
  default = ""
}

variable "description" {
  description = "description of the rule"
  type = string
  default = ""
}
