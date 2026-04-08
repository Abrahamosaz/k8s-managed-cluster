variable "vpc_cidr_block" {
  description = "CIDR range for vpc"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
}

variable "resource_tags" {
  description = "Tags for this project resources"
  type        = map(string)
}

variable "region" {
  description = "Region for deploying resources"
  type        = string
}

variable "azs" {
  description = "Multi AZ for high availability, it should match the number of subnets (both private and public)"
  type        = list(string)
}


variable "enable_ngw" {
  description = "Boolean to control if a nat gateway should be created for private subnet"
  type        = bool
  default     = false
}


variable "master_node_count" {
  description = "Number of control panel node in my cluster"
  type        = number
  default     = 1
}

variable "worker_node_count" {
  description = "Number of worker node in my cluster"
  type        = number
  default     = 1
}

variable "master_node_instance_type" {
  description = "Instance type for master nodes"
  type        = string
  default     = "t3.small"
}

variable "worker_node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.small"
}
