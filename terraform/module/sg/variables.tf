variable "vpc_id" {
  type = string
}
variable "eks_sg_ingress" {
  type = list(object({
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_block = string
  }))
}
