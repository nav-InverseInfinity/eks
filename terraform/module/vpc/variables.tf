variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "subnets" {
  type = object({
    public = map(object({
      az         = string
      cidr_block = string
      map_public = bool
    }))
    private = map(object({
      az         = string
      cidr_block = string
      map_public = bool
    }))
  })
}
variable "cluster_name" {
  type = string
}
