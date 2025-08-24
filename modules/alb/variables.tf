variable "vpc_id" {}

variable "public_subnets" {
  type = list(string)
}


variable "enable_https" {
  type = bool
}

variable "target_group_arn" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "alb_name" {

}