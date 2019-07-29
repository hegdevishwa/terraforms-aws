variable "vpc_name" {
  description = "name for the VPC to be created"
  type        = "string"
  default     = "main"
}

variable "network_address_space" {
  description="network cidr for the network address space in the VPC"
  default = "10.1.0.0/16"
}
