variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
}

variable "san_domains" {
  description = "List of Subject Alternative Names (SANs)"
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID for DNS validation"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the certificate"
  type        = map(string)
  default     = {}
}
