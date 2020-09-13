variable "subnet_type" {
  type = string
  default = "private"
}

variable "name" {
  description = "Default subnet group name"
  type        = string
  default     = "private"
}

variable "cluster_id" {
  description = "Id to assign the new cluster"
  type        = string
  default     = "redis-cluster"
}

variable "node_groups" {
  description = "Number of nodes groups to create in the cluster"
  default     = 1 
}
