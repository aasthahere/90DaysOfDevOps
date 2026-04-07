variable "vpc_id" {
  description = "VPC ID where SG will be created"
  type        = string
}

variable "sg_name" {
  description = "Security group name"
  type        = string
}

variable "ingress_ports" {
  description = "List of ports to allow inbound"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
