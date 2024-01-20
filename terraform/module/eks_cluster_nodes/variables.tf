variable "env" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "eks_cluster_policy_arns" {
  type = map(string)
}

variable "eks_node_policy_arns" {
  type = map(string)
}

variable "eks_subnets" {
  type = list(string)
}

variable "node_groups" {
  type = map(object({
    node_group_name  = string
    instance_types   = list(string)
    max_scaling_size = number
    capacity_type    = string
    # taint            = map(string)
  }))
}

variable "node_taint" {
  type = map(string)
}
