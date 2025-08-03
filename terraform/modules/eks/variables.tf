variable "cluster_name" { type = string }
variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }
variable "tags" { type = map(string) }
variable "enable_irsa" { type = bool }
