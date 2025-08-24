variable "region" {
  default = "us-east-1"
}

variable "enable_https" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  type      = string
  default   = null
  sensitive = true
}

