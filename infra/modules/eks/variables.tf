variable "cluster_name" {
  description = "eks cluster name"
  type        = string
}

variable "cluster_version" {
  description = "eks cluster version"
  type        = string
}

variable "cluster_vpc_id" {
  description = "eks cluster vpc id"
  type        = string
}
variable "cluster_subnet_ids" {
  description = "eks cluster subnet ids"
  type        = list(string)
}


variable "node_groups" {
  description = "eks node group name"
  type = map(object({
    capacity_type = string
    instance_type = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}

