variable "vpc_id" {
  type = string
}

variable "name_prefix" {
  
}

variable "instance_type" {
  type = string
}
variable "alb_sg_id" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "min_instance_count" {
  type = number
}

variable "max_instance_count" {
  type = number
}

variable "private_subnets" {
  type = list(string)
}